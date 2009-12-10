// Copyright © 2008-2009 Vidar Wahlberg <canidae@exent.net>
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

#include <stdlib.h>
#include "Album.h"
#include "Comparison.h"
#include "Database.h"
#include "Levenshtein.h"
#include "Matcher.h"
#include "Metafile.h"
#include "Metatrack.h"
#include "MusicBrainz.h"
#include "Track.h"

using namespace std;

Matcher::Matcher(Database *database, MusicBrainz *musicbrainz) : database(database), musicbrainz(musicbrainz) {
	album_weight = database->loadSettingDouble(ALBUM_WEIGHT_KEY, ALBUM_WEIGHT_VALUE, ALBUM_WEIGHT_DESCRIPTION);
	if (album_weight < 0.0)
		album_weight = 0.0;
	artist_weight = database->loadSettingDouble(ARTIST_WEIGHT_KEY, ARTIST_WEIGHT_VALUE, ARTIST_WEIGHT_DESCRIPTION);
	if (artist_weight < 0.0)
		artist_weight = 0.0;
	combine_threshold = database->loadSettingDouble(COMBINE_THRESHOLD_KEY, COMBINE_THRESHOLD_VALUE, COMBINE_THRESHOLD_DESCRIPTION);
	if (combine_threshold < 0.0)
		combine_threshold = 0.0;
	else if (combine_threshold > 1.0)
		combine_threshold = 1.0;
	duration_limit = database->loadSettingDouble(DURATION_LIMIT_KEY, DURATION_LIMIT_VALUE, DURATION_LIMIT_DESCRIPTION);
	if (duration_limit < 0.0)
		duration_limit = 0.0;
	duration_must_match = database->loadSettingBool(DURATION_MUST_MATCH_KEY, DURATION_MUST_MATCH_VALUE, DURATION_MUST_MATCH_DESCRIPTION);
	duration_weight = database->loadSettingDouble(DURATION_WEIGHT_KEY, DURATION_WEIGHT_VALUE, DURATION_WEIGHT_DESCRIPTION);
	if (duration_weight < 0.0)
		duration_weight = 0.0;
	mbid_lookup = database->loadSettingBool(LOOKUP_MBID_KEY, LOOKUP_MBID_VALUE, LOOKUP_MBID_DESCRIPTION);
	max_diff_best_score = database->loadSettingDouble(MAX_DIFF_BEST_SCORE_KEY, MAX_DIFF_BEST_SCORE_VALUE, MAX_DIFF_BEST_SCORE_DESCRIPTION);
	if (max_diff_best_score < 0.0)
		max_diff_best_score = 0.0;
	else if (max_diff_best_score > 1.0)
		max_diff_best_score = 1.0;
	match_min_score = database->loadSettingDouble(MATCH_MIN_SCORE_KEY, MATCH_MIN_SCORE_VALUE, MATCH_MIN_SCORE_DESCRIPTION);
	if (match_min_score < 0.0)
		match_min_score = 0.0;
	else if (match_min_score > 1.0)
		match_min_score = 1.0;
	compare_relative_score = database->loadSettingDouble(COMPARE_RELATIVE_SCORE_KEY, COMPARE_RELATIVE_SCORE_VALUE, COMPARE_RELATIVE_SCORE_DESCRIPTION);
	if (compare_relative_score < 0.0)
		compare_relative_score = 0.0;
	else if (compare_relative_score > 1.0)
		compare_relative_score = 1.0;
	allow_group_duplicates = database->loadSettingBool(ALLOW_GROUP_DUPLICATES_KEY, ALLOW_GROUP_DUPLICATES_VALUE, ALLOW_GROUP_DUPLICATES_DESCRIPTION);
	only_save_complete_albums = database->loadSettingBool(ONLY_SAVE_COMPLETE_ALBUMS_KEY, ONLY_SAVE_COMPLETE_ALBUMS_VALUE, ONLY_SAVE_COMPLETE_ALBUMS_DESCRIPTION);
	only_save_if_all_match = database->loadSettingBool(ONLY_SAVE_IF_ALL_MATCH_KEY, ONLY_SAVE_IF_ALL_MATCH_VALUE, ONLY_SAVE_IF_ALL_MATCH_DESCRIPTION);
	title_weight = database->loadSettingDouble(TITLE_WEIGHT_KEY, TITLE_WEIGHT_VALUE, TITLE_WEIGHT_DESCRIPTION);
	if (title_weight < 0.0)
		title_weight = 0.0;
	tracknumber_weight = database->loadSettingDouble(TRACKNUMBER_WEIGHT_KEY, TRACKNUMBER_WEIGHT_VALUE, TRACKNUMBER_WEIGHT_DESCRIPTION);
	if (tracknumber_weight < 0.0)
		tracknumber_weight = 0.0;

	/* if a metadata match score is less than match_min_score * compare_relative_score then we won't save the match */
	mismatch_threshold = match_min_score * compare_relative_score;

	/* set acs to NULL */
	acs = NULL;
}

