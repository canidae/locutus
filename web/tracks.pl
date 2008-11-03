#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $dbh = Locutus::db_connect();
my $limit = 25;
my $page = 'tracks';
my %vars = ();

my $offset = (int(param('page')) - 1) * $limit;
$offset = 0 if ($offset < 0);

my $filter = param('filter') || '';
$filter = $dbh->quote('%' . $filter . '%');

my $query = 'SELECT * FROM v_web_list_tracks WHERE title ILIKE ' . $filter . ' OR artist_name ILIKE ' . $filter;
$query = $query . ' ORDER BY title LIMIT ' . $limit . ' OFFSET ' . $offset;
$vars{'tracks'} = $dbh->selectall_arrayref($query, {Slice => {}});

$query = 'SELECT count(*) FROM v_web_list_tracks WHERE title ILIKE ' . $filter . ' OR artist_name ILIKE ' . $filter;
my $count = int($dbh->selectrow_array($query));
$vars{'pagination'} = Locutus::paginate($count, $offset, $limit);

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
