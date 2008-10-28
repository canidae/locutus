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
my $only_unmatched = int(param('list_unmatched_only') || 0);
my $filter = param('filter') || '';

my $query = 'SELECT * FROM v_web_list_files WHERE filename ILIKE ' . $dbh->quote('%' . $filter . '%');
# TODO: status (list_unmatched_only)
#$query = $query . ' AND (no_album_match = true OR group_not_matched = true OR too_low_score = true)' if ($only_unmatched == 1);
$query = $query . ' ORDER BY filename LIMIT 25 OFFSET ' . $offset;

$vars{'files'} = $dbh->selectall_arrayref($query, {Slice => {}});

Locutus::process_template($page, \%vars);
