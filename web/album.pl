#!/usr/bin/perl
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
# 
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

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
my $figrid = int(param('figrid') || -1);

my @match_file_track = param('match_file_track');
if (@match_file_track) {
	my $force_save = param('force_save');
	foreach my $value (@match_file_track) {
		my ($file_id, $track_id) = split (/@/, $value);
		$file_id = int($file_id);
		$track_id = int($track_id);
		if ($file_id > 0 && $track_id > 0) {
			my $query = 'UPDATE file SET track_id = ' . $track_id;
			$query .= ', force_save = true' if (defined $force_save && $force_save eq "force_save");
			$query .= ' WHERE file_id = ' . $file_id;
			$dbh->do($query);
		}
	}
}

my @remove_file_track = param('remove_file_track');
if (@remove_file_track) {
	foreach my $value (@remove_file_track) {
		my ($file_id, $track_id) = split (/@/, $value);
		$file_id = int($file_id);
		$track_id = int($track_id);
		if ($file_id > 0 && $track_id > 0) {
			my $query = 'DELETE FROM comparison WHERE file_id = ' . $file_id;
			$query .= ' AND track_id = ' . $track_id;
			$dbh->do($query);
		}
	}
}

$vars{album} = $dbh->selectrow_hashref('SELECT * FROM v_web_info_album WHERE album_id = ' . $alid);
$vars{similar_albums} = $dbh->selectall_arrayref('SELECT album_id, title AS album, (SELECT count(*) FROM track t WHERE t.album_id = a.album_id) AS tracks FROM album a WHERE album_id != ' . $alid . ' AND album_id IN (SELECT album_id FROM album WHERE artist_id = (SELECT artist_id FROM album WHERE album_id = ' . $alid . ' AND title = a.title)) ORDER BY tracks, album_id', {Slice => {}});
my $query = 'SELECT * FROM v_web_album_list_tracks_and_matching_files WHERE album_id = ' . $alid;
$query .= ' AND groupname = (SELECT groupname FROM file WHERE file_id = ' . $figrid . ')' if ($figrid > -1);
$query .= ' ORDER BY tracknumber ASC, mbid_match DESC, score DESC';
$vars{tracks} = $dbh->selectall_arrayref($query, {Slice => {}});

foreach my $track (@{$vars{tracks}}) {
	$vars{groups}->{$track->{groupname}} = $track->{file_id} if ($track->{groupname} ne '');
	$track->{color} = Locutus::score_to_color($track->{score});
	$track->{score} = sprintf("%.1f%%", $track->{score} * 100);
	my $durdiff = abs($track->{duration} - $track->{file_duration});
	if ($durdiff < 15000) {
		$track->{duration_color} = Locutus::score_to_color(1.0 - $durdiff / 15000);
	} else {
		$track->{duration_color} = Locutus::score_to_color(0.0);
	}
}

Locutus::process_template($page, \%vars);

#print Dumper(\%vars);
