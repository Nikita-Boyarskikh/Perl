package Local::Chat::Core;

use 5.016;
use strict;
use warnings;
use Local::Chat::Tools;
use Local::Chat::Server::Room;
use Class::XSAccessor accessors => [qw( online rooms log )];
use Digest::MD5 'md5_hex';

use DDP;
# /mnt/Data/workSpace/perl/localchat/server/lib/Local/Chat/Core.pm
sub getDB {
	my $db = YAML::LoadFile("$FindBin::Bin/../etc/db.yaml") or warn "cant open db";
	p $db;
	return $db;
}

sub newUser {
	my ($self, $user, $password) = @_;
	return if (!defined($user));

	$user = substr $user, 1;
	#warn $user."  -- " . $password;

	open (my $fh, '>', "$FindBin::Bin/../etc/db.yaml") or warn "cant set new user";

	print $fh $user." : ";

	warn $password;
	$password = (defined $password) ? md5_hex($password) : "";

	warn $password;
	print $fh $password."\n";
	close ($fh);
}

sub new {
	my $pkg = shift;
	my $self = bless { @_ }, $pkg;

	$self->{rooms}  = {}; # { room1 => room1, room2 => room2 }
	$self->{online} = {}; # { nick => { room1 => Local::Chat::Server::Room, ... } }
	$self->{db} = getDB; # { nick => }

	$self->rooms->{'#all'} = Local::Chat::Server::Room->new(
		name => '#all',
		log => $self->log
	);
	return $self;
}

sub randname {
	my $self = shift;
	my $nick = shift;
	for my $digits (2..5) {
		my $max = 10**$digits;
		for (1..50) {
			my $guess = $nick . int(rand($max));
			unless (exists $self->online->{$guess}) {
				return $guess;
			}
		}
	}
	return;
}

sub AUTH {
	my ($self,$conn,$data) = @_;
	# p $data;

	my ($old_nick, $new_nick, $passwd, $v) = ($conn->nick, $data->{nick}, $data->{password}, $data->{v});
	my $nick_for_log = $new_nick;
	if ($new_nick =~ /^@.*/) {$nick_for_log = substr $new_nick, 1};

	if ($old_nick) {
		if ($v == 1) {
			return if ($old_nick eq $new_nick);

			if ($self->online->{$new_nick}) {
				$self->log->warn('User `%s` already exists', $new_nick);
				return $conn->error($data->{seq}, 'Nick unavailable');
			}
			$self->online->{$new_nick} = delete $self->online->{$old_nick};
			$conn->set_nick($new_nick, $data->{seq}); # answer new-nick to connection

			my $rooms = $self->online->{$new_nick}{rooms};
			my %conns;
			for my $room (values %$rooms) {
				for my $c ($room->connections) {
					$conns{ 0+$c } = $c;
				}
			}

			for my $c (values %conns) {
				next if $c == $conn;
				$c->event(RENAME => { from => $old_nick, nick => $new_nick });
			}
		} else { # v == 2
			warn "in else";
			if (exists $self->{db}->{$nick_for_log} && ($self->{db}->{$nick_for_log} eq md5_hex($passwd))) {
				$conn->set_nick($new_nick, $data->{seq}); # answer new-nick to connection
				warn "in v2";
				my $rooms = $self->online->{$new_nick}{rooms};
				my %conns;
				for my $room (values %$rooms) {
					for my $c ($room->connections) {
						$conns{ 0+$c } = $c;
					}
				}

				for my $c (values %conns) {
					next if $c == $conn;
					$c->event(RENAME => { from => $old_nick, nick => $new_nick });
				}
			} else {
				$self->log->warn('Wrong password');
				return $conn->error($data->{seq}, 'Wrong password');
			}
		}
	} else {

		warn "in else";

		if ($v == 2) {
			warn p $self->{db};

			if (exists $self->{db}->{$nick_for_log}) {
				warn "nik existd";

				if (exists $self->{db}->{$nick_for_log} and ($self->{db}->{$nick_for_log} eq "1")) {
					my $old_user = delete $self->online->{$new_nick};
					$self->online->{$new_nick} = {
						conn  => $conn,
						rooms => {},
					};
					$conn->set_nick($new_nick, $data->{seq});
					$self->{db}->{$nick_for_log} = md5_hex($passwd);
					$self->newUser($nick_for_log, $passwd);
					warn "Drop";
					$old_user->{conn}->drop;
					$old_user->{conn}->DESTROY;
					
					warn p $self->{db};

					return;
				}

				if ($self->{db}->{$nick_for_log} eq md5_hex($passwd)) {
					warn "right pawd";
					$self->online->{$new_nick} = {
						conn  => $conn,
						rooms => {},
					};

					$conn->set_nick($new_nick, $data->{seq});

					$self->JOIN($conn, { room => '#all', seq => $data->{seq} });
				} else {
					$self->log->warn('Wrong password');
					return $conn->error($data->{seq}, 'Wrong password');
				}
			} else {
				$self->online->{$new_nick} = {
 					conn  => $conn,
 					rooms => {},
 				};

 				$conn->set_nick($new_nick, $data->{seq});

 				$self->JOIN($conn, { room => '#all', seq => $data->{seq} });
				$self->{db}->{$nick_for_log} = md5_hex($passwd);
				$self->newUser($nick_for_log, $passwd);
				p $self->{db};
			}
		} else {
			warn p $self->online;
			if ($self->online->{$new_nick}) {
				warn "it comes here";
				$new_nick = $self->randname($new_nick);
			}
			$self->online->{$new_nick} = {
				conn  => $conn,
				rooms => {},
			};

			$conn->set_nick($new_nick, $data->{seq});

			$self->JOIN($conn, { room => '#all', seq => $data->{seq} });
			$self->{db}->{$nick_for_log} = 1;
			$self->newUser($nick_for_log, 1);
		}
	}
}

