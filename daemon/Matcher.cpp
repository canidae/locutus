#include "Album.h"
#include "Comparison.h"
#include "Database.h"
#include "Debug.h"
#include "Levenshtein.h"
#include "Matcher.h"
#include "Metafile.h"
#include "Metatrack.h"
#include "MusicBrainz.h"

using namespace std;

/* constructors/destructor */
Matcher::Matcher(Database *database, MusicBrainz *musicbrainz) : database(database), musicbrainz(musicbrainz) {
	album_weight = database->loadSettingDouble(ALBUM_WEIGHT_KEY, ALBUM_WEIGHT_VALUE, ALBUM_WEIGHT_DESCRIPTION);
	artist_weight = database->loadSettingDouble(ARTIST_WEIGHT_KEY, ARTIST_WEIGHT_VALUE, ARTIST_WEIGHT_DESCRIPTION);
	combine_threshold = database->loadSettingDouble(COMBINE_THRESHOLD_KEY, COMBINE_THRESHOLD_VALUE, COMBINE_THRESHOLD_DESCRIPTION);
	duration_limit = database->loadSettingDouble(DURATION_LIMIT_KEY, DURATION_LIMIT_VALUE, DURATION_LIMIT_DESCRIPTION);
	duration_must_match = database->loadSettingBool(DURATION_MUST_MATCH_KEY, DURATION_MUST_MATCH_VALUE, DURATION_MUST_MATCH_DESCRIPTION);
	duration_weight = database->loadSettingDouble(DURATION_WEIGHT_KEY, DURATION_WEIGHT_VALUE, DURATION_WEIGHT_DESCRIPTION);
	mbid_lookup = database->loadSettingBool(MBID_LOOKUP_KEY, MBID_LOOKUP_VALUE, MBID_LOOKUP_DESCRIPTION);
	max_diff_best_score = database->loadSettingDouble(MAX_DIFF_BEST_SCORE_KEY, MAX_DIFF_BEST_SCORE_VALUE, MAX_DIFF_BEST_SCORE_DESCRIPTION);
	metadata_min_score = database->loadSettingDouble(METADATA_MIN_SCORE_KEY, METADATA_MIN_SCORE_VALUE, METADATA_MIN_SCORE_DESCRIPTION);
	no_group_duplicates = database->loadSettingBool(NO_GROUP_DUPLICATES_KEY, NO_GROUP_DUPLICATES_VALUE, NO_GROUP_DUPLICATES_DESCRIPTION);
	only_save_complete_albums = database->loadSettingBool(ONLY_SAVE_COMPLETE_ALBUMS_KEY, ONLY_SAVE_COMPLETE_ALBUMS_VALUE, ONLY_SAVE_COMPLETE_ALBUMS_DESCRIPTION);
	only_save_if_all_match = database->loadSettingBool(ONLY_SAVE_IF_ALL_MATCH_KEY, ONLY_SAVE_IF_ALL_MATCH_VALUE, ONLY_SAVE_IF_ALL_MATCH_DESCRIPTION);
	puid_lookup = database->loadSettingBool(PUID_LOOKUP_KEY, PUID_LOOKUP_VALUE, PUID_LOOKUP_DESCRIPTION);
	puid_min_score = database->loadSettingDouble(PUID_MIN_SCORE_KEY, PUID_MIN_SCORE_VALUE, PUID_MIN_SCORE_DESCRIPTION);
	title_weight = database->loadSettingDouble(TITLE_WEIGHT_KEY, TITLE_WEIGHT_VALUE, TITLE_WEIGHT_DESCRIPTION);
	tracknumber_weight = database->loadSettingDouble(TRACKNUMBER_WEIGHT_KEY, TRACKNUMBER_WEIGHT_VALUE, TRACKNUMBER_WEIGHT_DESCRIPTION);

	/* if a metadata match score is less than half the metadata_min_score then we won't save the match */
	mismatch_threshold = metadata_min_score / 2.0;
}

Matcher::~Matcher() {
	clearAlbumComparison();
}

/* methods */
void Matcher::match(const string &group, const vector<Metafile *> &files) {
	/* remove matches from database */
	for (vector<Metafile *>::const_iterator f = files.begin(); f != files.end(); ++f)
		database->removeComparisons(**f);
	/* clear data */
	best_file_comparison.clear();
	clearAlbumComparison();
	/* look up puids first */
	lookupPUIDs(files);
	/* then look up mbids */
	lookupMBIDs(files);
	/* compare all tracks in group with albums loaded so far */
	for (map<string, AlbumComparison>::iterator ac = acs.begin(); ac != acs.end(); ++ac)
		compareFilesWithAlbum(&(ac->second), files);
	/* search using metadata */
	searchMetadata(group, files);
	/* and then match the files to albums */
	matchFilesToAlbums(files);
	/* and clear the "values" list in the metafiles */
	for (vector<Metafile *>::const_iterator mf = files.begin(); mf != files.end(); ++mf)
		(*mf)->clearValues();
}

/* private methods */
void Matcher::clearAlbumComparison() {
	for (map<string, AlbumComparison>::iterator ac = acs.begin(); ac != acs.end(); ++ac) {
		for (map<string, vector<Comparison *> >::iterator tc = ac->second.comparisons.begin(); tc != ac->second.comparisons.end(); ++tc) {
			for (vector<Comparison *>::iterator c = tc->second.begin(); c != tc->second.end(); ++c)
				delete *c;
		}
		delete ac->second.album;
	}
	acs.clear();
}

