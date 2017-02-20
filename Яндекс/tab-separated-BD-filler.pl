use strict;
use warnings;
use DBI;

my $db_driver = "mysql";
my $db_name = "database";
my $host = "localhost";
my $port = "3306";
my $user = "root";
my $password = "passwd";
my $table_name = "banners";
my $dsn = sprintf("DBI:%s:%s;host=%s:%d", $db_driver, $db_name, $host, $port);

open F, $ARGV[0] or die $!;

my $dbh = DBI->connect(
	$dsn,
	$user,
	$password,
	{ AutoCommit => 0, RaiseError => 1 }
);

my $sth = $dbh->prepare(
	"INSERT INTO $table_name (banner_id, title, url) VALUES (?, ?, ?)"
);

while (<F>) {
	chomp;
	my ($banner_id, $title, $url) = split /\t/;
	$sth->execute($banner_id, $title, $url);
}

close F;
$dbh->commit;
$dbh->disconnect;