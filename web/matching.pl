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
$query .= ' ORDER BY tracks_compared * avg_score DESC';
$query .= ' LIMIT 50 OFFSET ' . $offset;
$vars{'albums'} = $dbh->selectall_arrayref($query, {Slice => {}});

foreach my $album (@{$vars{albums}}) {
	$album->{max_color} = Locutus::score_to_color($album->{max_score});
	$album->{max_score} = sprintf("%.1f%%", $album->{max_score} * 100);
	$album->{avg_color} = Locutus::score_to_color($album->{avg_score});
	$album->{avg_score} = sprintf("%.1f%%", $album->{avg_score} * 100);
	$album->{min_color} = Locutus::score_to_color($album->{min_score});
	$album->{min_score} = sprintf("%.1f%%", $album->{min_score} * 100);
}


Locutus::process_template($page, \%vars);

#print Dumper(\%vars);
