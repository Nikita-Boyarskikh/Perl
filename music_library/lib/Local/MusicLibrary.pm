package Local::MusicLibrary;

use strict;
use warnings;
use Mouse;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::Record;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

    my $library = Local::MusicLibrary->new(options => [...]); # Output options
    
    $library->add_data(...); # Adds new record to our library
    $library->print();       # Prints table of all records in our library

=cut

my @table = ();
has 'options', is => 'rw';

sub print() {
	my @result = ();
	my $self = shift;
	unless (defined $self->options->[6]) {
		$self->options->[6] = ['band', 'year', 'album', 'track', 'format'];
	} else {
		$self->options->[6] = [split ',', $self->options->[6]];
	}
	my @name = @{ $self->options->[6] };
	my @max_len_strs = ();
	for (1 .. scalar @name) {
		push @max_len_strs, 0;
	}
	my $sort = $self->options->[5];
	if (defined $sort) {
		if ($sort eq 'year') {
			@table = sort { $a->$sort <=> $b->$sort } @table;
		} else {
			@table = sort { $a->$sort cmp $b->$sort } @table;
		}
	}
	for my $rec(@table) {
		if(
			(!defined $self->options->[0] || $self->options->[0] eq $rec->band) &&
			(!defined $self->options->[1] || $self->options->[1] == $rec->year) &&
			(!defined $self->options->[2] || $self->options->[2] eq $rec->album) &&
			(!defined $self->options->[3] || $self->options->[3] eq $rec->track) &&
			(!defined $self->options->[4] || $self->options->[4] eq $rec->format)
		){
			my @row = ();
			for (0 .. scalar @name - 1) {
				my $cur_name = $name[$_];
				if ( $max_len_strs[$_] < length($rec->$cur_name) ) {
					$max_len_strs[$_] = length($rec->$cur_name);
				}
				push @row, $rec->$cur_name;
			}
			push @result, [@row];
		}
	}
	if (defined $result[0] and defined $max_len_strs[0]) {
		print "/".("-"x($max_len_strs[0] + 2));
		for (1 .. scalar @{$result[0]} - 1) {
			print "-"x($max_len_strs[$_] + 3);
		}
		print "\\\n";
		for my $row(@result) {
			for (0 .. scalar @$row - 1) {
				print "|"." "x($max_len_strs[$_] - length($$row[$_]) + 1).$$row[$_]." ";
			}
			print "|\n";
			if ($row ne $result[$#result]) {
				print "|".("-"x($max_len_strs[0] + 2));
				for (1 .. scalar @$row - 1) {
					print "+".("-"x($max_len_strs[$_] + 2));
				}
				print "|\n";
			} else{
				print "\\".("-"x($max_len_strs[0] + 2));
				for (1 .. scalar @$row - 1) {
					print "-"x($max_len_strs[$_] + 3);
				}
				print "/\n";
			}
		}
	}
}

sub add_data($) {
	my ($self, $data) = @_;
	$data =~ /^\.\/([^\n\/]+)\/(\d+) \- ([^\n\/]+)\/([^\n\/]+)\.(\w+)$/;
	my $record = Local::Record->new(band => $1, year => $2, album => $3, track => $4, format => $5);
	push @table, $record;
}

1;
