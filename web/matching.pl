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

my $page = 'matching';
my %vars = ();

my $offset = int(param('offset'));
$offset = 0 if ($offset < 0);
my $filter = param('filter') || '';

my $dbh = Locutus::db_connect();
$filter = $dbh->quote('%' . $filter . '%');

my $query = 'SELECT * FROM v_web_matching_list_albums WHERE album ILIKE ' . $filter;
$query .= ' ORDER BY tracks_compared * avg_score DESC';
$query .= ' LIMIT 50 OFFSET ' . $offset;
$vars{'albums'} = $dbh->selectall_arrayref($query, {Slice => {}});

foreach my $album (@{$vars{albums}}) {
	$album->{max_color} = Locutus::score_to_color($album->{max_score});
	$album->{max_score} = sprintf("%.1f%%", $album->{max_score} * 100);
	$album->{avg_color} = Locutus::score_to_color($album->{avg_score});
	$album->{avg_score} = sprintf("%.1f%%", $album->{avg_score} * 100);
	$album->{min_color} = Locutus::score_to_color($album->{min_score});
	$album->{min_score} = sprintf("%.1f%%", $album->{min_score} * 100);
}


Locutus::process_template($page, \%vars);

#print Dumper(\%vars);
