#!/usr/bin/perl
use strict;
use warnings;

use lib '../include';
use Locutus;

my $dbh = Locutus::db_connect();
my $page = 'statistics';
my %vars = ();

$vars{daemon_stats} = $dbh->selectrow_hashref('SELECT active, start, stop, stop - start AS last_run_time, now() - start AS current_run_time, progress, ((now() - start) / coalesce(nullif(progress, 0.0), random())) - (now() - start) AS remaining FROM locutus');
$vars{file_stats} = $dbh->selectrow_hashref('SELECT count(*) AS files, count(DISTINCT track_id) AS matched_files, count(DISTINCT genre) AS genres, sum(duplicate::int) AS duplicates, min(duration) AS min_duration, max(duration) AS max_duration, sum(duration) AS total_duration, min(bitrate) AS min_bitrate, max(bitrate) AS max_bitrate, avg(bitrate) AS avg_bitrate FROM file');
$vars{album_stats} = $dbh->selectrow_hashref('SELECT count(*) AS albums, count(DISTINCT artist_id) AS album_artists FROM album');
$vars{track_stats} = $dbh->selectrow_hashref('SELECT count(*) AS tracks, count(DISTINCT artist_id) AS track_artists, min(duration) AS min_duration, max(duration) AS max_duration, max(tracknumber) AS max_tracknumber FROM track');
$vars{match_stats} = $dbh->selectrow_hashref('SELECT count(*) AS matches, sum(mbid_match::int) AS mbid_matches, min(score) AS min_score, max(score) AS max_score, avg(score) AS avg_score FROM comparison');


Locutus::process_template($page, \%vars);
