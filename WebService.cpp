#include "WebService.h"

/* constructors */
WebService::WebService(Locutus *locutus) {
	pthread_mutex_init(&mutex, NULL);
	this->locutus = locutus;
}

/* destructors */
WebService::~WebService() {
	pthread_mutex_destroy(&mutex);
}

/* methods */
Album WebService::fetchAlbum(string mbid) {
	Album album;
	if (mbid.size() != 36)
		return album;
	/* check if it's in database and updated recently first */
	mbid = locutus->database->escapeString(mbid);
	ostringstream query;
	query << "SELECT * FROM v_album_lookup WHERE album_mbid = '" << mbid << "' AND album_updated + INTERVAL '" << album_cache_lifetime << " months' < now()";
	if (locutus->database->query(query.str()) && locutus->database->getRows() > 0) {
		/* cool, we got this album in our "cache" */
		album.artist_mbid = locutus->database->getString(0, 0);
		album.artist_type = locutus->database->getString(0, 1);
		album.artist_name = locutus->database->getString(0, 2);
		album.artist_sortname = locutus->database->getString(0, 3);
		album.mbid = locutus->database->getString(0, 4);
		album.type = locutus->database->getString(0, 5);
		// 0, 6 is album_updated, not needed
		album.title = locutus->database->getString(0, 7);
		// 0, 8 is released. hmm, TODO?
		for (int r = 0; r < locutus->database->getRows(); ++r) {
			Metadata track;
			track.setValue(MUSICBRAINZ_TRACKID, locutus->database->getString(r, 9));
			track.setValue(TITLE, locutus->database->getString(r, 10));
			track.duration = locutus->database->getInt(r, 11);
			track.setValue(TRACKNUMBER, locutus->database->getString(r, 12));
			if (!locutus->database->isNull(0, 13)) {
				track.setValue(MUSICBRAINZ_ARTISTID, locutus->database->getString(r, 13));
				// r, 14 is artist_type. TODO?
				track.setValue(ARTIST, locutus->database->getString(r, 15));
				track.setValue(ARTISTSORT, locutus->database->getString(r, 16));
			}
			album.tracks[locutus->database->getInt(0, 12)] = track;
		}
		locutus->database->clear();
		return album;
	}
	locutus->database->clear();
	/* if not, then check web & update database */
	string url = release_lookup_url;
	url.append(mbid);
	url.append("?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels");
	if (fetch(url.c_str()) && root.children["metadata"].size() > 0) {
		XMLNode release = root.children["metadata"][0].children["release"][0];
		album.mbid = release.children["id"][0].value;
		string ambide = locutus->database->escapeString(album.mbid);
		album.type = release.children["type"][0].value;
		string atypee = locutus->database->escapeString(album.type);
		album.title = release.children["title"][0].value;
		string atitlee = locutus->database->escapeString(album.title);
		album.artist_mbid = release.children["artist"][0].children["id"][0].value;
		string aambide = locutus->database->escapeString(album.artist_mbid);
		album.artist_type = release.children["artist"][0].children["type"][0].value;
		string aatypee = locutus->database->escapeString(album.artist_type);
		album.artist_name = release.children["artist"][0].children["name"][0].value;
		string aanamee = locutus->database->escapeString(album.artist_name);
		album.artist_sortname = release.children["artist"][0].children["sort-name"][0].value;
		string aasortnamee = locutus->database->escapeString(album.artist_sortname);
		string areleasede = ""; // TODO
		query.clear();
		bool queries_ok = true;
		query << "BEGIN";
		if (!locutus->database->query(query.str()))
			queries_ok = false;
		locutus->database->clear();
		if (queries_ok) {
			query.clear();
			query << "INSERT INTO artist(mbid, type, name, sortname) SELECT '" << aambide << "', '" << aatypee << "', '" << aanamee << "', '" << aasortnamee << "' WHERE NOT EXISTS (SELECT true FROM artist WHERE mbid = '" << aambide << "')";
			if (!locutus->database->query(query.str()))
				queries_ok = false;
			locutus->database->clear();
			if (queries_ok) {
				query.clear();
				query << "UPDATE artist SET type = '" << aatypee << "', name = '" << aanamee << "', sortname = '" << aasortnamee << "' WHERE mbid = '" << aambide << "'";
				if (!locutus->database->query(query.str()))
					queries_ok = false;
				locutus->database->clear();
			}
		}
		if (queries_ok) {
			query.clear();
			query << "INSERT INTO album(artist_id, mbid, type, title, released) SELECT (SELECT artist_id FROM artist WHERE mbid = '" << aambide << "'), '" << ambide << "', '" << atypee << "', '" << atitlee << "', '" << areleasede << "' WHERE NOT EXISTS (SELECT true FROM album WHERE mbid = '" << ambide << "')";
			if (!locutus->database->query(query.str()))
				queries_ok = false;
			locutus->database->clear();
			if (queries_ok) {
				query.clear();
				query << "UPDATE album SET artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << aambide << "'), type = '" << aatypee << "', title = '" << atitlee << "', released = '" << areleasede << "' WHERE mbid = '" << aambide << "'";
				if (!locutus->database->query(query.str()))
					queries_ok = false;
				locutus->database->clear();
			}
		}
		for (vector<XMLNode>::size_type a = 0; a < release.children["track-list"][0].children["track"].size(); ++a) {
			Metadata track;
			track.setValue(MUSICBRAINZ_TRACKID, release.children["track-list"][0].children["track"][a].children["id"][0].value);
			string tmbide = locutus->database->escapeString(track.getValue(MUSICBRAINZ_TRACKID));
			track.setValue(TITLE, release.children["track-list"][0].children["track"][a].children["title"][0].value);
			string ttitlee = locutus->database->escapeString(track.getValue(TITLE));
			track.duration = atoi(release.children["track-list"][0].children["track"][a].children["duration"][0].value.c_str());
			ostringstream num;
			num << a;
			track.setValue(TRACKNUMBER, num.str());
			string tambide = "";
			if (release.children["track-list"][0].children["track"][a].children["artist"].size() > 0) {
				track.setValue(MUSICBRAINZ_ARTISTID, release.children["track-list"][0].children["track"][a].children["artist"][0].children["id"][0].value);
				tambide = locutus->database->escapeString(track.getValue(MUSICBRAINZ_ARTISTID));
				track.setValue(ARTIST, release.children["track-list"][0].children["track"][a].children["artist"][0].children["name"][0].value);
				string tartist = locutus->database->escapeString(track.getValue(ARTIST));
				track.setValue(ARTISTSORT, release.children["track-list"][0].children["track"][a].children["artist"][0].children["sort-name"][0].value);
				string tartistsort = locutus->database->escapeString(track.getValue(ARTISTSORT));
			}
			album.tracks[a] = track;
			if (queries_ok) {
				query.clear();
				query << "INSERT INTO track(album_id, ";
				if (tambide != "")
					query << "artist_id, ";
				query << "mbid, title, duration, tracknumber) SELECT (SELECT album_id FROM album WHERE mbid = '" << ambide << "'), ";
				if (tambide != "")
					query << "(SELECT artist_id FROM artist WHERE mbid = '" << tambide << "'), ";
				query << "'" << tmbide << "', '" << ttitlee << "', " << track.duration << ", " << a << " WHERE NOT EXISTS (SELECT true FROM track WHERE mbid = '" << tmbide << "')";
				if (!locutus->database->query(query.str()))
					queries_ok = false;
				locutus->database->clear();
				if (queries_ok) {
					query.clear();
					query << "UPDATE track SET album_id = (SELECT album_id FROM album WHERE mbid = '" << ambide << "'), artist_id = (SELECT artist_id FROM artist WHERE mbid = '";
				       if (tambide != "")
					       query << tambide;
				       else
					       query << aambide;
				       query << "'), title = '" << ttitlee << "', duration = " << track.duration << ", tracknumber = " << a << " WHERE mbid = '" << tmbide << "'";
				       if (!locutus->database->query(query.str()))
					       queries_ok = false;
				       locutus->database->clear();
				}
			}
		}
		if (queries_ok) {
			query.clear();
			query << "COMMIT";
			locutus->database->query(query.str());
			locutus->database->clear();
		} else {
			query.clear();
			query << "ROLLLBACK";
			locutus->database->query(query.str());
			locutus->database->clear();
		}
	}
	pthread_mutex_unlock(&mutex);
	return album;
}

