package Local::Iterator::Concater;

use strict;
use warnings;
use Mouse;
use DDP;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

extends 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Concater - concater of other iterators

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Concater->new(
        iterators => [
            $another_iterator1,
            $another_iterator2,
        ],
    );

=cut

has 'iterators', is => 'rw', required => 1,
	trigger => sub {
		my $self = shift;
		for (@{ $self->iterators }) {
			for (@{ $_->array }) {
				push @{ $self->array }, $_;
			}
		}
	};

1;
