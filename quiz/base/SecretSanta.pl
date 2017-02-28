use 5.010;
use warnings;
no warnings "experimental";
use strict;

use Getopt::Long;
use List::Util qw(all);

my ($ignore_family, $ignore_revert) = (0,0);
GetOptions(nofamilies => \$ignore_family, nostrict => \$ignore_revert) or die;

my @array;

while(<STDIN>) {
	chomp;
	my @data = split / /, $_;
	push @array, \@data;
}

for my $pair(calculate(@array)) {
	printf "%s->%s\n", $pair->[0], $pair->[1];
}

sub calculate {
	my @members = map { ref ? @$_ : $_ } @_;
	my %givers;
	@givers{@members} = (1,) x @members;
	my @res;
	my @recipients = @_;
	for my $one(@members) {
		my @copy = map { ref ? @$_ : $_ } grep { !($one ~~ $_) } ($ignore_family ? @members : @recipients);
		my $rand = $copy[ int( rand( $#copy ) ) ];
		last if (not defined $rand);
		if ($ignore_revert or defined $givers{$rand} and $givers{$rand} ne $one) {
			$givers{$one} = $rand;
			push @res, [$one, $rand];
		} else {
			redo if (not all { $_ eq $one }, values %givers);
		}
	}
	return @res;
}
