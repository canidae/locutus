#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'files';
my %vars = ();

my $dbh = Locutus::db_connect();

$vars{'files'} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_files ORDER BY filename LIMIT 25', {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
