package Local::Iterator::File;

use strict;
use warnings;
use Mouse;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

=encoding utf8

=head1 NAME

Local::Iterator::File - file-based iterator

=head1 SYNOPSIS

    my $iterator1 = Local::Iterator::File->new(filename => '/tmp/file');

    open(my $fh, '<', '/tmp/file2');
    my $iterator2 = Local::Iterator::File->new(fh => $fh);

=cut

extends 'Local::Iterator';

has 'fh', is => 'rw', required => 1;		
has 'filename', is => 'rw';
	
sub BUILDARGS {
	my ($class, %hash) = @_;
	if(defined $hash{filename}) {
		open(my $fh, '<', $hash{filename}) or die "Can't open ".@{$hash{filename}}.' '.$!;
		$hash{fh} = $fh;
		$hash{filename} = undef;
	}
	return \%hash;
}

sub next {
	my $self = shift;
	my $l = readline($self->fh) // return (undef, 1);
    chomp $l;
    return ($l, 0);
};

1;
