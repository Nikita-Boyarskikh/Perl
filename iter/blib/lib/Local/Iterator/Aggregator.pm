package Local::Iterator::Aggregator;

use strict;
use warnings;
use Mouse;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

extends 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Aggregator - aggregator of iterator

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Aggregator->new(
        chunk_length => 2,
        iterator => $another_iterator,
    );

=cut

has 'chunk_length', is => 'rw', default => 1;
has 'iterator', is => 'rw', required => 1,
	trigger => sub {
		my $self = shift;
		$self->array( [@{ $self->iterator->array }]);
	};

sub next {
	my $self = shift;
	my @res = ();
	if ($self->counter == scalar @{ $self->array }) {
		return (undef, 1);
	}
	print ref($self->chunk_length);
	for (1..$self->chunk_length) {
		if ($self->counter < scalar @{ $self->array }) {
			push @res, $self->array->[$self->counter];
			$self->counter($self->counter+1);
		}
		else {
			last;
		}
	}
	return (\@res, 0);
}

1;
