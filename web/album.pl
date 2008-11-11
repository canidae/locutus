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

my @match_file_track = param('match_file_track');
if (defined @match_file_track) {
	my $force_save = param('save_selected');
	foreach my $value (@match_file_track) {
		my ($file_id, $track_id) = split (/@/, $value);
		$file_id = int($file_id);
		$track_id = int($track_id);
		if ($file_id > 0 && $track_id > 0) {
			my $query = 'UPDATE file SET matched = ' . $track_id;
			$query .= ', force_save = true' if (defined $force_save);
			$query .= ' WHERE file_id = ' . $file_id;
			$dbh->do($query);
		}
	}
}

$vars{album} = $dbh->selectrow_hashref('SELECT * FROM v_web_info_album WHERE album_id = ' . $alid);
$vars{tracks} = $dbh->selectall_arrayref('SELECT * FROM v_web_album_list_tracks_and_matching_files WHERE album_id = ' . $alid . ' ORDER BY tracknumber ASC, mbid_match DESC, meta_score DESC', {Slice => {}});

foreach my $track (@{$vars{tracks}}) {
	$track->{color} = Locutus::score_to_color($track->{meta_score});
	$track->{meta_score} = sprintf("%.1f%%", $track->{meta_score} * 100);
}

Locutus::process_template($page, \%vars);

#print Dumper(\%vars);
