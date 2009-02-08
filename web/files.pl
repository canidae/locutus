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

my $dbh = Locutus::db_connect();
my $limit = 25;
my $page = 'files';
my %vars = ();

my $offset = (int(param('page')) - 1) * $limit;
$offset = 0 if ($offset < 0);

my $filter = param('filter') || '';
$filter = $dbh->quote('%' . $filter . '%');

my $query = 'SELECT * FROM v_web_list_files WHERE filename::varchar ILIKE ' . $filter;
$query = $query . ' ORDER BY filename LIMIT ' . $limit . ' OFFSET ' . $offset;
$vars{'files'} = $dbh->selectall_arrayref($query, {Slice => {}});

$query = 'SELECT count(*) FROM v_web_list_files WHERE filename::varchar ILIKE ' . $filter;
my $count = int($dbh->selectrow_array($query));
$vars{'pagination'} = Locutus::paginate($count, $offset, $limit);

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
