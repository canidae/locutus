#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'artists';
my %vars = ();

my $dbh = Locutus::db_connect();

my $offset = int(param('offset'));
$offset = 0 if ($offset < 0);
my $filter = param('filter') || '';
my $query = 'SELECT * FROM v_web_list_artists WHERE name ILIKE ' . $dbh->quote('%' . $filter . '%');
$query = $query . ' ORDER BY sortname LIMIT 25 OFFSET ' . $offset;

$vars{'artists'} = $dbh->selectall_arrayref($query, {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
