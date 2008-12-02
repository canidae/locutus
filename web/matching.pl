#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'matching';
my %vars = ();

my $offset = int(param('offset'));
$offset = 0 if ($offset < 0);
my $filter = param('filter') || '';

my $dbh = Locutus::db_connect();
$filter = $dbh->quote('%' . $filter . '%');

my $query = 'SELECT * FROM v_web_matching_list_albums WHERE album ILIKE ' . $filter;
$query .= ' ORDER BY tracks * min_track_score DESC';
$query .= ' LIMIT 50 OFFSET ' . $offset;
$vars{'albums'} = $dbh->selectall_arrayref($query, {Slice => {}});

foreach my $album (@{$vars{albums}}) {
	$album->{min_track_color} = Locutus::score_to_color($album->{min_track_score});
	$album->{min_track_score} = sprintf("%.1f%%", $album->{min_track_score} * 100);
	$album->{avg_track_color} = Locutus::score_to_color($album->{avg_track_score});
	$album->{avg_track_score} = sprintf("%.1f%%", $album->{avg_track_score} * 100);
	$album->{max_track_color} = Locutus::score_to_color($album->{max_track_score});
	$album->{max_track_score} = sprintf("%.1f%%", $album->{max_track_score} * 100);
}


Locutus::process_template($page, \%vars);

#print Dumper(\%vars);
