package Local::Iterator::Interval;

use strict;
use warnings;
use Mouse;
use Local::Interval;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

extends 'Local::Iterator', 'Local::Interval';

=encoding utf8

=head1 NAME

Local::Iterator::Interval - interval iterator

=head1 SYNOPSIS

    use DateTime;
    use DateTime::Duration;

    my $iterator = Local::Iterator::Interval->new(
      from   => DateTime->new('...'),
      to     => DateTime->new('...'),
      step   => DateTime::Duration->new(seconds => 25),
      length => DateTime::Duration->new(seconds => 35),
    );

=cut

has 'step', is => 'rw', isa => 'DateTime::Duration', required => 1,
	trigger => sub {
		my $self = shift;
		
		my $length;
		unless (defined $self->length) {
			$length = $self->step;
		}
		else {
			$length = $self->length;
		}
		
		my $self_duration = $self->to - $self->from;
		if ($self_duration->is_negative && $self->step->is_positive ||
			$self->step->is_negative && $self_duration->is_positive ||
			$self->step->is_zero) {
					die "Бесконечный итератор";
		}
		
		my $elem = Local::Interval->new(
			from => $self->from,
			to => do { $self->from + $length }
		);
		my $left = $self->to - $elem->to;
		while ($self->step->is_positive && $left->is_positive ||
			   $self->step->is_negative && $left->is_negative ||
			   $left->is_zero) {
			   		push $self->array, $elem;
			   		$elem = Local::Interval->new(
						from => do { $self->array->[scalar @{ $self->array } - 1]->from + $self->step },
						to => do { $self->array->[scalar @{ $self->array } - 1]->from + $self->step + $length }
					);
					$left = $self->to - $elem->to;
		}		
	};
	
has 'length', is => 'rw', isa => 'Maybe[DateTime::Duration]', default => undef;

1;
