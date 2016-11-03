=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;

BEGIN {
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}

no warnings 'experimental';

sub evaluate {

	my $rpn = shift;
	my @buf;
	
	for (@$rpn) {
		if (/\d/) {
			push @buf, $_;
		}
		elsif (/U\+/) {
			die "Неверно составлено выражение!" if (scalar @buf < 1);
		}
		elsif (/U\-/) {
			die "Неверно составлено выражение!" if (scalar @buf < 1);
			push @buf, - pop @buf;
		}
		elsif (/\+/) {
			die "Неверно составлено выражение!" if (scalar @buf < 2);
			my $tmp = pop @buf;
			push @buf, (pop @buf) + $tmp;
		}
		elsif (/\-/) {
			die "Неверно составлено выражение!" if (scalar @buf < 2);
			my $tmp = pop @buf;
			push @buf, (pop @buf) - $tmp;
		}
		elsif (/\*/) {
			die "Error! Неверно составлено выражение!" if (scalar @buf < 2);
			my $tmp = pop @buf;
			push @buf, (pop @buf) * $tmp;
		}
		elsif (/\//) {
			die "Неверно составлено выражение!" if (scalar @buf < 2);
			my $tmp = pop @buf;
			push @buf, (pop @buf) / $tmp;
		}
		elsif (/\^/) {
			die "Неверно составлено выражение!" if (scalar @buf < 2);
			my $tmp = pop @buf;
			push @buf, (pop @buf) ** $tmp;
		} else {
			die "Неверно составлено выражение!";
		}
	}
	die "Неверно составлено RPN-выражение!" unless (scalar @buf == 1);
	
	return pop @buf;
}
1;
