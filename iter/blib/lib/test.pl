use FindBin;
use lib "$FindBin::Bin/lib";
use Local::Iterator::Interval;
use DateTime;
use DateTime::Duration;
use strict;
use warnings;
use DDP;

my ($next, $end);
my $from = DateTime->new(
  year       => 1964,
  month      => 10,
  day        => 16,
  hour       => 16,
  minute     => 12,
  second     => 47,
  time_zone  => 'Asia/Taipei',
);
my $to = DateTime->new(
  year       => 1964,
  month      => 10,
  day        => 16,
  hour       => 16,
  minute     => 13,
  second     => 47,
  time_zone  => 'Asia/Taipei',
);

my $iterator = Local::Iterator::Interval->new(
  from   => $from,
  to     => $to,
  step   => DateTime::Duration->new(seconds => 25),
  length => DateTime::Duration->new(seconds => 35),
);

($next, $end) = $iterator->next();
print $next->to . "\n";
($next, $end) = $iterator->next();
print $next->to . "\n";
($next, $end) = $iterator->next();
print $next->to . "\n";
($next, $end) = $iterator->next();
print $next->to . "\n";