Matcher::~Matcher() {
	clearAlbumComparison();
}

vector<string> Matcher::getLoadedAlbums() {
	/* return all the albums loaded for this group */
	vector<string> albums;
	for (map<string, AlbumComparison>::iterator ac = acs->begin(); ac != acs->end(); ++ac)
		albums.push_back(ac->first);
	return albums;
}

void Matcher::match(const vector<Metafile *> &files, const string &album) {
	/* remove matches from database */
	for (vector<Metafile *>::const_iterator f = files.begin(); f != files.end(); ++f)
		database->removeComparisons(**f);
	/* clear data */
	best_file_comparison.clear();
	clearAlbumComparison();
	acs = new map<string, AlbumComparison>();
	/* if album is set, load only that album */
	if (album != "") {
		loadAlbum(album, files);
	} else {
		/* look up mbids */
		lookupMBIDs(files);
		/* search using metadata */
		searchMetadata(files);
	}
	/* and then match the files to albums */
	matchFilesToAlbums(files);
	/* and clear the "values" list in the metafiles */
	for (vector<Metafile *>::const_iterator mf = files.begin(); mf != files.end(); ++mf)
		(*mf)->clearValues();
	/* save comparisons for files that aren't matched */
	for (map<string, AlbumComparison>::iterator ac = acs->begin(); ac != acs->end(); ++ac) {
		for (map<string, vector<Comparison *> >::iterator cs = ac->second.comparisons.begin(); cs != ac->second.comparisons.end(); ++cs) {
			for (vector<Comparison *>::iterator c = cs->second.begin(); c != cs->second.end(); ++c) {
				if ((*c)->metafile->matched)
					continue; // file is matched, don't save comparison
				/* save the match */
				database->saveComparison(**c);
			}
		}
	}
}

void Matcher::clearAlbumComparison() {
	if (acs == NULL)
		return;
	for (map<string, AlbumComparison>::iterator ac = acs->begin(); ac != acs->end(); ++ac) {
		for (map<string, vector<Comparison *> >::iterator tc = ac->second.comparisons.begin(); tc != ac->second.comparisons.end(); ++tc) {
			for (vector<Comparison *>::iterator c = tc->second.begin(); c != tc->second.end(); ++c)
				delete *c;
		}
		delete ac->second.album;
	}
	delete acs;
}

void Matcher::compareFilesWithAlbum(AlbumComparison *ac, const vector<Metafile *> &files) {
	for (vector<Track *>::iterator t = ac->album->tracks.begin(); t != ac->album->tracks.end(); ++t) {
		Metatrack mt = (*t)->getAsMetatrack();
		for (vector<Metafile *>::const_iterator mf = files.begin(); mf != files.end(); ++mf) {
			Comparison *c = compareMetafileWithMetatrack(*mf, mt, *t);
			if (c == NULL)
				continue;
			if (!c->mbid_match && c->score < mismatch_threshold) {
				/* horrible match, don't save it nor prevent a metadata search for this file */
				delete c;
				continue;
			}
			/* fair or better match. if we're saving complete albums,
			 * then don't do a metadata search for this file */
			ac->comparisons[(*t)->mbid].push_back(c);
			if (only_save_complete_albums)
				(*mf)->meta_lookup = false;
		}
	}
}

