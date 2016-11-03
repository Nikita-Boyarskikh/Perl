=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

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

sub tokenize($) {
	chomp ( my $expr = shift );
	die "Не хватает цифр в выражении" unless $expr =~ /\d+/;
	my @res;
	my @arr = split /(?<!e)([\+\-\*\/\^\(\)]|\s+)/i, $expr;
	my $pref_is_oper = 1;
	for (@arr) {
		unless ( /^\s+$/ or $_ eq '' ) {
			if ( $_ eq '+' and $pref_is_oper ) {
				push @res, "U+";
				$pref_is_oper = 1;
			}
			elsif ( $_ eq '-' and $pref_is_oper ) {
				push @res, "U-";
				$pref_is_oper = 1;
			}
			elsif ( /^\d*.?\d+e?[\+\-]?\d*$/i) {
				push @res, 0+$_;
				$pref_is_oper = '';
			}
			elsif ( /^[\+\-\*\/\^]$/ and not $pref_is_oper ) {
				push @res, $_;
				$pref_is_oper = 1;
			} elsif ( not $pref_is_oper and $_ eq ')' ) {
				push @res, $_;
			} elsif ( $pref_is_oper and $_ eq '(' ) {
				push @res, $_;
			} else {
				die "Неверное выражение: ".$_;
			}
		}
	}
	return \@res;
}

1;
