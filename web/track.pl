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
$vars{matches} = $dbh->selectall_arrayref('SELECT * FROM v_web_track_list_matching_files WHERE track_id = \'' . $trid . '\' ORDER BY mbid_match DESC, puid_match DESC, meta_score DESC', {Slice => {}});

foreach my $match (@{$vars{matches}}) {
	$match->{color} = Locutus::score_to_color($match->{meta_score});
	$match->{meta_score} = sprintf("%.1f%%", $match->{meta_score} * 100);
}

Locutus::process_template($page, \%vars);
