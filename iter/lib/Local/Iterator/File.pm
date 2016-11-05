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

has 'fh', is => 'rw',
	trigger => sub {
		my $self = shift;
		while (not eof $self->fh) {
			chomp(my $line = readline($self->fh));
			push(@{$self->array}, $line);
		}
	};
		
has 'filename', is => 'rw',
	trigger => sub {
		my $self = shift;
		open(my $fh, '<', $self->filename) or die $!;
		$self->fh($fh);
	};

1;
