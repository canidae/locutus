#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'album_matching';
my %vars = ();

my $offset = int(param('offset'));
$offset = 0 if ($offset < 0);
my $filter = param('filter') || '';

my $dbh = Locutus::db_connect();
$filter = $dbh->quote('%' . $filter . '%');

my $query = 'SELECT * FROM v_web_album_matching_list_albums WHERE album ILIKE ' . $filter;
$query .= ' ORDER BY score DESC';
$query .= ' LIMIT 50 OFFSET ' . $offset;
$vars{'albums'} = $dbh->selectall_arrayref($query, {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
