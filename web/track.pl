#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'track';
my %vars = ();

my $dbh = Locutus::db_connect();

my $trid = int(param('trid'));

$vars{'track'} = $dbh->selectrow_hashref('SELECT * FROM v_web_info_track WHERE track_id = ' . $trid);
#$vars{'files'} = $dbh->selectall_arrayref('SELECT * FROM v_web_list_tracks WHERE album_id = ' . $trid . ' ORDER BY tracknumber ASC', {Slice => {}});

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
