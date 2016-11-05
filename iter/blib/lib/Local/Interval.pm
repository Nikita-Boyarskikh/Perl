package Local::Interval;

use strict;
use warnings;
use Mouse;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

=encoding utf8

=head1 NAME

Local::Interval - time interval

=head1 SYNOPSIS

    my $interval = Local::Interval->new('...');

    $interval->from(); # DateTime
    $interval->to(); # DateTime

=cut

has 'from', is => 'rw', isa => 'DateTime', required => 1;
has 'to', is => 'rw', isa => 'DateTime', required => 1;

1;

