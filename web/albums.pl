#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'albums';
my %vars = ();

my $offset = (int(param('page')) - 1) * 25;
$offset = 0 if ($offset < 0);
my $filter = param('filter') || '';

my $dbh = Locutus::db_connect();
$filter = $dbh->quote('%' . $filter . '%');

my $query = 'SELECT * FROM v_web_list_albums WHERE title ILIKE ' . $filter . ' OR artist_name ILIKE ' . $filter;
$query = $query . ' ORDER BY title LIMIT 25 OFFSET ' . $offset;
$vars{'albums'} = $dbh->selectall_arrayref($query, {Slice => {}});

$query = 'SELECT count(*) FROM v_web_list_albums WHERE title ILIKE ' . $filter . ' OR artist_name ILIKE ' . $filter;
my $count = int($dbh->selectrow_array($query));

$vars{'pagination'} = Locutus::paginate($count, $offset, 25);

#print Dumper(%vars);

Locutus::process_template($page, \%vars);
