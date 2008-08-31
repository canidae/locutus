use strict;
use warnings;

use DBI;
use Template;

package Locutus;

sub db_connect {
	my $dbh = DBI->connect("dbi:Pg:dbname=locutus;host=localhost", "locutus", "locutus") || die "Couldn't connect to database: " . DBI::errstr();
	return $dbh;
}

sub process_template {
	my ($page, $vars) = @_;

	my $template = Template->new({
			INCLUDE_PATH => '../templates'
		});
	print "Content-type: text/html\n\n";
	$template->process($page . ".tmpl", $vars) || die "Template process failed: ", $template->error(), "\n";
}

1;
