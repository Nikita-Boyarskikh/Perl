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

has 'step', is => 'rw', isa => 'DateTime::Duration', required => 1;
has 'length', is => 'rw', isa => 'Maybe[DateTime::Duration]', default => undef;

sub next {
	my $self = shift;
	my $length;
	unless (defined $self->length) {
		$length = $self->step;
	}
	else {
		$length = $self->length;
	}
	
	my $elem = Local::Interval->new(
		from => $self->from + $self->counter * $self->step,
		to => $self->from + $self->counter * $self->step + $length
	);
	
	$self->counter($self->counter + 1);
	my $left = $self->to - $elem->to;
	if($self->step->is_positive && $left->is_positive ||
	   $self->step->is_negative && $left->is_negative ||
	   $left->is_zero) {
	   		return ($elem, 0);
	} else {
		return (undef, 1);
	}
};

1;