sub user_disconnect {
	my $self = shift;
	my $conn = shift;

	my $user = delete $self->online->{ $conn->nick };
	return unless $user;

	for my $room (values %{ $user->{rooms} }) {
		$room->PART($conn, {});
	}
}

sub JOIN {
	my $self = shift;
	my $conn = shift;
	my $data = shift;
	my $room_name = $data->{room};

	my $user = $self->online->{$conn->nick}{conn};
	my $room = $self->rooms->{$room_name} //= Local::Chat::Server::Room->new(
		admin => $user->nick,
		name  => $room_name,
		log   => $self->log->clone(prefix => "[$room_name] "),
	);

	$room->JOIN($conn, $data);
	weaken($self->rooms->{$room_name}) if $room_name ne '#all' and !isweak($self->rooms->{$room_name});
	$self->online->{ $conn->nick }{rooms}{$room_name} = $room;
}

sub PART {
	my $self = shift;
	my $conn = shift;
	my $data = shift;
	my $room_name = $data->{room};

	my $room = $self->rooms->{$room_name};
    if ($room_name eq "#all") {
        $self->log->debug('Trying to leave #all');
        return;
    }
	unless (defined $room) {
		$self->log->warn('Room `%s` not found', $room_name);
		$conn->error($data->{seq}, 'Room not found');
		return;
	}

	delete $self->online->{ $conn->nick }{rooms}{ $room->name };
	$room->PART($conn, $data);
}

sub MEMBERS {
	my $self = shift;
	my $conn = shift;
	my $data = shift;
	my $room_name = $data->{room};

	my $room = $self->rooms->{$room_name};
	return $conn->error($data->{seq}, "Room $room_name not found")
		unless $room;

    my %users = map { $_ => "_" }
                    map { $_->nick } values %{ $room->members };
	return $conn->error($data->{seq}, "You are not allowed to see users of that room")
        unless $users{$conn->nick};

	$room->MEMBERS($conn,$data);
}

sub TITLE {
	my $self = shift;
	my $conn = shift;
	my $data = shift;
	my $room_name = $data->{room};
	my $new_name = $data->{title};

	my $user = $self->online->{$conn->nick}{conn};
	my $room = $self->rooms->{$room_name} or return $conn->error($data->{seq}, "Room not found `$room_name`");
	
	if($room_name =~ /^\#\w{1,32}$/) {
            $room->TITLE($conn, $data);
	    $room->title = $new_name;
	    weaken($self->rooms->{$room_name}) if $room_name ne '#all' and !isweak($self->rooms->{$room_name});
	    $self->online->{ $conn->nick }{rooms}{$room_name} = $room;
	} else {
            return $conn->error($data->{seq}, "Invalid room name\n");
        }

            
}

sub MSG {
	my $self = shift;
	my $conn = shift;
	my $data = shift;
	$data->{timestamp} = time;

	my $to = $data->{to};
	if($conn->{BAN}{FLAG}){
		if ($data->{timestamp} > $conn->{BAN}{OVER_TIME}){
			$conn->{BAN}{FLAG} = 0;
		}
		else
		{
			my $time = $conn->{BAN}{OVER_TIME} - $data->{timestamp};
			return $conn->error($data->{seq}, "You are banned :c\nRemaining: $time\n");
		}
	}
	if ($conn->{avg_ban_time}) {
	 	if (($#{$conn->{last_mes}}+1) < $conn->{max_msg_avg})
	 	{
			push @{$conn->{last_mes}},  $data->{timestamp};
	 	}
	 	else
	 	{
	 		if ($data->{timestamp} - $conn->{last_mes}[0] < 60){
	 			$conn->{BAN}{OVER_TIME} = $data->{timestamp} + 60 * $conn->{avg_ban_time};
	 			$conn->{BAN}{FLAG} = 1;
	 			return $conn->error($data->{seq}, "You are banned :c\nDon't spam pls.\n");
	 		}
	 		else
	 		{
	 			shift @{$conn->{last_mes}};
	 			push @{$conn->{last_mes}},  $data->{timestamp}
	 		}
		}
	}

	if ($to =~ m/^#/) { # msg to room:
		my $room = $self->rooms->{$to};
		return $conn->error($data->{seq}, "Room not found `$to`")
			unless $room;

		return $conn->error($data->{seq}, "You're not joined into `$to`")
			unless ($room->is_member($conn));

		# ACL here:
		$self->log->debug("Deliver message to room");
		$room->MSG($conn, $data);
	}
	elsif ($to =~ /^\@/) { # for user
		my $reciever = $self->online->{$to};

		return $conn->error($data->{seq},  "Destination $to not found")
			unless $reciever;

		my $sndr = $self->online->{$conn->nick};



		$sndr->{conn}->event(
			MSG => {
				from => $conn->nick,
				to   => $to,
				text => $data->{text},
			}
		);


		$reciever->{conn}->event(
			MSG => {
				from => $conn->nick,
				to   => $to,
				text => $data->{text},
			}
		);
	}
	else {
		return $conn->error($data->{seq}, "Unavailable");
	}
}


1;
