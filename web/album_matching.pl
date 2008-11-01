#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'album_matching';
my %vars = ();

my $dbh = Locutus::db_connect();

$vars{'albums'} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_album_matching WHERE matched > 0 ORDER BY matched DESC, tracks ASC, mbid_matches DESC, avg_score ASC', {Slice => {}});

foreach my $album (@{$vars{albums}}) {
	$album->{max_color} = Locutus::score_to_color($album->{max_score});
	$album->{min_color} = Locutus::score_to_color($album->{min_score});
	$album->{avg_color} = Locutus::score_to_color($album->{avg_score});
	$album->{max_score} = sprintf("%.1f%%", $album->{max_score} * 100);
	$album->{min_score} = sprintf("%.1f%%", $album->{min_score} * 100);
	$album->{avg_score} = sprintf("%.1f%%", $album->{avg_score} * 100);
}

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
