use strict;
use warnings;
use Data::Dumper;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';
use JSON::XS;

die 'Wrong argument!' if(defined $ARGV[0] and $ARGV[0] ne '--bare');

my @resources = ();
my $str;
while (defined($str = <STDIN>) and ($str ne $/)) {
	push @resources, decode_json $str;
}
my @users = ();
while (<STDIN>) {
	push @users, decode_json $_;
}

for my $usr(@users) {
	$usr->{'ans'} = 1;
	for my $res(@resources) {
		for my $key(keys $usr->{'resources'}) {
			if($res->{'name'} eq $key) {
				if($res->{'capacity'} >= $usr->{'resources'}{$key}) {
					$res->{'capacity'} -= $usr->{'resources'}{$key};
				} else {
					$res->{'capacity'} = 0 if (defined $ARGV[0]);
					$usr->{'ans'} = 0;
				}
			}
		}
	}
}

for (@users) {
	print $_->{'name'}.' ' if ($_->{'ans'});
}
print "\n";
