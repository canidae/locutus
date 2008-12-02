#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'uncompared';
my %vars = ();

my $offset = int(param('offset'));
$offset = 0 if ($offset < 0);
my $filter = param('filter') || '';

my $dbh = Locutus::db_connect();
$filter = $dbh->quote('%' . $filter . '%');

my $query = 'SELECT * FROM v_web_uncompared_list_files WHERE filename::varchar ILIKE ' . $filter;
$query = $query . ' ORDER by filename LIMIT 50 OFFSET ' . $offset;

$vars{'files'} = $dbh->selectall_arrayref($query, {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
