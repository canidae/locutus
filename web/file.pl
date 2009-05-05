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

my $page = 'file';
my %vars = ();

my $dbh = Locutus::db_connect();

my $fiid = int(param('fiid') || -1);

if (defined param('save_metadata') && $fiid >= 0) {
	# save user modified metadata
	my $artist = $dbh->quote(param('artist')) || "";
	my $album = $dbh->quote(param('album')) || "";
	my $albumartist = $dbh->quote(param('albumartist')) || "";
	my $title = $dbh->quote(param('title')) || "";
	my $tracknumber = $dbh->quote(param('tracknumber')) || "";
	my $musicbrainz_albumid = $dbh->quote(param('musicbrainz_albumid')) || "";
	my $musicbrainz_trackid = $dbh->quote(param('musicbrainz_trackid')) || "";
	my $query = 'UPDATE file SET album = ' . $album . ', albumartist = ' . $albumartist . ', artist = ' . $artist . ', musicbrainz_albumid = ' . $musicbrainz_albumid . ', musicbrainz_trackid = ' . $musicbrainz_trackid . ', title = ' . $title . ', tracknumber = ' . $tracknumber . ', track_id = NULL, user_changed = true WHERE file_id = ' . $fiid;
	$dbh->do($query);
}

$vars{file} = $dbh->selectrow_hashref('SELECT * FROM v_web_info_file WHERE file_id = ' . $fiid);
$vars{matches} = $dbh->selectall_arrayref('SELECT * FROM v_web_file_list_matching_tracks WHERE file_id = ' . $fiid . ' ORDER BY mbid_match DESC, score DESC', {Slice => {}});

foreach my $match (@{$vars{matches}}) {
	$match->{color} = Locutus::score_to_color($match->{score});
	$match->{score} = sprintf("%.1f%%", $match->{score} * 100);
}

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
