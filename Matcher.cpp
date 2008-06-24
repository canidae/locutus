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

void Matcher::match() {
	for (map<string, vector<Metafile *> >::iterator group = locutus->grouped_files.begin(); group != locutus->grouped_files.end(); ++group) {
		/* look up puids first */
		lookupPUIDs(group->second);
		/* then look up mbids */
		lookupMBIDs(group->second);
		/* and finally search using metadata */
		searchMetadata(group->first, group->second);

		/* compare all tracks in group with albums loaded so far */
		for (map<string, Album *>::iterator album = mg.albums.begin(); album != mg.albums.end(); ++album)
			compareFilesWithAlbum(group->second, album->first);
		/* look up with mbid or search with metadata */
		for (vector<Metafile *>::iterator group_file = group->second.begin(); group_file != group->second.end(); ++group_file) {
			Metafile *mf = *group_file;
			/* meta lookup */
			if (mg.best_score.find(mf->filename) != mg.best_score.end() && (mg.best_score[mf->filename].mbid_match || mg.best_score[mf->filename].puid_match || mg.best_score[mf->filename].meta_score > metadata_min_score))
				continue;
			vector<Metatrack> *tracks = locutus->webservice->searchMetadata(makeWSTrackQuery(group->first, mf));
			for (vector<Metatrack>::iterator mt = tracks->begin(); mt != tracks->end(); ++mt) {
				Match m = mf->compareWithMetatrack(*mt);
				mt->saveToCache();
				saveMatchToCache(mf->filename, mt->track_mbid, m.meta_score);
				if (m.meta_score < metadata_min_score)
					continue;
				if (mg.albums.find(mt->album_mbid) == mg.albums.end()) {
					Album *album = new Album(locutus);
					if (!album->loadFromCache(mt->album_mbid)) {
						if (album->retrieveFromWebService(mt->album_mbid))
							album->saveToCache();
					}
					if (album->mbid == "") {
						/* hmm, didn't find the album? */
						delete album;
						continue;
					}
					mg.albums[album->mbid] = album;
				}
				int trackcount = (int) mg.albums[mt->album_mbid]->tracks.size();
				if (mt->tracknumber > trackcount || mt->tracknumber <= 0) {
					/* this should never happen */
					locutus->debug(DEBUG_NOTICE, "Metadata search returned a tracknumber that doesn't exist on the album. This shouldn't happen, though");
					continue;
				}
				if ((int) mg.scores[mt->album_mbid].size() < trackcount)
					mg.scores[mt->album_mbid].resize(trackcount);
				mg.scores[mt->album_mbid][mt->tracknumber - 1][mf->filename] = m;
				setBestScore(mf->filename, m);
				/* compare the other files in group with this album */
				compareFilesWithAlbum(group->second, mt->album_mbid);
			}
		}
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

		/* clear for next group */
		clearMatchGroup();
	}
}

/* private methods */
void Matcher::compareFilesWithAlbum(vector<Metafile *> &files, string album_mbid) {
	if (mg.albums.find(album_mbid) == mg.albums.end())
		return;
	Album *album = mg.albums[album_mbid];
	for (vector<Metafile *>::iterator mf = files.begin(); mf != files.end(); ++mf) {
		for (vector<Track *>::size_type t = 0; t < album->tracks.size(); ++t) {
			if (mg.scores[album_mbid][t].find((*mf)->filename) != mg.scores[album_mbid][t].end())
				continue;
			Metatrack mt = album->tracks[t]->getAsMetatrack();
			Match m = (*mf)->compareWithMetatrack(mt);
			mg.scores[album_mbid][t][(*mf)->filename] = m;
			setBestScore((*mf)->filename, m);
			mt.saveToCache();
			saveMatchToCache((*mf)->filename, mt.track_mbid, m.meta_score);
		}
	}
}

