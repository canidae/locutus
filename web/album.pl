#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'album';
my %vars = ();

my $dbh = Locutus::db_connect();

$vars{'album'} = $dbh->selectrow_hashref('SELECT * FROM v_album_artist WHERE album_id = 1499');
$vars{'tracks'} = $dbh->selectall_arrayref('SELECT * FROM v_track_match_file WHERE album_id = 1499', {Slice => {}});
$vars{'prev_track'} = -1;

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
