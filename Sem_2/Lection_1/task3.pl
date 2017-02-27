use Data::Printer;
use Data::Dumper;
use strict;
use warnings;
my @arr=();

while(<>)
{
	chop;
	@arr[++$#arr]=[split(";", $_)];
}

p @arr;
print Dumper(@arr);
