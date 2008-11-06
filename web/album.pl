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

my $matches = $dbh->selectall_hashref('SELECT DISTINCT ON (file_id) * FROM v_web_track_list_matching_files WHERE track_id IN (SELECT track_id FROM track WHERE album_id = ' . $alid . ') ORDER BY file_id, mbid_match DESC, meta_score DESC', [qw(track_id file_id)]);

foreach my $track (@{$vars{tracks}}) {
	while ((my $file, my $match) = each (%{$matches->{$track->{track_id}}})) {
		$match->{color} = Locutus::score_to_color($match->{meta_score});
		$match->{meta_score} = sprintf("%.1f%%", $match->{meta_score} * 100);
		push (@{$track->{matches}}, $match);
	}
}

Locutus::process_template($page, \%vars);

#print Dumper(\%vars);
