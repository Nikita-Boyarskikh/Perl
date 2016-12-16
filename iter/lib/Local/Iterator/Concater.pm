package Local::Iterator::Concater;

use strict;
use warnings;
use Mouse;
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

has 'iterators', is => 'rw', required => 1;

sub next {
	my $self = shift;
	my $res;
	for my $iter(@{$self->iterators}) {
		my ($elem, $status) = $iter->next();
		if (!$status) {
			$res = $elem;
			last;		
		}
		else {
			next;
		}
	}
	return ($res, 0) if defined $res;
	return (undef, 1);
}

1;
