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
	/* file -> [Track : score] */
	for (map<string, vector<Metafile *> >::iterator group = locutus->grouped_files.begin(); group != locutus->grouped_files.end(); ++group) {
		map<string, Album> *albums = new map<string, Album>;
		/* <album_mbid, <tracknumber<filename, Match> > > */
		map<string, vector<map<string, Match> > > *scores = new map<string, vector<map<string, Match> > >;
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
				if (score < puid_min_score)
					continue;
				if (loadAlbum(albums, mt->album_mbid)) {
					if (mt->tracknumber > (int) (*albums)[mt->album_mbid].tracks.size() || mt->tracknumber <= 0) {
						/* this should never happen */
						locutus->debug(DEBUG_NOTICE, "PUID search returned a tracknumber that doesn't exist on the album. This shouldn't happen, though");
						continue;
					}
					Match m;
					m.mbid_match = false;
					m.puid_match = true;
					m.meta_score = score;
					(*scores)[mt->album_mbid].resize((*albums)[mt->album_mbid].tracks.size());
					(*scores)[mt->album_mbid][mt->tracknumber - 1][mf->filename] = m;
				}
			}
		}
		/* compare all tracks in group with albums loaded so far */
		for (map<string, Album>::iterator album = albums->begin(); album != albums->end(); ++album)
			compareFilesWithAlbum(scores, &group->second, &album->second);
		/* look up with mbid or search with metadata */
		for (vector<Metafile *>::iterator group_file = group->second.begin(); group_file != group->second.end(); ++group_file) {
			Metafile *mf = *group_file;
			/* mbid lookup */
			/* TODO:
			 * we'll need some sort of handling here too:
			 * - no matching tracks (mbid was deleted from mb) */
			/* meta lookup */
			vector<Metatrack> *tracks = locutus->webservice->searchMetadata(makeWSQuery(group->first, mf));
			for (vector<Metatrack>::iterator mt = tracks->begin(); mt != tracks->end(); ++mt) {
				double score = mf->compareWithMetatrack(&(*mt));
				if (score < metadata_min_score)
					continue;
				if (loadAlbum(albums, mt->album_mbid)) {
					if (mt->tracknumber > (int) (*albums)[mt->album_mbid].tracks.size() || mt->tracknumber <= 0) {
						/* this should never happen */
						locutus->debug(DEBUG_NOTICE, "Metadata search returned a tracknumber that doesn't exist on the album. This shouldn't happen, though");
						continue;
					}
					Match m;
					m.mbid_match = false;
					m.puid_match = false;
					m.meta_score = score;
					(*scores)[mt->album_mbid].resize((*albums)[mt->album_mbid].tracks.size());
					/* compare the other files in group with this album */
					compareFilesWithAlbum(scores, &group->second, &(*albums)[mt->album_mbid]);
				}
			}
		}
		delete albums;
	}
}