void WebService::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(WEBSERVICE_CLASS, WEBSERVICE_CLASS_DESCRIPTION);
	metadata_search_url = locutus->settings->loadSetting(setting_class_id, METADATA_SEARCH_URL_KEY, METADATA_SEARCH_URL_VALUE, METADATA_SEARCH_URL_DESCRIPTION);
	release_lookup_url = locutus->settings->loadSetting(setting_class_id, RELEASE_LOOKUP_URL_KEY, RELEASE_LOOKUP_URL_VALUE, RELEASE_LOOKUP_URL_DESCRIPTION);
	album_cache_lifetime = locutus->settings->loadSetting(setting_class_id, ALBUM_CACHE_LIFETIME_KEY, ALBUM_CACHE_LIFETIME_VALUE, ALBUM_CACHE_LIFETIME_DESCRIPTION);
}

vector<Metadata> WebService::searchMetadata(string query) {
	if (query == "")
		return vector<Metadata>();
	string url = metadata_search_url;
	url.append("?type=xml&");
	url.append(query);
	vector<Metadata> tracks;
	if (fetch(url.c_str()) && root.children["metadata"].size() > 0) {
		XMLNode tracklist = root.children["metadata"][0].children["track-list"][0];
		for (vector<XMLNode>::size_type a = 0; a < root.children["metadata"][0].children["track-list"][0].children["track"].size(); ++a) {
			XMLNode tracknode = root.children["metadata"][0].children["track-list"][0].children["track"][a];
			Metadata track;
			track.setValue(MUSICBRAINZ_TRACKID, tracknode.children["id"][0].value);
			track.setValue(TITLE, tracknode.children["title"][0].value);
			track.duration = atoi(tracknode.children["duration"][0].value.c_str());
			track.setValue(MUSICBRAINZ_ARTISTID, tracknode.children["artist"][0].children["id"][0].value);
			track.setValue(ARTIST, tracknode.children["artist"][0].children["artist"][0].value);
			track.setValue(MUSICBRAINZ_ALBUMID, tracknode.children["release-list"][0].children["release"][0].children["id"][0].value);
			track.setValue(ALBUM, tracknode.children["release-list"][0].children["release"][0].children["title"][0].value);
			string offset = tracknode.children["release-list"][0].children["release"][0].children["track-list"][0].children["offset"][0].value;
			stringstream meh;
			meh << atoi(offset.c_str()) + 1;
			track.setValue(TRACKNUMBER, meh.str());
		}
	}
	pthread_mutex_unlock(&mutex);
	return tracks;
}

