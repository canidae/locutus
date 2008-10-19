#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'file';
my %vars = ();

my $dbh = Locutus::db_connect();

my $fiid = int(param('fiid') || -1);

if (defined param('save_metadata') && $fiid >= 0) {
	# save user modified metadata
	my $artist = param('artist') || "";
	my $album = param('album') || "";
	my $albumartist = param('albumartist') || "";
	my $title = param('title') || "";
	my $tracknumber = param('tracknumber') || "";
	my $musicbrainz_albumid = param('musicbrainz_albumid') || "";
	my $musicbrainz_trackid = param('musicbrainz_trackid') || "";
	my $query = 'UPDATE file SET album=' . $dbh->quote($album) . ', albumartist=' . $dbh->quote($albumartist) . ', artist=' . $dbh->quote($artist) . ', musicbrainz_albumid=' . $dbh->quote($musicbrainz_albumid) . ', musicbrainz_trackid=' . $dbh->quote($musicbrainz_trackid) . ', title=' . $dbh->quote($title) . ', tracknumber=' . $dbh->quote($tracknumber) . ' WHERE file_id=' . $fiid;
	$dbh->do($query);
} elsif (defined param('use_selected') && $fiid >= 0) {
	# some magic needed here
}

$vars{file} = $dbh->selectrow_hashref('SELECT * FROM v_web_info_file WHERE file_id = ' . $fiid);
$vars{matches} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_matches WHERE file_file_id = ' . $fiid . ' ORDER BY mbid_match DESC, puid_match DESC, meta_score DESC', {Slice => {}});

foreach my $match (@{$vars{matches}}) {
	$match->{color} = Locutus::score_to_color($match->{meta_score});
	$match->{meta_score} = sprintf("%.1f%%", $match->{meta_score} * 100);
}

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
