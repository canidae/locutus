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
	for (map<string, vector<int> >::iterator group = locutus->grouped_files.begin(); group != locutus->grouped_files.end(); ++group) {
		map<string, vector<Metadata> > albums;
		map<string, map<vector<Metadata>::size_type, vector<Match> > > matches;
		map<int, bool> track_puid_match;
		for (vector<int>::size_type file_in_group = 0; file_in_group < group->second.size(); ++file_in_group) {
			FileMetadata fm = locutus->files[group->second[file_in_group]];
			string ambid = fm.getValue(MUSICBRAINZ_ALBUMID);
			vector<Metadata> tracks;
			if (fm.puid_lookup) {
				/* puid lookup */
				tracks = locutus->webservice->searchPUID(fm.getValue(MUSICIP_PUID));
				if (tracks.size() > 0) {
					track_puid_match[file_in_group] = true;
				} else {
					track_puid_match[file_in_group] = false;
					/* do meta lookup if no match on puid lookup */
					string wsquery = "";
					tracks = locutus->webservice->searchMetadata(wsquery);
				}
			} else if (ambid != "") {
				/* mbid lookup */
				if (albums.find(ambid) == albums.end()) {
					vector<Metadata> album = locutus->webservice->fetchAlbum(ambid);
					albums[ambid] = album;
				}
				tracks = albums[ambid];
			} else {
				/* meta lookup */
				string wsquery = "";
				tracks = locutus->webservice->searchMetadata(wsquery);
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
				/* new album fetched, compare all files in group with it */
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
						/* TODO: store possible match in database */
					}
				}
			}
		}
		/* figure out album scores */
		map<string, double> album_scores;
		map<string, vector<AlbumMatch> > album_matched;
		for (map<string, map<vector<Metadata>::size_type, vector<Match> > >::iterator album = matches.begin(); album != matches.end(); ++album) {
			AlbumMatch tmp;
			tmp.file = -1;
			tmp.score = 0.0;
			vector<AlbumMatch> matched(group->second.size(), tmp);
			double album_score = 0.0;
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
					matched[best_track].file = best_file;
					matched[best_track].score = best_score;
					album_score += best_score;
				}
			}
			album_scores[album->first] = album_score;
			album_matched[album->first] = matched;
		}
		/* make changes */
	}
}
