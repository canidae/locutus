#include "Matcher.h"

/* constructors */
Matcher::Matcher(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
Matcher::~Matcher() {
}

/* methods */
void Matcher::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(MATCHER_CLASS, MATCHER_CLASS_DESCRIPTION);
	puid_min_score = locutus->settings->loadSetting(setting_class_id, PUID_MIN_SCORE_KEY, PUID_MIN_SCORE_VALUE, PUID_MIN_SCORE_DESCRIPTION);
	metadata_min_score = locutus->settings->loadSetting(setting_class_id, METADATA_MIN_SCORE_KEY, METADATA_MIN_SCORE_VALUE, METADATA_MIN_SCORE_DESCRIPTION);
}

void Matcher::matchFilesToAlbums(vector<Metafile *> *files) {
	/* match tracks to album */
	/* TODO
	 * 1. find best album:
	 *    * match_score = meta_score * (5 if mbid_match, 2 if puid_match, 1 if neither)
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
	/* find best album */
	for (map<string, Album *>::size_type albumtmp = 0; albumtmp < mg.albums.size(); ++albumtmp) {
		for (map<string, Album *>::iterator album = mg.albums.begin(); album != mg.albums.end(); ++album) {
			map<string, Track *> used_files;
			map<int, bool> used_tracks;
			double album_score = 0.0;
			int files_matched = 0;
			/* find best track */
			for (vector<map<string, Match> >::size_type tracktmp = 0; tracktmp < mg.scores[album->first].size(); ++tracktmp) {
				double best_score = 0.0;
				int best_track = -1;
				string best_file = "";
				for (vector<map<string, Match> >::size_type track = 0; track < mg.scores[album->first].size(); ++track) {
					if (used_tracks.find(track) != used_tracks.end())
						continue;
					/* find best file to track */
					for (map<string, Match>::iterator match = mg.scores[album->first][track].begin(); match != mg.scores[album->first][track].end(); ++match) {
						if (used_files.find(match->first) != used_files.end())
							continue;
						if (!match->second.mbid_match && match->second.meta_score < metadata_min_score)
							continue;
						if (!match->second.puid_match && match->second.meta_score < puid_min_score)
							continue;
						double score = match->second.meta_score * (match->second.mbid_match ? 5 : (match->second.puid_match ? 2 : 1));
						if (score > best_score) {
							best_score = score;
							best_track = track;
							best_file = match->first;
						}
					}
				}
				if (best_track != -1) {
					used_files[best_file] = album->second->tracks[best_track];
					used_tracks[best_track] = true;
					album_score += best_score;
					++files_matched;
				}
			}
		}
	}
}

void Matcher::match(string group, vector<Metafile *> *files) {
	/* look up puids first */
	lookupPUIDs(files);
	/* then look up mbids */
	lookupMBIDs(files);
	/* compare all tracks in group with albums loaded so far */
	for (map<string, Album *>::iterator album = mg.albums.begin(); album != mg.albums.end(); ++album)
		compareFilesWithAlbum(album->first, files);
	/* search using metadata */
	searchMetadata(group, files);
	/* and then match the files to albums */
	matchFilesToAlbums(files);
	/* clear data */
	clearMatchGroup();
}

/* private methods */
void Matcher::compareFilesWithAlbum(string mbid, vector<Metafile *> *files) {
	if (mg.albums.find(mbid) == mg.albums.end())
		return;
	Album *album = mg.albums[mbid];
	for (vector<Metafile *>::iterator mf = files->begin(); mf != files->end(); ++mf) {
		for (vector<Track *>::size_type t = 0; t < album->tracks.size(); ++t) {
			if (mg.scores[mbid][t].find((*mf)->filename) != mg.scores[mbid][t].end())
				continue;
			Metatrack mt = album->tracks[t]->getAsMetatrack();
			Match m = (*mf)->compareWithMetatrack(&mt);
			if (!(*mf)->puid_lookup && !(*mf)->mbid_lookup && m.meta_score >= metadata_min_score)
				(*mf)->meta_lookup = false; // so good match that we won't lookup this track using metadata
			mg.scores[mbid][t][(*mf)->filename] = m;
			mt.saveToCache();
			saveMatchToCache((*mf)->filename, mt.track_mbid, m.meta_score);
		}
	}
}

