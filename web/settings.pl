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

my $page = 'settings';
my %vars = ();

my $dbh = Locutus::db_connect();

foreach my $key (param()) {
	my $query = 'UPDATE setting SET value = ' . $dbh->quote(param($key)) . ' WHERE key = ' . $dbh->quote($key);
	$dbh->do($query);
}

$vars{'settings'} = $dbh->selectall_arrayref('SELECT * FROM setting ORDER BY key', {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
