use strict;
use warnings;

use DBI;
use Template;

package Locutus;

sub db_connect {
	my $dbh = DBI->connect("dbi:Pg:dbname=locutus;host=sql.samfundet.no", "locutus", "locutus") || die "Couldn't connect to database: " . DBI::errstr();
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

sub score_to_color {
	my $score = shift;
	if ($score > 0.75) {
		return sprintf("%02x%02x00", (1.0 - ($score - 0.75) * 4) * 255, 255);
	} elsif ($score > 0.25) {
		return sprintf("%02x%02x00", 255, (($score - 0.25) * 2) * 255);
	}
	return '#ff0000';
}

1;
