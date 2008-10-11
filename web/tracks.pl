#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'tracks';
my %vars = ();

my $dbh = Locutus::db_connect();

$vars{'tracks'} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_tracks ORDER BY title LIMIT 25', {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
