#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'files';
my %vars = ();

my $dbh = Locutus::db_connect();

$vars{'file'} = $dbh->selectrow_hashref('SELECT * FROM file WHERE file_id = 333');
$vars{'metatracks'} = $dbh->selectall_arrayref('SELECT * FROM v_match_metatrack WHERE file_id = 333', {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