Comparison *Matcher::compareMetafileWithMetatrack(Metafile *metafile, const Metatrack &metatrack, Track *track) {
	if (duration_must_match && abs(metafile->duration - metatrack.duration) > duration_limit)
		return NULL;
	list<string> values = metafile->getValues(combine_threshold);
	if (values.size() <= 0)
		return NULL;
	/* find highest score */
	bool used_row[4];
	for (int a = 0; a < 4; ++a)
		used_row[a] = false;
	bool used_col[(int) values.size()];
	double scores[4][values.size()];
	int pos = 0;
	for (list<string>::iterator v = values.begin(); v != values.end(); ++v) {
		used_col[pos] = false;
		scores[0][pos] = Levenshtein::similarity(*v, metatrack.album_title);
		scores[1][pos] = Levenshtein::similarity(*v, metatrack.artist_name);
		scores[2][pos] = Levenshtein::similarity(*v, metatrack.track_title);
		scores[3][pos] = (atoi(v->c_str()) == metatrack.tracknumber) ? 1.0 : 0.0;
		++pos;
	}
	for (int a = 0; a < 4; ++a) {
		int best_row = -1;
		list<string>::size_type best_col = -1;
		double best_score = -1.0;
		for (int r = 0; r < 4; ++r) {
			if (used_row[r])
				continue;
			for (list<string>::size_type c = 0; c < values.size(); ++c) {
				if (used_col[c])
					continue;
				if (scores[r][c] > best_score) {
					best_row = r;
					best_col = c;
					best_score = scores[r][c];
				}
			}
		}
		if (best_row >= 0) {
			scores[best_row][0] = best_score;
			used_row[best_row] = true;
			used_col[best_col] = true;
		} else {
			break;
		}
	}
	double score = scores[0][0] * album_weight;
	score += scores[1][0] * artist_weight;
	score += scores[2][0] * title_weight;
	score += scores[3][0] * tracknumber_weight;
	int durationdiff = abs(metatrack.duration - metafile->duration);
	if (durationdiff < duration_limit)
		score += (1.0 - durationdiff / duration_limit) * duration_weight;
	score /= album_weight + artist_weight + title_weight + tracknumber_weight + duration_weight;
	Comparison *comparison = new Comparison(metafile, track, (metafile->musicbrainz_trackid != "" && metafile->musicbrainz_trackid == metatrack.track_mbid), score);
	map<string, double>::iterator bfm = best_file_comparison.find(metafile->filename);
	if (bfm == best_file_comparison.end() || bfm->second < comparison->total_score)
		best_file_comparison[metafile->filename] = comparison->total_score;
	return comparison;
}

bool Matcher::loadAlbum(const string &mbid, const vector<Metafile *> files) {
	if (mbid.size() != 36)
		return false;
	map<string, AlbumComparison>::iterator ac = acs->find(mbid);
	if (ac != acs->end())
		return true; // already loaded
	Album *album = new Album(mbid);
	if (!database->loadAlbum(album)) {
		if (musicbrainz->lookupAlbum(album)) {
			database->saveAlbum(*album);
		} else {
			/* hmm, didn't find the album? */
			delete album;
			return false;
		}
	}
	(*acs)[mbid].album = album;
	/* when we load an album we'll match the files with it */
	compareFilesWithAlbum(&(*acs)[mbid], files);
	return true;
}

void Matcher::lookupMBIDs(const vector<Metafile *> &files) {
	for (vector<Metafile *>::const_iterator file = files.begin(); file != files.end(); ++file) {
		Metafile *mf = *file;
		if (!mbid_lookup || mf->musicbrainz_albumid.size() != 36)
			continue;
		loadAlbum(mf->musicbrainz_albumid, files);
	}
}

