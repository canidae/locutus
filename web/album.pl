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
$vars{tracks} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_tracks WHERE album_id = ' . $alid . ' ORDER BY tracknumber ASC', {Slice => {}});

foreach my $track (@{$vars{tracks}}) {
	$track->{matches} = $dbh->selectall_arrayref('SELECT * FROM v_web_track_list_matching_files WHERE track_id = ' . $dbh->quote($track->{track_id}) . ' ORDER BY mbid_match DESC, puid_match DESC, meta_score DESC', {Slice => {}});
	foreach my $match (@{$track->{matches}}) {
		$match->{color} = Locutus::score_to_color($match->{meta_score});
		$match->{meta_score} = sprintf("%.1f%%", $match->{meta_score} * 100);
	}
}

Locutus::process_template($page, \%vars);

#print Dumper(\%vars);