void Matcher::clearMatchGroup() {
	for (map<string, Album *>::iterator album = mg.albums.begin(); album != mg.albums.end(); ++album)
		delete album->second;
	mg.albums.clear();
	mg.best_score.clear();
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

void Matcher::lookupMBIDs(vector<Metafile *> &files) {
	for (vector<Metafile *>::iterator file = files.begin(); file != files.end(); ++file) {
		Metafile *mf = *file;
		if (!mf->mbid_lookup || mf->musicbrainz_albumid.size() != 36 || mg.albums.find(mf->musicbrainz_albumid) != mg.albums.end())
			continue;
		Album *album = new Album(locutus);
		if (!album->loadFromCache(mf->musicbrainz_albumid)) {
			if (album->retrieveFromWebService(mf->musicbrainz_albumid))
				album->saveToCache();
		}
		if (album->mbid == "") {
			/* hmm, didn't find the album? */
			delete album;
			continue;
		}
		mg.albums[album->mbid] = album;
		int trackcount = (int) album->tracks.size();
		if ((int) mg.scores[album->mbid].size() < trackcount)
			mg.scores[album->mbid].resize(trackcount);
	}
}

void Matcher::lookupPUIDs(vector<Metafile *> &files) {
	/* TODO:
	 * we'll need some sort of handling when:
	 * - no matching tracks
	 * - matching tracks, but no good mbid/metadata match */
	for (vector<Metafile *>::iterator file = files.begin(); file != files.end(); ++file) {
		Metafile *mf = *file;
		if (!mf->puid_lookup || mf->puid.size() != 36)
			continue;
		vector<Metatrack> *tracks = locutus->webservice->searchPUID(mf->puid);
		for (vector<Metatrack>::iterator mt = tracks->begin(); mt != tracks->end(); ++mt) {
			/* puid search won't return puid, so let's set it manually */
			mt->puid = mf->puid;
			Match m = mf->compareWithMetatrack(*mt);
			mt->saveToCache();
			saveMatchToCache(mf->filename, mt->track_mbid, m.meta_score);
			if (m.meta_score < puid_min_score)
				continue;
			if (mg.albums.find(mt->album_mbid) == mg.albums.end()) {
				Album *album = new Album(locutus);
				if (!album->loadFromCache(mt->album_mbid)) {
					if (album->retrieveFromWebService(mt->album_mbid))
						album->saveToCache();
				}
				if (album->mbid == "") {
					/* hmm, didn't find the album? */
					delete album;
					continue;
				}
				mg.albums[album->mbid] = album;
			}
			int trackcount = (int) mg.albums[mt->album_mbid]->tracks.size();
			if (mt->tracknumber > trackcount || mt->tracknumber <= 0) {
				/* this should never happen */
				locutus->debug(DEBUG_NOTICE, "PUID search returned a tracknumber that doesn't exist on the album. This shouldn't happen, though");
				continue;
			}
			if ((int) mg.scores[mt->album_mbid].size() < trackcount)
				mg.scores[mt->album_mbid].resize(trackcount);
			mg.scores[mt->album_mbid][mt->tracknumber - 1][mf->filename] = m;
			setBestScore(mf->filename, m);
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

void Matcher::setBestScore(string filename, Match score) {
	if (mg.best_score.find(filename) == mg.best_score.end()) {
		mg.best_score[filename] = score;
		return;
	}
	Match m = mg.best_score[filename];
	if ((m.mbid_match && !score.mbid_match) || (m.mbid_match && score.mbid_match && m.meta_score > score.meta_score))
		return;
	else if ((m.puid_match && !score.puid_match) || (m.puid_match && score.puid_match && m.meta_score > score.meta_score))
		return;
	else if (m.meta_score > score.meta_score)
		return;
	mg.best_score[filename] = score;
}

void Matcher::searchMetadata(string group, vector<Metafile *> &files) {
	for (vector<Metafile *>::iterator file = files.begin(); file != files.end(); ++file) {
		Metafile *mf = *file;
		/* meta lookup */
		if (mg.best_score.find(mf->filename) != mg.best_score.end() && (mg.best_score[mf->filename].mbid_match || mg.best_score[mf->filename].puid_match || mg.best_score[mf->filename].meta_score > metadata_min_score))
			continue;
		vector<Metatrack> *tracks = locutus->webservice->searchMetadata(makeWSTrackQuery(group, mf));
		for (vector<Metatrack>::iterator mt = tracks->begin(); mt != tracks->end(); ++mt) {
			Match m = mf->compareWithMetatrack(*mt);
			mt->saveToCache();
			saveMatchToCache(mf->filename, mt->track_mbid, m.meta_score);
			if (m.meta_score < metadata_min_score)
				continue;
			if (mg.albums.find(mt->album_mbid) == mg.albums.end()) {
				Album *album = new Album(locutus);
				if (!album->loadFromCache(mt->album_mbid)) {
					if (album->retrieveFromWebService(mt->album_mbid))
						album->saveToCache();
				}
				if (album->mbid == "") {
					/* hmm, didn't find the album? */
					delete album;
					continue;
				}
				mg.albums[album->mbid] = album;
			}
			int trackcount = (int) mg.albums[mt->album_mbid]->tracks.size();
			if (mt->tracknumber > trackcount || mt->tracknumber <= 0) {
				/* this should never happen */
				locutus->debug(DEBUG_NOTICE, "Metadata search returned a tracknumber that doesn't exist on the album. This shouldn't happen, though");
				continue;
			}
			if ((int) mg.scores[mt->album_mbid].size() < trackcount)
				mg.scores[mt->album_mbid].resize(trackcount);
			mg.scores[mt->album_mbid][mt->tracknumber - 1][mf->filename] = m;
			setBestScore(mf->filename, m);
		}
	}
}
