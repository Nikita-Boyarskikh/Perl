package Local::MusicLibrary::Paint;

use strict;
use warnings;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

=encoding utf8

=head1 NAME

Local::MusicLibrary::OptionTools - music library module is responsible for printing data

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
	
	# Paint your @table with widths of columns in @widths
    Local::MusicLibrary::Paint->paint(result => @table, widths => @widths);

=cut

sub paint {
	shift;
	my $result = $_[0]->{result};
	my $max_len_strs = $_[0]->{widths};
	
	# join '/', @$result; (типо csv, но вместо ',' использовать '/') - необходимо вставить \n

	if (defined $result->[0] and defined $max_len_strs->[0]) {
		print "/".("-"x($max_len_strs->[0] + 2));
		for (1 .. scalar @{$result->[0]} - 1) {
			print "-"x($max_len_strs->[$_] + 3);
		}
		print "\\\n";
		for my $row(@$result) {
			for (0 .. scalar @$row - 1) {
				print "|"." "x($max_len_strs->[$_] - length($$row[$_]) + 1).$$row[$_]." ";
			}
			print "|\n";
			if ($row ne $result->[$#$result]) {
				print "|".("-"x($max_len_strs->[0] + 2));
				for (1 .. scalar @$row - 1) {
					print "+".("-"x($max_len_strs->[$_] + 2));
				}
				print "|\n";
			} else{
				print "\\".("-"x($max_len_strs->[0] + 2));
				for (1 .. scalar @$row - 1) {
					print "-"x($max_len_strs->[$_] + 3);
				}
				print "/\n";
			}
		}
	}
}

1;
