#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);

use lib '../include';
use Locutus;

my $page = 'track';
my %vars = ();

my $dbh = Locutus::db_connect();

my $trid = int(param('trid'));

$vars{track} = $dbh->selectrow_hashref('SELECT * FROM v_web_info_track WHERE track_id = ' . $trid);
my $track_mbid = $vars{track}{mbid};
$vars{matches} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_matches WHERE metatrack_track_mbid = \'' . $track_mbid . '\' ORDER BY mbid_match DESC, puid_match DESC, meta_score DESC', {Slice => {}});

foreach my $match (@{$vars{matches}}) {
	$match->{color} = Locutus::score_to_color($match->{meta_score});
	$match->{meta_score} = sprintf("%.1f%%", $match->{meta_score} * 100);
}

Locutus::process_template($page, \%vars);
