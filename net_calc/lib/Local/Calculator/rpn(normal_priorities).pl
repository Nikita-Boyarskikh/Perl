=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize(normal_priorities).pl";

sub isLeft {
	return (shift =~ /^[\+\-\*\/]$/) ? 1 : '';
}

sub priority {
	my $var = shift;
	given ($var) {
		when (/U\+|U\-/){
			return 4;
		}
		when (/\^/){
			return 3;
		}
		when (/\/|\*/) {
			return 2;
		}
		when (/\+|\-/) {
			return 1;
		}
		when (/\(/) {
			return 0;
		}
		default {
			die 'Неправильная операция: '.$var
		}
	}
}

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;
	my @stack;
	for (@$source) {
		if (/\d/) {
			push @rpn, $_;
		}
		elsif (/\(/) {
			push @stack, $_;
		}
		elsif (/\)/) {
			if (scalar @stack > 0) {
				my $pop = pop @stack;
				while (scalar @stack > 0 and $pop ne '(') {
					push @rpn, $pop;
					$pop = pop @stack;
				}
				die "Не уравновешено количество скобок!" unless $pop eq '(';
			} else {
				die "Не уравновешено количество скобок!";
			}
		}
		elsif (/U\+|U\-|\+|\-|\*|\/|\^/) {
			if (scalar @stack == 0) {
				push @stack, $_;
			} elsif ( isLeft($_) ) {
				if ( priority(''.$stack[$#stack]) < priority(''.$_) ) {
					push @stack, $_;
				} else {
					while ( scalar @stack > 0 and priority(''.$stack[$#stack]) >= priority(''.$_) and $stack[$#stack] ne '(') {
							push @rpn, pop @stack;
					}
					push @stack, $_;
				}
			} else {
				if ( priority(''.$stack[$#stack]) <= priority(''.$_) ) {
					push @stack, $_;
				} else {
					while ( scalar @stack > 0 and priority(''.$stack[$#stack]) > priority(''.$_) and $stack[$#stack] ne '(') {
							push @rpn, pop @stack;
					}
					push @stack, $_;
				}
			}
		} else {
			die "Неизвестный символ: ".$_;
		}
	}
	while (scalar @stack > 0) {
		die "Не уравновешено количество скобок!" if $stack[$#stack] eq '(';
		push @rpn, pop @stack;
	}
	return \@rpn;
}
1;
