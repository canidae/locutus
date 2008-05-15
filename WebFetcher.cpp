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
	puid_min_match = locutus->settings->loadSetting(setting_class_id, PUID_MIN_MATCH_KEY, PUID_MIN_MATCH_VALUE, PUID_MIN_MATCH_DESCRIPTION);
	metadata_min_match = locutus->settings->loadSetting(setting_class_id, METADATA_MIN_MATCH_KEY, METADATA_MIN_MATCH_VALUE, METADATA_MIN_MATCH_DESCRIPTION);
}

void WebFetcher::lookup() {
	for (map<string, vector<int> >::iterator it = locutus->grouped_files.begin(); it != locutus->grouped_files.end(); ++it) {
		map<string, Album> albums;
		map<string, map<vector<Metadata>::size_type, vector<Match> > > matches;
		vector<bool> mbid_looked_up;
		vector<bool> puid_looked_up;
		vector<bool> meta_looked_up;
		/* look up using mbid */
		/* look up using puid */
		for (vector<int>::size_type file_in_group = 0; file_in_group < it->second.size(); ++file_in_group) {
			FileMetadata fm = locutus->files[it->second[file_in_group]];
			if (!fm.puid_lookup)
				continue;
			vector<Metadata> tracks = locutus->webservice->searchPUID(fm.getValue(MUSICIP_PUID));
			for (vector<int>::size_type track_in_result = 0; track_in_result < tracks.size(); ++track_in_result) {
				string ambid = tracks[track_in_result].getValue(MUSICBRAINZ_ALBUMID);
				if (albums.find(ambid) == albums.end()) {
					Album album = locutus->webservice->fetchAlbum(ambid);
					albums[ambid] = album;
				}
				Match match;
				match.file = file_in_group;
				match.mbid_match = fm.equalMBID(tracks[track_in_result]);
				match.puid_match = true;
				match.meta_score = fm.compareWithMetadata(tracks[track_in_result]);
				/* TODO: store possible match in database */
				matches[ambid][track_in_result].push_back(match);
			}
		}
		/* match files with albums */
		/* look up using metadata */
		/* match files with albums */
	}
}
