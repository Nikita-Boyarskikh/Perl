use strict;

sub reduce(&@) {

  my ($f, @list) = @_;
  my $elem = shift(@list);
  
  if (scalar @list == 0) {
  	return $elem;
  }
  
  my $result = reduce($f, @list);

  return $elem + $result;
  
}

print( reduce {
  my ($sum, $i) = @_;
  $sum + $i;
} 1, 2, 3, 4);