vector<Metadata> WebService::searchPUID(string puid) {
	if (puid == "")
		return vector<Metadata>();
	/* check if it's in database and updated recently first */
	string query = "puid=";
	query.append(puid);
	return searchMetadata(query);
}

/* private methods */
void WebService::characters(const unsigned char *text, size_t len) {
	curnode->value = string((char *) text, len);
}

void WebService::close() {
	URLStream::close();
}

void WebService::endElement(const unsigned char *name) {
	if (curnode != NULL)
		curnode = curnode->parent;
}

bool WebService::fetch(const char *url) {
	pthread_mutex_lock(&mutex);
	cout << url << endl;
	status = get(url);
	if (status) {
		cout << "failed; reason=" << status << endl;
		close();
		return false;
	}
	root.parent = NULL;
	root.children.clear();
	root.key = "root";
	root.value = "";
	curnode = &root;
	if (!parse())
		cout << "not well formed..." << endl;
	close();
	printXML(&root);
	return true;
}

void WebService::printXML(XMLNode *startnode) {
	if (startnode == NULL)
		return;
	if (startnode->parent == NULL)
		cout << startnode->key << ": " << startnode->value << endl;
	else
		cout << startnode->key << ": " << startnode->value << " (parent: " << startnode->parent->key << ")" << endl;
	for (map<string, vector<XMLNode> >::iterator it = startnode->children.begin(); it != startnode->children.end(); ++it) {
		for (vector<XMLNode>::size_type a = 0; a < it->second.size(); ++a)
			printXML(&it->second[a]);
	}
}

int WebService::read(unsigned char *buffer, size_t len) {
	URLStream::read((char *) buffer, len);
	return gcount();
}

void WebService::startElement(const unsigned char *name, const unsigned char **attr) {
	XMLNode childnode;
	childnode.parent = curnode;
	childnode.key = (char *) name;
	childnode.value = "";
	curnode->children[childnode.key].push_back(childnode);
	if (curnode->children[childnode.key].size() > 1)
		uniteChildrenWithParent(curnode, childnode.key);
	curnode = &curnode->children[childnode.key][curnode->children[childnode.key].size() - 1];
	if (attr != NULL) {
		while (*attr != NULL) {
			childnode.parent = curnode;
			childnode.key = (char *) *(attr++);
			childnode.value = (char *) *(attr++);
			curnode->children[childnode.key].push_back(childnode);
			if (curnode->children[childnode.key].size() > 1)
				uniteChildrenWithParent(curnode, childnode.key);
		}
	}
}

void WebService::uniteChildrenWithParent(XMLNode *parent, string key) {
	/* when we add more elements to a vector the other elements might be recreated.
	 * this means they'll get a new memory location, and the "parent" pointer in child nodes is invalid */
	for (vector<XMLNode>::size_type a = 0; a < parent->children[key].size() - 1; ++a) {
		for (map<string, vector<XMLNode> >::iterator it = parent->children[key][a].children.begin(); it != parent->children[key][a].children.end(); ++it) {
			for (vector<XMLNode>::size_type a = 0; a < it->second.size(); ++a)
				it->second[a].parent = parent;
		}
	}
}
