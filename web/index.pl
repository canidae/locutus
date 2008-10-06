#!/usr/bin/perl
use strict;
use warnings;

use lib '../include';
use Locutus;

my $page = 'statistics';
my %vars = ();

my $dbh = Locutus::db_connect();

Locutus::process_template($page, \%vars);
