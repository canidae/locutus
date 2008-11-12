#include "Album.h"
#include "Database.h"
#include "Debug.h"
#include "Levenshtein.h"
#include "Match.h"
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
	clearAlbumMatch();
}

/* methods */
void Matcher::match(const string &group, const vector<Metafile *> &files) {
	/* clear data */
	best_file_match.clear();
	clearAlbumMatch();
	/* look up puids first */
	lookupPUIDs(files);
	/* then look up mbids */
	lookupMBIDs(files);
	/* compare all tracks in group with albums loaded so far */
	for (map<string, AlbumMatch>::iterator am = ams.begin(); am != ams.end(); ++am)
		compareFilesWithAlbum(&(am->second), files);
	/* search using metadata */
	searchMetadata(group, files);
	/* and then match the files to albums */
	matchFilesToAlbums(files);
	/* and clear the "values" list in the metafiles */
	for (vector<Metafile *>::const_iterator mf = files.begin(); mf != files.end(); ++mf)
		(*mf)->clearValues();
}

/* private methods */
void Matcher::clearAlbumMatch() {
	for (map<string, AlbumMatch>::iterator am = ams.begin(); am != ams.end(); ++am) {
		for (map<string, vector<Match *> >::iterator tm = am->second.matches.begin(); tm != am->second.matches.end(); ++tm) {
			for (vector<Match *>::iterator m = tm->second.begin(); m != tm->second.end(); ++m)
				delete *m;
		}
		delete am->second.album;
	}
	ams.clear();
}

void Matcher::compareFilesWithAlbum(AlbumMatch *am, const vector<Metafile *> &files) {
	for (vector<Track *>::iterator t = am->album->tracks.begin(); t != am->album->tracks.end(); ++t) {
		Metatrack mt = (*t)->getAsMetatrack();
		for (vector<Metafile *>::const_iterator mf = files.begin(); mf != files.end(); ++mf) {
			Match *m = compareMetafileWithMetatrack(*mf, mt, *t);
			if (m == NULL)
				continue;
			am->matches[(*t)->mbid].push_back(m);
			if (!m->mbid_match && !m->puid_match && m->meta_score < mismatch_threshold)
				continue; // horrible match, don't save it nor prevent a metadata search for this file
			/* fair or better match. don't do a metadata search for this file and save the match */
			(*mf)->meta_lookup = false;
			database->saveMatch(*m);
		}
	}
}

Match *Matcher::compareMetafileWithMetatrack(Metafile *metafile, const Metatrack &metatrack, Track *track) {
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
	double meta_score = scores[0][0] * album_weight;
	meta_score += scores[1][0] * artist_weight;
	meta_score += scores[2][0] * title_weight;
	meta_score += scores[3][0] * tracknumber_weight;
	int durationdiff = abs(metatrack.duration - metafile->duration);
	if (durationdiff < duration_limit)
		meta_score += (1.0 - durationdiff / duration_limit) * duration_weight;
	meta_score /= album_weight + artist_weight + title_weight + tracknumber_weight + duration_weight;
	Match *match = new Match(metafile, track, (metafile->musicbrainz_trackid != "" && metafile->musicbrainz_trackid == metatrack.track_mbid), (metafile->puid != "" && metafile->puid == metatrack.puid), meta_score);
	map<string, double>::iterator bfm = best_file_match.find(metafile->filename);
	if (bfm == best_file_match.end() || bfm->second < match->total_score)
		best_file_match[metafile->filename] = match->total_score;
	return match;
}

bool Matcher::loadAlbum(const string &mbid, const vector<Metafile *> files) {
	if (mbid.size() != 36)
		return false;
	if (ams.find(mbid) != ams.end())
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
	ams[mbid].album = album;
	/* when we load an album we'll match the files with it */
	compareFilesWithAlbum(&ams[mbid], files);
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
		for (vector<Metatrack>::iterator mt = tracks.begin(); mt != tracks.end(); ++mt) {
			/* puid search won't return puid, so let's set it manually */
			mt->puid = mf->puid;
			Match *m = compareMetafileWithMetatrack(mf, *mt);
			if (m == NULL)
				continue;
			/* check that score is high enough for us to load this album */
			if (m->meta_score >= puid_min_score)
				loadAlbum(mt->album_mbid, files);
			delete m;
		}
	}
}

