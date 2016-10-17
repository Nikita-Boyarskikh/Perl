use strict;

chomp(my $H=<>);
chomp(my $W=<>);
chomp(my $h=<>);
chomp(my $w=<>);

print "Убогая раскладка:\n";

my $y=$h;
while ($y<$H) {
	my $x=$w;
	while ($x<$W) {
		$x+=$w;
		print "[$h, $w] ";
	}
	if($W % $w != 0) {
		print "[$h, @{[$W%$w]}]";
	}
	print "\n";
	$y+=$h;
}

if($H % $h != 0) {
	my $x=$w;
	while ($x<$W) {
		$x+=$w;
		print "[@{[$H%$h]}, $w] ";
	}
	if($W % $w != 0) {
		print "[@{[$H%$h]}, @{[$W%$w]}]";
	}
}

print "\nДеревенская раскладка:\n";

if($H % $h != 0) {
	my $x=$w;
	if($W % $w != 0) {
		print "[@{[$H%$h/2]}, @{[$W%$w/2]}] ";
	}
	while ($x<$W) {
		$x+=$w;
		print "[@{[$H%$h/2]}, $w] ";
	}
	if($W % $w != 0) {
		print "[@{[$H%$h/2]}, @{[$W%$w/2]}] ";
	}
	print "\n"
}

my $y=$h;
while ($y<$H) {
	my $x=$w;
	if($W % $w != 0) {
		print "[$h, @{[$W%$w/2]}] ";
	}
	while ($x<$W) {
		$x+=$w;
		print "[$h, $w] ";
	}
	if($W % $w != 0) {
		print "[$h, @{[$W%$w/2]}]";
	}
	print "\n";
	$y+=$h;
}

if($H % $h != 0) {
	my $x=$w;
	if($W % $w != 0) {
		print "[@{[$H%$h/2]}, @{[$W%$w/2]}] ";
	}
	while ($x<$W) {
		$x+=$w;
		print "[@{[$H%$h/2]}, $w] ";
	}
	if($W % $w != 0) {
		print "[@{[$H%$h/2]}, @{[$W%$w/2]}]";
	}
}

print "\nКлассическая раскладка:\n";

if($H % $h != 0) {
	my $x=2*$w;
	if($W % $w != 0) {
		print "[@{[($H%$h+$h)/2]}, @{[($W%$w+$w)/2]}] ";
	}
	while ($x<$W) {
		$x+=$w;
		print "[@{[($H%$h+$h)/2]}, $w] ";
	}
	if($W % $w != 0) {
		print "[@{[ ($H%$h+$h)/2 ]}, @{[($W%$w+$w)/2]}] ";
	}
	print "\n"
}

my $y=2*$h;
while ($y<$H) {
	my $x=2*$w;
	if($W % $w != 0) {
		print "[$h, @{[($W%$w+$w)/2]}] ";
	}
	while ($x<$W) {
		$x+=$w;
		print "[$h, $w] ";
	}
	if($W % $w != 0) {
		print "[$h, @{[($W%$w+$w)/2]}]";
	}
	print "\n";
	$y+=$h;
}

if($H % $h != 0) {
	my $x=2*$w;
	if($W % $w != 0) {
		print "[@{[($H%$h+$h)/2]}, @{[($W%$w+$w)/2]}] ";
	}
	while ($x<$W) {
		$x+=$w;
		print "[@{[($H%$h+$h)/2]}, $w] ";
	}
	if($W % $w != 0) {
		print "[@{[($H%$h+$h)/2]}, @{[($W%$w+$w)/2]}]";
	}
}

print "\n";
