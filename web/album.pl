#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'album';
my %vars = ();

my $dbh = Locutus::db_connect();

my $alid = int(param('alid'));

$vars{'album'} = $dbh->selectrow_hashref('SELECT * FROM v_web_album_info WHERE album_id = ' . $alid);
$vars{'tracks'} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_tracks WHERE album_id = ' . $alid, {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