void Matcher::matchFilesToAlbums(const vector<Metafile *> &files) {
	/* well, this method is a total mess :(
	 *
	 * this is what it's supposed to do:
	 * 1. find best album:
	 *    * match_score = meta_score * (3 if mbid_match, 2 if puid_match, 1 if neither)
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
	map<string, Match *> save_files;
	map<string, bool> used_albums;
	map<string, bool> used_files;
	map<string, bool> used_tracks;
	vector<Match *> album_files;
	vector<Match *> best_album_files;
	/* find best album */
	for (map<string, AlbumMatch>::iterator amtmp = ams.begin(); amtmp != ams.end(); ++amtmp) {
		best_album_files.clear();
		double best_album_score = -1.0;
		for (map<string, AlbumMatch>::iterator am = ams.begin(); am != ams.end(); ++am) {
			if (used_albums.find(am->first) != used_albums.end())
				continue;
			used_files.clear();
			used_tracks.clear();
			int tracks_matched = 0;
			double album_score = 0.0;
			album_files.clear();
			/* find best track */
			while (true) {
				Match *best_match = NULL;
				double best_match_score = -1.0;
				for (map<string, vector<Match *> >::iterator t = am->second.matches.begin(); t != am->second.matches.end(); ++t) {
					if (no_group_duplicates && used_tracks.find(t->first) != used_tracks.end())
						continue;
					/* find best file */
					for (vector<Match *>::iterator m = t->second.begin(); m != t->second.end(); ++m) {
						if ((*m)->metafile->force_save && (*m)->mbid_match) {
							/* user demands that this file is saved, even if it means
							 * that we won't satisfy the settings */
							(*m)->metafile->setMetadata((*m)->track);
							/* no "continue" here, or we won't get "complete album" or
							 * "complete group" which may keep other files from being
							 * saved */
						}
						if (used_files.find((*m)->metafile->filename) != used_files.end() || save_files.find((*m)->metafile->filename) != save_files.end())
							continue; // file already used
						else if ((*m)->total_score <= best_match_score)
							continue; // already found a better match
						else if (!(*m)->mbid_match && (*m)->puid_match && (*m)->meta_score < puid_min_score)
							continue; // puid compare with too low meta_score
						else if (!(*m)->mbid_match && !(*m)->puid_match && (*m)->meta_score < metadata_min_score)
							continue; // metadata compare with too low meta_score
						map<string, double>::iterator bfm = best_file_match.find((*m)->metafile->filename);
						if (bfm != best_file_match.end() && bfm->second - (*m)->total_score > max_diff_best_score)
							continue; // total_score is too far away from this file's best total_score
						best_match = *m;
						best_match_score = (*m)->total_score;
					}
				}
				if (best_match == NULL)
					break;
				used_files[best_match->metafile->filename] = true;
				if (used_tracks.find(best_match->track->mbid) == used_tracks.end()) {
					used_tracks[best_match->track->mbid] = true;
					++tracks_matched;
					album_score += best_match_score;
				}
				album_files.push_back(best_match);
			}
			if (tracks_matched == 0 || (only_save_complete_albums && tracks_matched != (int) am->second.album->tracks.size()))
				continue;
			album_score *= (double) tracks_matched / (double) am->second.album->tracks.size();
			cout << "Album: " << am->second.album->title << " | Score: " << album_score << " | Matched: " << tracks_matched << " | Files: " << am->second.album->tracks.size() << " | Group: " << files.size() << endl;
			if (album_score > best_album_score) {
				best_album_score = album_score;
				best_album_files = album_files;
			}
		}
		if (best_album_files.size() <= 0)
			continue;
		for (vector<Match *>::iterator match = best_album_files.begin(); match != best_album_files.end(); ++match)
			save_files[(*match)->metafile->filename] = *match;
	}
	if (save_files.size() <= 0 || (only_save_if_all_match && (int) save_files.size() != (int) files.size()))
		return;
	/* set new metadata */
	for (map<string, Match *>::iterator sf = save_files.begin(); sf != save_files.end(); ++sf)
		sf->second->metafile->setMetadata(sf->second->track);
}

void Matcher::searchMetadata(const string &group, const vector<Metafile *> &files) {
	for (vector<Metafile *>::const_iterator file = files.begin(); file != files.end(); ++file) {
		Metafile *mf = *file;
		if (!mf->meta_lookup)
			continue;
		vector<Metatrack> tracks = musicbrainz->searchMetadata(group, *mf);
		for (vector<Metatrack>::iterator mt = tracks.begin(); mt != tracks.end(); ++mt) {
			Match *m = compareMetafileWithMetatrack(mf, *mt);
			if (m == NULL)
				continue;
			/* check that score is high enough for us to load this album */
			if (m->meta_score >= metadata_min_score)
				loadAlbum(mt->album_mbid, files);
			delete m;
		}
	}
}
