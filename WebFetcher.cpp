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
}

void WebFetcher::lookup() {
	for (map<string, vector<int> >::iterator it = locutus->grouped_files.begin(); it != locutus->grouped_files.end(); ++it) {
		/* check if there are any files we want to look up puid for */
		/* TODO
		 * this whole thing has to be rethought & rewritten.
		 * bloody noisy people.
		 * the idea, which is hard to think of right now is something like this:
		 * - if we got mbid and puid lookup returns vastly different tracks, notify user
		 * - perhaps lookup all puids first and see if lots of them mostly match 1 album?
		 * - hrm, will have to think more later, when i actually can hear my own thoughts
		 */
		vector<Album> albums;
		/* TODO
		 * screw this for now, we don't generate puids yet, it's not important.
		 * spend time on matching metadata first */
		for (vector<int>::size_type a = 0; a < it->second.size(); ++a) {
			FileMetadata fm = locutus->files[it->second[a]];
			if (!fm.puid_lookup)
				continue;
			vector<Metadata> tracks = locutus->webservice->searchPUID(fm.getValue(MUSICIP_PUID));
			for (vector<int>::size_type b = 0; b < tracks.size(); ++b) {
				double match = fm.compareWithMetadata(tracks[b]);
				if (match < puid_min_match)
					continue;
				/* good match, add this album as a potential match */
				Album album = locutus->webservice->fetchAlbum(tracks[b].getValue(MUSICBRAINZ_ALBUMID));
				bool add_album = true;
				for (vector<int>::size_type c = 0; c < albums.size(); ++c) {
					if (albums[c].mbid == album.mbid) {
						add_album = false;
						break;
					}
				}
				if (add_album)
					albums.push_back(album);
			}
		}
		/* after looking up puids, compare albums with files in group */
		/* TODO & FIXME */

		/* then lookup using metadata
		 * to limit lookups to musicbrainz:
		 * 10 lookup file not connected to any album
		 * 20 load album with best metadata match
		 * 30 match all files in group with album
		 * 40 goto 10
		 */
		for (vector<int>::size_type a = 0; a < it->second.size(); ++a) {
		}
	}
}
