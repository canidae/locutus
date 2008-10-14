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

my $alid = int(param('alid'));

$vars{album} = $dbh->selectrow_hashref('SELECT * FROM v_web_info_album WHERE album_id = ' . $alid);
$vars{tracks} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_tracks WHERE album_id = ' . $alid . ' ORDER BY tracknumber ASC', {Slice => {}});

foreach my $track (@{$vars{tracks}}) {
	$track->{files} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_matches WHERE metatrack_track_mbid = ' . $dbh->quote($track->{mbid}) . ' ORDER BY mbid_match DESC, puid_match DESC, meta_score DESC', {Slice => {}});
}

Locutus::process_template($page, \%vars);

#print Dumper(\%vars);
