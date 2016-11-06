package Local::Record;

use strict;
use warnings;
use Mouse;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

=encoding utf8

=head1 NAME

Local::Record - music library module, that storing one-string data

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

	my $record = Local::Record->new(...);
	
	$record->band();   # Music band
	$record->year();   # Year of release
	$record->album();  # Music album
	$record->track();  # Music track
	$record->format(); # Music file format
	
=cut

has 'band', is => 'rw', isa => 'Str', required => 1;
has 'year', is => 'rw', isa => 'Str', required => 1;
has 'album', is => 'rw', isa => 'Str', required => 1;
has 'track', is => 'rw', isa => 'Str', required => 1;
has 'format', is => 'rw', isa => 'Str', required => 1;

1;
