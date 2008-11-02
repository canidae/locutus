#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
use Data::Dumper;

use lib '../include';
use Locutus;

my $page = 'album_matching';
my %vars = ();

my $offset = int(param('offset'));
$offset = 0 if ($offset < 0);
my $filter = param('filter') || '';

my $dbh = Locutus::db_connect();
$filter = $dbh->quote('%' . $filter . '%');

my $query = 'SELECT * FROM v_web_list_album_matching WHERE tracks_matched > 0 AND title ILIKE ' . $filter;
$query = $query . ' ORDER BY tracks - tracks_matched ASC, tracks_matched * avg_score DESC LIMIT 50 OFFSET ' . $offset;

$vars{'albums'} = $dbh->selectall_arrayref($query, {Slice => {}});

foreach my $album (@{$vars{albums}}) {
	$album->{max_color} = Locutus::score_to_color($album->{max_score});
	$album->{min_color} = Locutus::score_to_color($album->{min_score});
	$album->{avg_color} = Locutus::score_to_color($album->{avg_score});
	$album->{max_score} = sprintf("%.1f%%", $album->{max_score} * 100);
	$album->{min_score} = sprintf("%.1f%%", $album->{min_score} * 100);
	$album->{avg_score} = sprintf("%.1f%%", $album->{avg_score} * 100);
}

#print Dumper(\%vars);

Locutus::process_template($page, \%vars);
