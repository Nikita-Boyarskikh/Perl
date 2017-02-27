use strict;
use warnings;

my @arr = (
	{
		name => 34,
		smth => 'dsgsdg',
		value => 2353
	},
	{
		name => 3534,
		smth => 'dsgs34235g',
		gsfd => 'sdg',
		value => 53
	},
	{
		name => 345,
		smth => 'd543g',
		a => 'dsf',
		value => 23
	},
	{
		name => 304,
		smth => ' ',
		value => "",
		d => "gsd"
	},
	{
		name => 334,
		smth => '8405',
		value => 0,
		dgs => 325
	},
	{
		name => 3400,
		smth => '003n',
		value => ";",
		ge => 4534
	},
	{
		name => 34,
		smth => 'hsdighw',
		value => 2303,
		534 => 23
	}
);

my @sorted_array = sort { $a->{name} <=> $b->{name} } @arr;

use DDP;
p @sorted_array;