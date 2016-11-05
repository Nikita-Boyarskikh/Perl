package Local::Iterator;

use strict;
use warnings;
use Mouse;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

=encoding utf8

=head1 NAME

Local::Iterator - base abstract iterator

=head1 VERSION

Version 1.00

=cut

our $VERSION = '2.00';

=head1 SYNOPSIS

=cut

has 'array', is => 'rw', default => sub {[]};
has 'counter', is => 'rw', default => 0;

sub next {
	my $self = shift;
	if ($self->counter == scalar @{ $self->array }) {
		return (undef, 1);
	}
	my $elem = $self->array->[$self->counter];
	$self->counter($self->counter+1);
	return ($elem, 0);
}

sub all {
	my $self = shift;
	my @arr = ();
	my ($cur, $stat) = $self->next();
	while (!$stat) {
		push @arr, $cur;
		($cur, $stat) = $self->next();
	}
	return \@arr;
}

1;