void Matcher::compareFilesWithAlbum(AlbumComparison *ac, const vector<Metafile *> &files) {
	for (vector<Track *>::iterator t = ac->album->tracks.begin(); t != ac->album->tracks.end(); ++t) {
		Metatrack mt = (*t)->getAsMetatrack();
		for (vector<Metafile *>::const_iterator mf = files.begin(); mf != files.end(); ++mf) {
			Comparison *c = compareMetafileWithMetatrack(*mf, mt, *t);
			if (c == NULL)
				continue;
			ac->comparisons[(*t)->mbid].push_back(c);
			if (!c->mbid_match && !c->puid_match && c->score < mismatch_threshold)
				continue; // horrible match, don't save it nor prevent a metadata search for this file
			/* fair or better match. if we're saving complete albums,
			 * then don't do a metadata search for this file */
			if (only_save_complete_albums)
				(*mf)->meta_lookup = false;
			/* save the match */
			database->saveComparison(*c);
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
	Comparison *comparison = new Comparison(metafile, track, (metafile->musicbrainz_trackid != "" && metafile->musicbrainz_trackid == metatrack.track_mbid), (metafile->puid != "" && metafile->puid == metatrack.puid), score);
	map<string, double>::iterator bfm = best_file_comparison.find(metafile->filename);
	if (bfm == best_file_comparison.end() || bfm->second < comparison->total_score)
		best_file_comparison[metafile->filename] = comparison->total_score;
	return comparison;
}

bool Matcher::loadAlbum(const string &mbid, const vector<Metafile *> files) {
	if (mbid.size() != 36)
		return false;
	if (acs.find(mbid) != acs.end())
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
	acs[mbid].album = album;
	/* when we load an album we'll match the files with it */
	compareFilesWithAlbum(&acs[mbid], files);
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

void Matcher::lookupPUIDs(const vector<Metafile *> &files) {
	/* TODO:
	 * we'll need some sort of handling when:
	 * - no matching tracks
	 * - matching tracks, but no good mbid/metadata match */
	for (vector<Metafile *>::const_iterator file = files.begin(); file != files.end(); ++file) {
		Metafile *mf = *file;
		if (!puid_lookup || mf->puid.size() != 36)
			continue;
		vector<Metatrack> tracks = musicbrainz->searchPUID(mf->puid);
		string load_album_title = "";
		for (vector<Metatrack>::iterator mt = tracks.begin(); mt != tracks.end(); ++mt) {
			/* puid search won't return puid, so let's set it manually */
			mt->puid = mf->puid;
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

void Matcher::matchFilesToAlbums(const vector<Metafile *> &files) {
	/* well, this method is a total mess :(
	 *
	 * this is what it's supposed to do:
	 * 1. find best album:
	 *    * match_score = score * (3 if mbid_match, 2 if puid_match, 1 if neither)
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
	for (map<string, AlbumComparison>::iterator actmp = acs.begin(); actmp != acs.end(); ++actmp) {
		best_album_files.clear();
		double best_album_score = -1.0;
		for (map<string, AlbumComparison>::iterator ac = acs.begin(); ac != acs.end(); ++ac) {
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
					if (no_group_duplicates && used_tracks.find(t->first) != used_tracks.end())
						continue;
					/* find best file */
					for (vector<Comparison *>::iterator c = t->second.begin(); c != t->second.end(); ++c) {
						if ((*c)->metafile->force_save && (*c)->mbid_match) {
							/* user demands that this file is saved, even if it means
							 * that we won't satisfy the settings */
							(*c)->metafile->setMetadata((*c)->track);
							/* no "continue" here, or we won't get "complete album" or
							 * "complete group" which may keep other files from being
							 * saved */
						}
						if (used_files.find((*c)->metafile->filename) != used_files.end() || save_files.find((*c)->metafile->filename) != save_files.end())
							continue; // file already used
						else if ((*c)->total_score <= best_comparison_score)
							continue; // already found a better match
						else if (!(*c)->mbid_match && (*c)->puid_match && (*c)->score < puid_min_score)
							continue; // puid compare with too low score
						else if (!(*c)->mbid_match && !(*c)->puid_match && (*c)->score < metadata_min_score)
							continue; // metadata compare with too low score
						map<string, double>::iterator bfc = best_file_comparison.find((*c)->metafile->filename);
						if (!(*c)->mbid_match && !(*c)->puid_match && bfc != best_file_comparison.end() && bfc->second - (*c)->total_score > max_diff_best_score)
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
			if (tracks_matched == 0 || (only_save_complete_albums && tracks_matched != (int) ac->second.album->tracks.size()))
				continue;
			album_score *= (double) tracks_matched / (double) ac->second.album->tracks.size();
			cout << "Album: " << ac->second.album->title << " | Score: " << album_score << " | Tracks: " << ac->second.album->tracks.size() << " | Matched: " << tracks_matched << " | Group: " << files.size() << endl;
			if (album_score > best_album_score) {
				best_album_score = album_score;
				best_album_files = album_files;
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
		sf->second->metafile->setMetadata(sf->second->track);
}

void Matcher::searchMetadata(const string &group, const vector<Metafile *> &files) {
	for (vector<Metafile *>::const_iterator file = files.begin(); file != files.end(); ++file) {
		Metafile *mf = *file;
		if (!mf->meta_lookup)
			continue;
		vector<Metatrack> tracks = musicbrainz->searchMetadata(group, *mf);
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