/*
void WebFetcher::lookup() {
	for (map<string, vector<int> >::iterator group = locutus->grouped_files.begin(); group != locutus->grouped_files.end(); ++group) {
		map<string, vector<Metadata> > albums;
		map<string, map<vector<Metadata>::size_type, vector<Match> > > matches;
		map<int, bool> track_puid_match;
		for (vector<int>::size_type file_in_group = 0; file_in_group < group->second.size(); ++file_in_group) {
			FileMetadata fm = locutus->files[group->second[file_in_group]];
			string ambid = fm.getValue(MUSICBRAINZ_ALBUMID);
			vector<Metadata> tracks;
			if (fm.puid_lookup) {
				tracks = locutus->webservice->searchPUID(fm.getValue(MUSICIP_PUID));
				if (tracks.size() > 0) {
					track_puid_match[file_in_group] = true;
				} else {
					track_puid_match[file_in_group] = false;
					tracks = locutus->webservice->searchMetadata(makeWSQuery(group->first, fm));
				}
			} else if (ambid != "") {
				tracks = locutus->webservice->fetchAlbum(ambid);
			} else {
				tracks = locutus->webservice->searchMetadata(makeWSQuery(group->first, fm));
			}
			for (vector<Metadata>::size_type track_in_result = 0; track_in_result < tracks.size(); ++track_in_result) {
				Metadata track = tracks[track_in_result];
				double minscore = fm.puid_lookup ? puid_min_score : metadata_min_score;
				if (!fm.equalMBID(track) && fm.compareWithMetadata(track) < minscore)
					continue; // don't load album, not good enough match
				string ambid = track.getValue(MUSICBRAINZ_ALBUMID);
				if (albums.find(ambid) != albums.end())
					continue; // album already loaded
				vector<Metadata> album = locutus->webservice->fetchAlbum(ambid);
				albums[ambid] = album;
				for (vector<FileMetadata>::size_type fig2 = 0; fig2 < group->second.size(); ++fig2) {
					FileMetadata fm2 = locutus->files[group->second[fig2]];
					for (vector<Metadata>::iterator albumtrack = album.begin(); albumtrack != album.end(); ++albumtrack) {
						Match match;
						match.mbid_match = fm2.equalMBID(*albumtrack);
						match.puid_match = fm2.puid_lookup && fm2.getValue(MUSICIP_PUID) == track.getValue(MUSICIP_PUID) && albumtrack->getValue(MUSICBRAINZ_TRACKID) == track.getValue(MUSICBRAINZ_TRACKID);
						match.meta_score = fm2.compareWithMetadata(*albumtrack);
						if (!match.mbid_match && match.meta_score < minscore)
							continue; // too low score
						match.file = fig2;
						matches[ambid][track_in_result].push_back(match);
						ostringstream query;
						query << "INSERT INTO possible_match(file_id, track_id, meta_score, mbid_match, puid_match) SELECT (SELECT file_id FROM file WHERE filename = '";
						query << locutus->database->escapeString(fm2.filename) << "'), (SELECT track_id FROM track WHERE mbid = '";
						query << locutus->database->escapeString(albumtrack->getValue(MUSICBRAINZ_TRACKID)) << "'), ";
						query << match.meta_score << ", ";
						query << (match.mbid_match ? "true" : "false") << ", ";
						query << (match.puid_match ? "true" : "false") << " WHERE NOT EXISTS (SELECT true FROM file f JOIN possible_match pm ON (f.file_id = pm.file_id) JOIN track t ON (pm.track_id = t.track_id) WHERE f.filename = '";
						query << locutus->database->escapeString(fm2.filename) << "' AND t.mbid = '";
						query << locutus->database->escapeString(albumtrack->getValue(MUSICBRAINZ_TRACKID)) << "')";
						locutus->database->query(query.str());
						query.str("");
						query << "UPDATE possible_match SET meta_score = ";
						query << match.meta_score << ", mbid_match = ";
						query << (match.mbid_match ? "true" : "false") << ", puid_match = ";
						query << (match.puid_match ? "true" : "false") << " WHERE file_id = (SELECT file_id FROM file WHERE filename = '";
						query << locutus->database->escapeString(fm2.filename) << "') AND track_id = (SELECT track_id FROM track WHERE mbid = '";
						query << locutus->database->escapeString(albumtrack->getValue(MUSICBRAINZ_TRACKID)) << "')";
						locutus->database->query(query.str());
					}
				}
			}
		}
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
			Match m;
			m.mbid_match = false;
			m.puid_match = false;
			m.meta_score = (*mf)->compareWithTrack(album->tracks[t]);
			(*scores)[album->mbid][t][(*mf)->filename] = m;
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

bool WebFetcher::loadAlbum(map<string, Album> *albums, string mbid) {
	if (mbid.size() != 36)
		return false;
	if (albums->find(mbid) != albums->end())
		return true; // already loaded
	Album album(locutus);
	if (!album.loadFromCache(mbid)) {
		album = locutus->webservice->fetchAlbum(mbid);
		if (album.mbid != "")
			album.saveToCache();
		else
			return false; // couldn't load album
	}
	(*albums)[mbid] = album;
	return true;
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
