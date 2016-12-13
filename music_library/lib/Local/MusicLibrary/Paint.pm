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
	return if (not defined $result->[0] or not defined $max_len_strs->[0]);
	my $width = 0;
	$width += $max_len_strs->[$_] for(0 .. scalar @$max_len_strs - 1);
	$width += (scalar @$max_len_strs) * 3 - 1;
	print "/".("-" x $width)."\\\n";
	for my $row(@$result) {
		print "|"." "x($max_len_strs->[$_] - length($$row[$_]) + 1).$$row[$_]." " for (0 .. scalar @$row - 1);
		print "|\n";
		if ($row ne $result->[$#$result]) {
			print "|".("-"x($max_len_strs->[0] + 2));
			print "+".("-"x($max_len_strs->[$_] + 2)) for (1 .. scalar @$row - 1);
			print "|\n";
		} else {
			print "\\".("-" x $width)."/\n";
		}
	}
}

1;