void Matcher::clearMatchGroup() {
	for (map<string, Album *>::iterator album = mg.albums.begin(); album != mg.albums.end(); ++album)
		delete album->second;
	mg.albums.clear();
	mg.scores.clear();
}

string Matcher::escapeWSString(string text) {
	/* escape these characters:
	 * + - && || ! ( ) { } [ ] ^ " ~ * ? : \ */
	/* also change "_" to " " */
	ostringstream str;
	for (string::size_type a = 0; a < text.size(); ++a) {
		switch (text[a]) {
			case '+':
			case '-':
			case '!':
			case '(':
			case ')':
			case '{':
			case '}':
			case '[':
			case ']':
			case '^':
			case '"':
			case '~':
			case '*':
			case '?':
			case ':':
			case '\\':
				str << '\\';
				break;

			case '&':
			case '|':
				if (a + 1 < text.size() && text[a + 1] == text[a])
					str << '\\';
				break;

			case '_':
				text[a] = ' ';
				break;

			default:
				break;
		}
		str << text[a];
	}
	return str.str();
}

bool Matcher::loadAlbum(string mbid) {
	if (mbid.size() != 36)
		return false;
	if (mg.albums.find(mbid) != mg.albums.end())
		return true; // already loaded
	Album *album = new Album(locutus);
	if (!album->loadFromCache(mbid)) {
		if (album->retrieveFromWebService(mbid))
			album->saveToCache();
	}
	if (album->mbid != mbid) {
		/* hmm, didn't find the album? */
		delete album;
		return false;
	}
	mg.albums[mbid] = album;
	mg.scores[mbid].resize((int) album->tracks.size());
	return true;
}

void Matcher::lookupMBIDs(vector<Metafile *> *files) {
	for (vector<Metafile *>::iterator file = files->begin(); file != files->end(); ++file) {
		Metafile *mf = *file;
		if (!mf->mbid_lookup || mf->musicbrainz_albumid.size() != 36 || mg.albums.find(mf->musicbrainz_albumid) != mg.albums.end())
			continue;
		if (loadAlbum(mf->musicbrainz_albumid))
			mf->meta_lookup = false; // shouldn't look up using metadata
	}
}

void Matcher::lookupPUIDs(vector<Metafile *> *files) {
	/* TODO:
	 * we'll need some sort of handling when:
	 * - no matching tracks
	 * - matching tracks, but no good mbid/metadata match */
	for (vector<Metafile *>::iterator file = files->begin(); file != files->end(); ++file) {
		Metafile *mf = *file;
		if (!mf->puid_lookup || mf->puid.size() != 36)
			continue;
		vector<Metatrack> *tracks = locutus->webservice->searchPUID(mf->puid);
		for (vector<Metatrack>::iterator mt = tracks->begin(); mt != tracks->end(); ++mt) {
			/* puid search won't return puid, so let's set it manually */
			mt->puid = mf->puid;
			Match m = mf->compareWithMetatrack(&(*mt));
			mt->saveToCache();
			saveMatchToCache(mf->filename, mt->track_mbid, m.meta_score);
			if (m.meta_score < puid_min_score)
				continue;
			if (!loadAlbum(mt->album_mbid))
				continue;
			int trackcount = (int) mg.albums[mt->album_mbid]->tracks.size();
			if (mt->tracknumber > trackcount || mt->tracknumber <= 0) {
				/* this should never happen */
				locutus->debug(DEBUG_NOTICE, "PUID search returned a tracknumber that doesn't exist on the album. This shouldn't happen, though");
				continue;
			}
			/* since we've already calculated the score, save it */
			mg.scores[mt->album_mbid][mt->tracknumber - 1][mf->filename] = m;
			/* if we found a match using puid we shouldn't look up using metadata */
			mf->meta_lookup = false;
		}
	}
}

