#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'settings';
my %vars = ();

my $dbh = Locutus::db_connect();

$vars{'settings'} = $dbh->selectall_arrayref('SELECT * FROM setting', {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
