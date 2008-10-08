#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'artists';
my %vars = ();

my $dbh = Locutus::db_connect();

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