string Matcher::makeWSTrackQuery(string group, Metafile *mf) {
	ostringstream query;
	group = escapeWSString(group);
	string bnwe = escapeWSString(mf->getBaseNameWithoutExtension());
	query << "limit=25&query=";
	query << "tnum:(" << escapeWSString(mf->tracknumber) << " " << bnwe << ") ";
	if (mf->duration > 0) {
		int lower = mf->duration / 1000 - 10;
		int upper = mf->duration / 1000 + 10;
		if (lower < 0)
			lower = 0;
		query << "qdur:[" << lower << " TO " << upper << "] ";
	}
	query << "artist:(" << escapeWSString(mf->artist) << " " << bnwe << " " << group << ") ";
	query << "track:(" << escapeWSString(mf->title) << " " << bnwe << " " << ") ";
	query << "release:(" << escapeWSString(mf->album) << " " << bnwe << " " << group << ") ";
	return query.str();
}

bool Matcher::saveMatchToCache(string filename, string track_mbid, double score) {
	if (filename == "" || track_mbid.size() != 36)
		return false;
	string e_filename = locutus->database->escapeString(filename);
	string e_track_mbid = locutus->database->escapeString(track_mbid);
	ostringstream query;
	query << "INSERT INTO metadata_match(file_id, metatrack_id, score) SELECT (SELECT file_id FROM file WHERE filename = '" << e_filename << "'), (SELECT metatrack_id FROM metatrack WHERE track_mbid = '" << e_track_mbid << "'), " << score << " WHERE NOT EXISTS (SELECT true FROM metadata_match WHERE file_id = (SELECT file_id FROM file WHERE filename = '" << e_filename << "') AND metatrack_id = (SELECT metatrack_id FROM metatrack WHERE track_mbid = '" << e_track_mbid << "'))";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save metadata match in cache, query failed. See error above");
	query.str("");
	query << "UPDATE metadata_match SET score = " << score << " WHERE file_id = (SELECT file_id FROM file WHERE filename = '" << e_filename << "') AND metatrack_id = (SELECT metatrack_id FROM metatrack WHERE track_mbid = '" << e_track_mbid << "')";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save metadata match in cache, query failed. See error above");
	return true;
}

void Matcher::searchMetadata(string group, vector<Metafile *> *files) {
	for (vector<Metafile *>::iterator file = files->begin(); file != files->end(); ++file) {
		Metafile *mf = *file;
		if (!mf->meta_lookup)
			continue;
		vector<Metatrack> *tracks = locutus->webservice->searchMetadata(makeWSTrackQuery(group, mf));
		for (vector<Metatrack>::iterator mt = tracks->begin(); mt != tracks->end(); ++mt) {
			Match m = mf->compareWithMetatrack(&(*mt));
			mt->saveToCache();
			saveMatchToCache(mf->filename, mt->track_mbid, m.meta_score);
			if (m.meta_score < metadata_min_score)
				continue;
			if (!loadAlbum(mt->album_mbid))
				continue;
			int trackcount = (int) mg.albums[mt->album_mbid]->tracks.size();
			if (mt->tracknumber > trackcount || mt->tracknumber <= 0) {
				/* this should never happen */
				locutus->debug(DEBUG_NOTICE, "Metadata search returned a tracknumber that doesn't exist on the album. This shouldn't happen, though");
				continue;
			}
			/* since we've already calculated the score, save it */
			mg.scores[mt->album_mbid][mt->tracknumber - 1][mf->filename] = m;
			compareFilesWithAlbum(mt->album_mbid, files);
		}
	}
}
