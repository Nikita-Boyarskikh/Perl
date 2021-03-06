package Local::Log;

use 5.016;
use strict;
use Time::HiRes qw(gettimeofday);
use POSIX qw(strftime);
use Exporter 'import';

our @EXPORT = our @EXPORT_OK = qw($log);

our $log = __PACKAGE__->new();

sub new {
	my $pkg = shift;
	my $self = bless {
		prefix => '',
	}, $pkg;
}

sub clone {
	my $old = shift;

	my $self = bless {
		@_,
	}, ref $old;

	if ($self->{prefix} and $self->{prefix} !~ /\s+$/) {
		$self->{prefix} .= ' ';
	}

	return $self;
}

sub prefix {
	my $self = shift;
	if (@_) {
		$self->{prefix} = shift;
	}
	else {
		return $self->{prefix};
	}
}

our %COLOR = (
	debug     => "37",
	info      => "1;37",
	warn      => "1;33",
	error     => "31",
	# fatal     => "4;1;31",
	fatal     => "1;31",
);

BEGIN {
	our @methods = qw(debug info warn error fatal);
	for my $method (@methods) {
		no strict 'refs';
		*$method = sub {
			my $self = shift;
			my $msg = shift;
			if (@_ and index($msg,'%') > -1) {
				$msg = sprintf $msg, @_;
			}
			$msg =~ s{\n*$}{};
			{
				no warnings 'utf8';
				my ($s,$ms) = gettimeofday;
				printf "%s.%03d [+%d]\t", strftime("%Y-%m-%d %H:%M:%S",localtime($s)),int($ms/1000), $s-$^T;
				if (-t STDOUT) {
					print STDOUT "\e[".( $COLOR{$method} || 0 )."m";
				}
				print STDOUT "[".uc( $method )."]\t".$self->{prefix}.$msg;
				if (-t STDOUT) {
					print STDOUT "\e[0m";
				}
				print STDOUT "\n";
			}
		};
	}
}

INIT {
	$SIG{__WARN__} = sub {
		my $msg = shift;
		for (@INC) {
			$msg =~ s{(at )\Q$_/\E(.+?line \d+\.)$}{$1$2}m and last;
		}
		$log->warn($msg);
	};
}

1;
