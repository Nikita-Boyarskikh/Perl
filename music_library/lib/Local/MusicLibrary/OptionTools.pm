package Local::MusicLibrary::OptionTools;

use strict;
use warnings;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

=encoding utf8

=head1 NAME

Local::MusicLibrary::OptionTools - music library module is responsible for the preparation 
of data on the basis of options

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

    Local::MusicLibrary::OptionTools->prepare_option_columns(@columns); # Replace @columns with default value
    Local::MusicLibrary::OptionTools->sort_table($sort, @table); # Sort your @table by field $sort and return sorted @table
    Local::MusicLibrary::OptionTools->prepare_result(options => %options, table => @table, name => @name); # Prepare your @table bases on your %options
    	and return hash: result => @result of preparation and widths => @max_len_strs - array of max widths by columns
    	(@name - prepared array of columns names)

=cut

sub prepare_option_columns {
	shift;
	my @result;
	my $columns = shift;
	unless (defined $columns) {
		@result = ['band', 'year', 'album', 'track', 'format'];
	} else {
		@result = [split ',', $columns];
	}
	return @result;
}

sub sort_table {
	shift;
	my ($sort, @table) = @_;
	if (defined $sort) {
		if ($sort eq 'year') {
			@table = sort { $a->{$sort} <=> $b->{$sort} } @table;
		} else {
			@table = sort { $a->{$sort} cmp $b->{$sort} } @table;
		}
	}
	return @table;
}

sub prepare_result {
	shift;
	my $options = $_[0]->{options};
	my $table = $_[0]->{table};
	my $name = $_[0]->{name};
	my @max_len_strs = ();
	my @result = ();
	for (1 .. scalar @$name) {
		push @max_len_strs, 0;
	}
	for my $rec(@$table) {
		if(
			(!defined $options->{band} || $options->{band} eq $rec->{band}) &&
			(!defined $options->{year} || $options->{year} == $rec->{year}) &&
			(!defined $options->{album} || $options->{album} eq $rec->{album}) &&
			(!defined $options->{track} || $options->{track} eq $rec->{track}) &&
			(!defined $options->{format} || $options->{format} eq $rec->{format})
		){
			my @row = ();
			for (0 .. scalar @$name - 1) {
				my $cur_name = $name->[$_];
				if ( $max_len_strs[$_] < length($rec->{$cur_name}) ) {
					$max_len_strs[$_] = length($rec->{$cur_name});
				}
				push @row, $rec->{$cur_name};
			}
			push @result, [@row];
		}
	}
	return {result => [@result], widths => [@max_len_strs]};
}

1;