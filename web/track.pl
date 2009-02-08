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

use lib '../include';
use Locutus;

my $page = 'track';
my %vars = ();

my $dbh = Locutus::db_connect();

my $trid = int(param('trid'));

$vars{track} = $dbh->selectrow_hashref('SELECT * FROM v_web_info_track WHERE track_id = ' . $trid);
$vars{matches} = $dbh->selectall_arrayref('SELECT * FROM v_web_track_list_matching_files WHERE track_id = \'' . $trid . '\' ORDER BY mbid_match DESC, puid_match DESC, score DESC', {Slice => {}});

foreach my $match (@{$vars{matches}}) {
	$match->{color} = Locutus::score_to_color($match->{score});
	$match->{score} = sprintf("%.1f%%", $match->{score} * 100);
}

Locutus::process_template($page, \%vars);
