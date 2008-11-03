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
	return 'ff0000';
}

sub paginate {
	my ($count,
		 $offset,
		 $limit
		) = @_;

	my $page = !$offset ? 1 : int($offset / $limit) + 1;
	my $max = int($count / $limit) + ($count % $limit > 0 ? 1 : 0);

	if($max == 1) {
		return 0;
	}

	my %data = (prev => $page > 1 ? $page - 1 : 0,
				next => $page < $max ? $page + 1 : 0);
	my @pages = ();

	if($max < 9) {
		for(my $i = 1; $i <= $max; $i++) {
			push(@pages, [$i, $page == $i ? 1 : 0]);
		}
	} elsif ($max > 7) {
		if($page < 3) {
			for (my $i = 1; $i < 6; $i++) {
				push(@pages, [$i, $page == $i ? 1 : 0]);
			}
			push(@pages, 0);
			push(@pages, [$max - 1, 0]);
			push(@pages, [$max, 0]);
		} elsif ($max - 2 > $page && $page > 2) {
			push(@pages, [1, 0]);
			push(@pages, [2, 0]);
			push(@pages, 0);
			for (my $i = $page - 2; $i < $page + 2; $i++) {
				push(@pages, [$i, $page == $i ? 1 : 0]);
			}
			push(@pages, 0);
			push(@pages, [$max - 1, 0]);
			push(@pages, [$max, 0]);
		} else {
			push(@pages, [1, 0]);
			push(@pages, [2, 0]);
			push(@pages, 0);
			for (my $i = $max - 4; $i <= $max; $i++) {
				push(@pages, [$i, $page == $i ? 1 : 0]);
			}
		}
	}

	$data{'data'} = \@pages;
	return \%data;
}

1;
