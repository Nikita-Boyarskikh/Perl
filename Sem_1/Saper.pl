use strict;

if (scalar @ARGV != 1) {
	print("Неверное количество параметров!\n");
	exit;
}
eval {
chomp(my $str = <STDIN>);
(my $h, my $w) = split(/\s+/, $str);

my @matrix = [];

for my $i(1..$h) {
	push(@matrix, []);
}

while (chomp(my $str = <STDIN>))
{
	(my $y, my $x) = split(/\s+/, $str);
	$y--;
	$x--; 
	if ($y<$h and $x<$w) {
		$matrix[$y][$x]='X';
	}
}

for my $y(0..$h-1) {
	for my $x(0..$w-1) {
	  if($matrix[$y][$x] ne 'X') {
		$matrix[$y][$x]=0;
		for my $i(-$ARGV[0]..$ARGV[0]) {
			for my $j(-$ARGV[0]..$ARGV[0]) {
				if ($x+$j<$w and $y+$i<$h and $x+$j>=0 and $y+$i>=0 and $matrix[$y+$i][$x+$j] eq 'X') {
					$matrix[$y][$x]++;
				}
			}
		}
	  }
	}
}

for my $y(0..$h-1) {
	for my $x(0..$w-1) {
		print $matrix[$y][$x], ' ';
	}
	print "\n";
}
1;
} or die("Ошибка! Введены некорректные данные");
