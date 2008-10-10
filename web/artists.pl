#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'artists';
my %vars = ();

my $dbh = Locutus::db_connect();

$vars{'artists'} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_artists ORDER BY sortname LIMIT 25', {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
