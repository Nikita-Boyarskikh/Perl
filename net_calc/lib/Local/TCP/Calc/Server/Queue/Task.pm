package Local::TCP::Calc::Server::Queue::Task;

use strict;
use warnings;

use Mouse;

has file => (is => 'rw', isa => 'Str');
has status => (is => 'rw', isa => 'Int',
				trigger => sub {
						my self = shift;
						self->status_time(time())
				});
has status_time => (is => 'ro', isa => 'Int', lazy_build => 1);

sub _build_status_time { time() };

1;
