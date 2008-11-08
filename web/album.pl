#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'album';
my %vars = ();

my $dbh = Locutus::db_connect();

my $alid = int(param('alid') || -1);

$vars{album} = $dbh->selectrow_hashref('SELECT * FROM v_web_info_album WHERE album_id = ' . $alid);
$vars{tracks} = $dbh->selectall_arrayref('SELECT * FROM v_web_album_list_tracks_and_matching_files WHERE album_id = ' . $alid . ' ORDER BY tracknumber ASC, mbid_match DESC, meta_score DESC', {Slice => {}});

foreach my $track (@{$vars{tracks}}) {
	$track->{color} = Locutus::score_to_color($track->{meta_score});
	$track->{meta_score} = sprintf("%.1f%%", $track->{meta_score} * 100);
}

Locutus::process_template($page, \%vars);

#print Dumper(\%vars);
