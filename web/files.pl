#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);

use lib '../include';
use Locutus;

my $page = 'files';
my %vars = ();

my $dbh = Locutus::db_connect();

my $offset = int(param('offset'));
$offset = 0 if ($offset < 0);

my $only_unmatched = int(param('list_unmatched_only'));
my $select_view = 'v_web_list_files';
$select_view = 'v_web_list_unmatched_files' if ($only_unmatched == 1);

my $filter = param('filter') || '';
$filter = ' WHERE filename ILIKE ' . $dbh->quote('%' . $filter . '%') unless ($filter eq '');

$vars{'files'} = $dbh->selectall_arrayref('SELECT * FROM ' . $select_view . $filter . ' ORDER BY filename LIMIT 25 OFFSET ' . $offset, {Slice => {}});

Locutus::process_template($page, \%vars);