void Matcher::matchFilesToAlbums(const vector<Metafile *> &files) {
	/* well, this method is a total mess :(
	 *
	 * this is what it's supposed to do:
	 * 1. find best album:
	 *    * match_score = score * (3 if mbid_match, 1 if metadata match)
	 *    * album_score = matches/tracks * match_score
	 * 2. make files matched unavailable for matching with next album
	 * 3. goto 1
	 *
	 * notes:
	 * - add "only save if all files in group match something" setting
	 * - add "only save complete albums" setting
	 *   * best album must be complete, it's not enough with any album being complete.
	 *     this because there often are singles with same tracks as an album
	 */
	map<string, Comparison *> save_files;
	map<string, bool> used_albums;
	map<string, bool> used_files;
	map<string, bool> used_tracks;
	vector<Comparison *> album_files;
	vector<Comparison *> best_album_files;
	/* find best album */
	for (map<string, AlbumComparison>::iterator actmp = acs->begin(); actmp != acs->end(); ++actmp) {
		best_album_files.clear();
		double best_album_score = -1.0;
		for (map<string, AlbumComparison>::iterator ac = acs->begin(); ac != acs->end(); ++ac) {
			if (used_albums.find(ac->first) != used_albums.end())
				continue;
			used_files.clear();
			used_tracks.clear();
			int tracks_matched = 0;
			double album_score = 0.0;
			album_files.clear();
			/* find best track */
			while (true) {
				Comparison *best_comparison = NULL;
				double best_comparison_score = -1.0;
				for (map<string, vector<Comparison *> >::iterator t = ac->second.comparisons.begin(); t != ac->second.comparisons.end(); ++t) {
					if (!allow_group_duplicates && used_tracks.find(t->first) != used_tracks.end())
						continue;
					/* find best file */
					for (vector<Comparison *>::iterator c = t->second.begin(); c != t->second.end(); ++c) {
						if ((*c)->metafile->matched && (*c)->mbid_match) {
							/* track is already matched, set/update metadata */
							(*c)->metafile->setMetadata(*((*c)->track));
							/* no "continue" here, or we won't get "complete album" or
							 * "complete group" which may keep other files from being
							 * saved */
						}
						if (used_files.find((*c)->metafile->filename) != used_files.end() || save_files.find((*c)->metafile->filename) != save_files.end())
							continue; // file already used
						else if ((*c)->total_score <= best_comparison_score)
							continue; // already found a better match
						else if (!(*c)->mbid_match && (*c)->score < match_min_score)
							continue; // metadata compare with too low score
						map<string, double>::iterator bfc = best_file_comparison.find((*c)->metafile->filename);
						if (!(*c)->mbid_match && bfc != best_file_comparison.end() && bfc->second - (*c)->total_score > max_diff_best_score)
							continue; // total_score is too far away from this file's best total_score
						best_comparison = *c;
						best_comparison_score = (*c)->total_score;
					}
				}
				if (best_comparison == NULL)
					break;
				used_files[best_comparison->metafile->filename] = true;
				if (used_tracks.find(best_comparison->track->mbid) == used_tracks.end()) {
					used_tracks[best_comparison->track->mbid] = true;
					++tracks_matched;
					album_score += best_comparison_score;
				}
				album_files.push_back(best_comparison);
			}
			album_score *= (double) tracks_matched / (double) ac->second.album->tracks.size();
			if (album_score > best_album_score) {
				best_album_score = album_score;
				if (!only_save_complete_albums || tracks_matched == (int) ac->second.album->tracks.size())
					best_album_files = album_files;
				else
					best_album_files.clear();
			}
		}
		if (best_album_files.size() <= 0)
			continue;
		for (vector<Comparison *>::iterator save = best_album_files.begin(); save != best_album_files.end(); ++save)
			save_files[(*save)->metafile->filename] = *save;
	}
	if (save_files.size() <= 0 || (only_save_if_all_match && (int) save_files.size() != (int) files.size()))
		return;
	/* set new metadata */
	for (map<string, Comparison *>::iterator sf = save_files.begin(); sf != save_files.end(); ++sf)
		sf->second->metafile->setMetadata(*(sf->second->track));
}

void Matcher::searchMetadata(const vector<Metafile *> &files) {
	for (vector<Metafile *>::const_iterator file = files.begin(); file != files.end(); ++file) {
		Metafile *mf = *file;
		if (!mf->meta_lookup)
			continue;
		vector<Metatrack> tracks = musicbrainz->searchMetadata(*mf);
		string load_album_title = "";
		for (vector<Metatrack>::iterator mt = tracks.begin(); mt != tracks.end(); ++mt) {
			Comparison *c = compareMetafileWithMetatrack(mf, *mt);
			if (c == NULL)
				continue;
			/* check that score is high enough for us to load this album
			 * and that we've not loaded any albums or this album got the
			 * same name as the first album we loaded */
			if (c->score >= mismatch_threshold && (load_album_title == "" || load_album_title == mt->album_title)) {
				loadAlbum(mt->album_mbid, files);
				/* set load_album_title.
				 * we'll load albums of the same name because it's quite
				 * common that an album is released multiple times with
				 * different track count. if we load an album with too
				 * few tracks then the album won't be saved */
				load_album_title = mt->album_title;
			}
			delete c;
		}
	}
}
