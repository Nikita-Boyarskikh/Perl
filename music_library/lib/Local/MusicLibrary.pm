package Local::MusicLibrary;

use strict;
use warnings;
BEGIN {if($]<5.018){package experimental; use warnings::register;}} no warnings 'experimental';

use Local::MusicLibrary::OptionTools;
use Local::MusicLibrary::Paint;

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

    Local::MusicLibrary->setopt(...); # Output options
    
    Local::MusicLibrary->add_data(...); # Adds new record to our library
    Local::MusicLibrary->print();       # Print table of all records in our library

=cut

my @table = ();
my %options;

sub setopt {
	(my $self, %options) = @_;
}

sub print() {
	my @name = Local::MusicLibrary::OptionTools->prepare_option_columns ($options{columns});
	@table = Local::MusicLibrary::OptionTools->sort_table ($options{sort}, @table);
	my $result = Local::MusicLibrary::OptionTools->prepare_result ({options => {%options}, table => [@table], name => @name});
	Local::MusicLibrary::Paint->paint($result);
}

sub add_data($) {
	my ($self, $data) = @_;
	$data =~ /^\.\/(?<band>[^\n\/]+)\/(?<year>\d+) \- (?<album>[^\n\/]+)\/(?<track>[^\n\/]+)\.(?<format>\w+)$/;
	my %record = (band => $+{band}, year => $+{year}, album => $+{album}, track => $+{track}, format => $+{format});
	if (defined $record{band} && defined $record{year} && defined $record{album} &&
		defined $record{track} && defined $record{format}) {
			push @table, \%record;
	} else {
			warn "Wrong format";
	}
}

1;
