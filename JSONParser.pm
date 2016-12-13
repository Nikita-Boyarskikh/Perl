package Local::JSONParser;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

sub parse_json {
	my $source = shift;
	my $numer = '"(?<!\\)([^\\]*)"';
	$source =~ s/[^\"]*(\:)/ \=\>/g;
	$source =~ s/\\u\{(.*)?\}/\\x\g{-1}/gc;
#	use JSON::XS;
	
#	return JSON::XS->new->utf8->decode($source);
	return eval $source;
}

1;
