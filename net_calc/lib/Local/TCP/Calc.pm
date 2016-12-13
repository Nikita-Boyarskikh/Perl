package Local::TCP::Calc;

use strict;
use warnings;

sub TYPE_START_WORK {1}
sub TYPE_CHECK_WORK {2}
sub TYPE_CONN_ERR   {3}
sub TYPE_CONN_OK    {4}

sub STATUS_NEW   {1}
sub STATUS_WORK  {2}
sub STATUS_DONE  {3}
sub STATUS_ERROR {4}

sub pack_message {
	my $pkg = shift;
	my $type = shift;
	my $messages = shift;
	return pack "CCa*", $type, length($messages), $messages;
}

sub unpack_message {
	my $pkg = shift;
	my $bytes = shift;
	return unpack "CCa*", $bytes;
}

1;
