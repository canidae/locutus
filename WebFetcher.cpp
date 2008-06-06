#include "WebFetcher.h"

/* constructors */
WebFetcher::WebFetcher(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
WebFetcher::~WebFetcher() {
}

/* methods */
void WebFetcher::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEREADER_CLASS, FILEREADER_CLASS_DESCRIPTION);
	puid_min_score = locutus->settings->loadSetting(setting_class_id, PUID_MIN_SCORE_KEY, PUID_MIN_SCORE_VALUE, PUID_MIN_SCORE_DESCRIPTION);
	metadata_min_score = locutus->settings->loadSetting(setting_class_id, METADATA_MIN_SCORE_KEY, METADATA_MIN_SCORE_VALUE, METADATA_MIN_SCORE_DESCRIPTION);
}

void WebFetcher::lookup() {
	for (map<string, vector<Metafile *> >::iterator group = locutus->grouped_files.begin(); group != locutus->grouped_files.end(); ++group) {
		map<string, Album *> albums;
		/* <album_mbid, <tracknumber<filename, Match> > > */
		map<string, vector<map<string, Match> > > scores;
		/* look up puids first */
		/* TODO:
		 * we'll need some sort of handling when:
		 * - no matching tracks
		 * - matching tracks, but no good mbid/metadata match */
		for (vector<Metafile *>::iterator group_file = group->second.begin(); group_file != group->second.end(); ++group_file) {
			Metafile *mf = *group_file;
			if (!mf->puid_lookup)
				continue;
			vector<Metatrack> *tracks = locutus->webservice->searchPUID(mf->puid);
			for (vector<Metatrack>::iterator mt = tracks->begin(); mt != tracks->end(); ++mt) {
				double score = mf->compareWithMetatrack(&(*mt));
				mt->saveToCache();
				saveMatchToCache(mf->filename, mt->track_mbid, score);
				if (score < puid_min_score)
					continue;
				if (albums.find(mt->album_mbid) == albums.end()) {
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
					albums[album->mbid] = album;
				}
				int trackcount = (int) albums[mt->album_mbid]->tracks.size();
				if (mt->tracknumber > trackcount || mt->tracknumber <= 0) {
					/* this should never happen */
					locutus->debug(DEBUG_NOTICE, "PUID search returned a tracknumber that doesn't exist on the album. This shouldn't happen, though");
					continue;
				}
				Match m;
				m.mbid_match = false;
				m.puid_match = true;
				m.meta_score = score;
				if ((int) scores[mt->album_mbid].size() < trackcount)
					scores[mt->album_mbid].resize(trackcount);
				scores[mt->album_mbid][mt->tracknumber - 1][mf->filename] = m;
			}
		}
		/* compare all tracks in group with albums loaded so far */
		for (map<string, Album *>::iterator album = albums.begin(); album != albums.end(); ++album)
			compareFilesWithAlbum(&scores, &group->second, album->second);
		/* look up with mbid or search with metadata */
		for (vector<Metafile *>::iterator group_file = group->second.begin(); group_file != group->second.end(); ++group_file) {
			Metafile *mf = *group_file;
			/* mbid lookup */
			if (mf->musicbrainz_albumid.size() == 36 && albums.find(mf->musicbrainz_albumid) == albums.end()) {
				Album *album = new Album(locutus);
				if (!album->loadFromCache(mf->musicbrainz_albumid)) {
					if (album->retrieveFromWebService(mf->musicbrainz_albumid))
						album->saveToCache();
				}
				if (album->mbid == "") {
					/* hmm, didn't find the album? */
					delete album;
				} else {
					albums[album->mbid] = album;
					/* compare the other files in group with this album */
					int trackcount = (int) album->tracks.size();
					if ((int) scores[album->mbid].size() < trackcount)
						scores[album->mbid].resize(trackcount);
					compareFilesWithAlbum(&scores, &group->second, album);
					continue;
				}
			}
			/* meta lookup */
			vector<Metatrack> *tracks = locutus->webservice->searchMetadata(makeWSQuery(group->first, mf));
			for (vector<Metatrack>::iterator mt = tracks->begin(); mt != tracks->end(); ++mt) {
				double score = mf->compareWithMetatrack(&(*mt));
				mt->saveToCache();
				saveMatchToCache(mf->filename, mt->track_mbid, score);
				if (score < metadata_min_score)
					continue;
				if (albums.find(mt->album_mbid) == albums.end()) {
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
					albums[album->mbid] = album;
				}
				int trackcount = (int) albums[mt->album_mbid]->tracks.size();
				if (mt->tracknumber > trackcount || mt->tracknumber <= 0) {
					/* this should never happen */
					locutus->debug(DEBUG_NOTICE, "Metadata search returned a tracknumber that doesn't exist on the album. This shouldn't happen, though");
					continue;
				}
				Match m;
				m.mbid_match = false;
				m.puid_match = false;
				m.meta_score = score;
				if ((int) scores[mt->album_mbid].size() < trackcount)
					scores[mt->album_mbid].resize(trackcount);
				scores[mt->album_mbid][mt->tracknumber - 1][mf->filename] = m;
				/* compare the other files in group with this album */
				compareFilesWithAlbum(&scores, &group->second, albums[mt->album_mbid]);
			}
		}
		/* match tracks to album */
		/* TODO
		 * ideas?
		 * - always save if a group perfectly match an album (no duplicates, no files left, album is filled)?
		 *   * there are several problems that must be adressed. what if all files except 1 match album "a"
		 *     using puid while the last track doesn't match the same album using puid, but rather match
		 *     another album?
		 *     same goes for mbid.
		 * - optionally save if a group match multiple albums perfectly?
		 *   * this is ~essentially the same as above, though. probably safe to merge them
		 * - optionally save if all files match one (or more) albums, but don't fill the album(s) up?
		 *   * we'll need some intelligent way to make sure files are "gathered" on as few albums as possible
		 * - optionally save if some of the files match an album, but not all?
		 */
		/* clear for next group */
		for (map<string, Album *>::iterator album = albums.begin(); album != albums.end(); ++album)
			delete album->second;
		albums.clear();
		scores.clear();
	}
}

