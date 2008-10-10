#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'artist';
my %vars = ();

my $dbh = Locutus::db_connect();

my $arid = int(param('arid'));

$vars{'artist'} = $dbh->selectrow_hashref('SELECT * FROM artist WHERE artist_id = ' . $arid, {Slice => {}});
$vars{'albums'} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_albums WHERE artist_id = ' . $arid, {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