/*
void WebFetcher::lookup() {
	for (map<string, vector<int> >::iterator group = locutus->grouped_files.begin(); group != locutus->grouped_files.end(); ++group) {
		map<string, double> album_scores;
		map<string, vector<AlbumMatch> > album_matched;
		for (map<string, map<vector<Metadata>::size_type, vector<Match> > >::iterator album = matches.begin(); album != matches.end(); ++album) {
			AlbumMatch tmp;
			tmp.file = -1;
			tmp.score = 0.0;
			vector<AlbumMatch> matched(group->second.size(), tmp);
			double album_score = 0.0;
			int matched_tracks = 0;
			for (map<vector<Metadata>::size_type, vector<Match> >::iterator tc = album->second.begin(); tc != album->second.end(); ++tc) {
				int best_file = -1;
				int best_track = -1;
				double best_score = 0.0;
				for (map<vector<Metadata>::size_type, vector<Match> >::size_type t = 0; t < album->second.size(); ++t) {
					for (vector<Match>::iterator match = album->second[t].begin(); match != album->second[t].begin(); ++match) {
						if (matched[t].file != -1)
							continue;
						FileMetadata fm = locutus->files[group->second[match->file]];
						double score = 0.0;
						if (fm.puid_lookup && track_puid_match[match->file])
							score = 2.0 + match->meta_score;
						else if (match->mbid_match)
							score = 1.0 + match->meta_score;
						else
							score = match->meta_score;
						if (score > best_score) {
							best_file = match->file;
							best_track = t;
							best_score = score;
						}
					}
				}
				if (best_track != -1) {
					++matched_tracks;
					matched[best_track].file = best_file;
					matched[best_track].score = best_score;
					album_score += best_score;
				}
			}
			if (matched_tracks == (int) group->second.size())
				album_score *= 3;
			else if (matched_tracks == (int) album->second.size())
				album_score *= 2;
			album_scores[album->first] = album_score / album->second.size();
			album_matched[album->first] = matched;
		}
		vector<bool> used_files(group->second.size(), false);
		for (map<string, vector<Metadata> >::iterator album = albums.begin(); album != albums.end(); ++album) {
			double max = -1.0;
			string key = "";
			for (map<string, double>::iterator as = album_scores.begin(); as != album_scores.end(); ++as) {
				if (as->second > max) {
					key = as->first;
					max = as->second;
				}
			}
			if (key == "")
				break;
			for (vector<Metadata>::size_type track = 0; track < album->second.size(); ++track) {
				AlbumMatch am = album_matched[key][track];
				if (am.file == -1 || used_files[am.file])
					continue;
				FileMetadata fm = locutus->files[am.file];
				fm.setValues(albums[key][track]);
				locutus->files[am.file] = fm;
				used_files[am.file] = true;
			}
		}
	}
}
*/

/* private methods */
void WebFetcher::compareFilesWithAlbum(map<string, vector<map<string, Match> > > *scores, vector<Metafile *> *files, Album *album) {
	for (vector<Metafile *>::iterator mf = files->begin(); mf != files->end(); ++mf) {
		for (vector<Track *>::size_type t = 0; t < album->tracks.size(); ++t) {
			if ((*scores)[album->mbid][t].find((*mf)->filename) != (*scores)[album->mbid][t].end())
				continue;
			Metatrack mt = album->tracks[t]->getAsMetatrack();
			Match m;
			if (mt.track_mbid == (*mf)->musicbrainz_trackid)
				m.mbid_match = true;
			else
				m.mbid_match = false;
			m.puid_match = false;
			m.meta_score = (*mf)->compareWithMetatrack(&mt);
			(*scores)[mt.album_mbid][t][(*mf)->filename] = m;
			mt.saveToCache();
			saveMatchToCache((*mf)->filename, mt.track_mbid, m.meta_score);
		}
	}
}

string WebFetcher::escapeWSString(string text) {
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

string WebFetcher::makeWSQuery(string group, Metafile *mf) {
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
	query << "track:(" << escapeWSString(mf->title) << " " << bnwe << " " << group << ") ";
	query << "release:(" << escapeWSString(mf->album) << " " << bnwe << " " << group << ") ";
	return query.str();
}

bool WebFetcher::saveMatchToCache(string filename, string track_mbid, double score) {
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
