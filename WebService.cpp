#include "WebService.h"

/* constructors */
WebService::WebService(Locutus *locutus) {
	pthread_mutex_init(&mutex, NULL);
	this->locutus = locutus;
	root = new XMLNode;
}

/* destructors */
WebService::~WebService() {
	pthread_mutex_destroy(&mutex);
	delete root;
}

/* methods */
void WebService::cleanCache() {
	/* delete old data from database */
	ostringstream query;
	/* album */
	query << "DELETE FROM album WHERE updated + INTERVAL '" << album_cache_lifetime << " months' < now()";
	locutus->database->query(query.str());
	/* puid_track */
	query.str("");
	query << "DELETE FROM puid_track WHERE updated + INTERVAL '" << puid_cache_lifetime << " months' < now()";
	locutus->database->query(query.str());
	/* artist */
	query.str("");
	query << "DELETE FROM artist WHERE artist_id NOT IN (SELECT artist_id FROM album UNION SELECT artist_id FROM track)";
	locutus->database->query(query.str());
}

vector<Metadata> WebService::fetchAlbum(string mbid) {
	vector<Metadata> album;
	if (mbid.size() != 36)
		return album;
	/* check if it's in database and updated recently first */
	mbid = locutus->database->escapeString(mbid);
	ostringstream query;
	query << "SELECT * FROM v_album_lookup WHERE album_mbid = '" << mbid << "'";
	if (locutus->database->query(query.str()) && locutus->database->getRows() > 0) {
		/* cool, we got this album in our "cache" */
		album.resize(locutus->database->getRows());
		for (int r = 0; r < locutus->database->getRows(); ++r) {
			Metadata track;
			track.setValue(MUSICBRAINZ_ALBUMARTISTID, locutus->database->getString(r, 0));
			track.setValue(ALBUMARTIST, locutus->database->getString(r, 1));
			track.setValue(ALBUMARTISTSORT, locutus->database->getString(r, 2));
			track.setValue(MUSICBRAINZ_ALBUMID, locutus->database->getString(r, 3));
			//album.type = locutus->database->getString(r, 4);
			track.setValue(ALBUM, locutus->database->getString(r, 5));
			//album.released = locutus->database->getString(r, 6);
			track.setValue(MUSICBRAINZ_TRACKID, locutus->database->getString(r, 7));
			track.setValue(TITLE, locutus->database->getString(r, 8));
			track.duration = locutus->database->getInt(r, 9);
			track.setValue(TRACKNUMBER, locutus->database->getString(r, 10));
			track.setValue(MUSICBRAINZ_ARTISTID, locutus->database->getString(r, 11));
			track.setValue(ARTIST, locutus->database->getString(r, 12));
			track.setValue(ARTISTSORT, locutus->database->getString(r, 13));
			album[locutus->database->getInt(r, 10) - 1] = track;
		}
		return album;
	}
	/* if not, then check web & update database */
	string url = release_lookup_url;
	url.append(mbid);
	url.append("?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels");
	if (fetch(url.c_str()) && root->children["metadata"].size() > 0) {
		XMLNode *release = root->children["metadata"][0]->children["release"][0];
		string ambid = release->children["id"][0]->value;
		string ambide = locutus->database->escapeString(ambid);
		string atype = release->children["type"][0]->value;
		string atypee = locutus->database->escapeString(atype);
		string atitle = release->children["title"][0]->value;
		string atitlee = locutus->database->escapeString(atitle);
		string aambid = release->children["artist"][0]->children["id"][0]->value;
		string aambide = locutus->database->escapeString(aambid);
		string aaname = release->children["artist"][0]->children["name"][0]->value;
		string aanamee = locutus->database->escapeString(aaname);
		string aasortname = release->children["artist"][0]->children["sort-name"][0]->value;
		string aasortnamee = locutus->database->escapeString(aasortname);
		string areleased = "";
		if (release->children["release-event-list"].size() > 0) {
			areleased = release->children["release-event-list"][0]->children["event"][0]->children["date"][0]->value;
			bool ok = false;
			if (areleased.size() == 10) {
				ok = true;
				for (int a = 0; a < 10 && ok; ++a) {
					if (a == 4 || a == 7) {
						if (areleased[a] != '-')
							ok = false;
					} else {
						if (areleased[a] < '0' || areleased[a] > '9')
							ok = false;
					}
				}
			}
			if (!ok) {
				if (areleased.size() >= 4) {
					bool yearok = true;
					for (int a = 0; a < 4 && yearok; ++a) {
						if (areleased[a] < '0' || areleased[a] > '9')
							yearok = false;
					}
					if (yearok)
						areleased = areleased.substr(0, 4);
					else
						areleased = "";
				} else {
					areleased = "";
				}
			}
		}
		string areleasede;
		if (areleased == "") {
			areleasede = "NULL";
		} else {
			areleasede = "'";
			areleasede.append(locutus->database->escapeString(areleased));
			if (areleased.size() == 4)
				areleasede.append("-01-01");
			areleasede.append("'");
		}
		query.str("");
		query << "INSERT INTO artist(mbid, name, sortname, loaded) SELECT '" << aambide << "', '" << aanamee << "', '" << aasortnamee << "', true WHERE NOT EXISTS (SELECT true FROM artist WHERE mbid = '" << aambide << "')";
		locutus->database->query(query.str());
		query.str("");
		query << "UPDATE artist SET name = '" << aanamee << "', sortname = '" << aasortnamee << "', loaded = true WHERE mbid = '" << aambide << "'";
		locutus->database->query(query.str());
		query.str("");
		query << "INSERT INTO album(artist_id, mbid, type, title, released, loaded) SELECT (SELECT artist_id FROM artist WHERE mbid = '" << aambide << "'), '" << ambide << "', '" << atypee << "', '" << atitlee << "', " << areleasede << ", true WHERE NOT EXISTS (SELECT true FROM album WHERE mbid = '" << ambide << "')";
		locutus->database->query(query.str());
		query.str("");
		query << "UPDATE album SET artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << aambide << "'), type = '" << atypee << "', title = '" << atitlee << "', released = " << areleasede << ", loaded = true, updated = now() WHERE mbid = '" << aambide << "'";
		locutus->database->query(query.str());
		album.resize(release->children["track-list"][0]->children["track"].size());
		for (vector<XMLNode *>::size_type a = 0; a < release->children["track-list"][0]->children["track"].size(); ++a) {
			Metadata track;
			track.setValue(MUSICBRAINZ_ALBUMID, ambid);
			track.setValue(ALBUM, atitle);
			track.setValue(MUSICBRAINZ_ALBUMARTISTID, aambid);
			track.setValue(ALBUMARTIST, aaname);
			track.setValue(ALBUMARTISTSORT, aasortname);
			string tmbid = release->children["track-list"][0]->children["track"][a]->children["id"][0]->value;
			track.setValue(MUSICBRAINZ_TRACKID, tmbid);
			string tmbide = locutus->database->escapeString(tmbid);
			string ttitle = release->children["track-list"][0]->children["track"][a]->children["title"][0]->value;
			track.setValue(TITLE, ttitle);
			string ttitlee = locutus->database->escapeString(ttitle);
			track.duration = atoi(release->children["track-list"][0]->children["track"][a]->children["duration"][0]->value.c_str());
			ostringstream num;
			num << a;
			track.setValue(TRACKNUMBER, num.str());
			string tambide = "";
			if (release->children["track-list"][0]->children["track"][a]->children["artist"].size() > 0) {
				string tambid = release->children["track-list"][0]->children["track"][a]->children["artist"][0]->children["id"][0]->value;
				track.setValue(MUSICBRAINZ_ARTISTID, tambid);
				tambide = locutus->database->escapeString(tambid);
				string tartist = release->children["track-list"][0]->children["track"][a]->children["artist"][0]->children["name"][0]->value;
				track.setValue(ARTIST, tartist);
				string tartiste = locutus->database->escapeString(tartist);
				string tartistsort = release->children["track-list"][0]->children["track"][a]->children["artist"][0]->children["sort-name"][0]->value;
				track.setValue(ARTISTSORT, tartistsort);
				string tartistsorte = locutus->database->escapeString(tartistsort);
				query.str("");
				query << "INSERT INTO artist(mbid, name, sortname, loaded) SELECT '" << tambide << "', '" << tartiste << "', '" << tartistsorte << "', true WHERE NOT EXISTS (SELECT true FROM artist WHERE mbid = '" << tambide << "')";
				locutus->database->query(query.str());
				query.str("");
				query << "UPDATE artist SET name = '" << tartiste << "', sortname = '" << tartistsorte << "', loaded = true WHERE mbid = '" << tambide << "'";
				locutus->database->query(query.str());
			} else {
				track.setValue(MUSICBRAINZ_ARTISTID, aambid);
				tambide = aambide;
				track.setValue(ARTIST, aaname);
				track.setValue(ARTISTSORT, aasortname);
			}
			album[a] = track;
			query.str("");
			query << "INSERT INTO track(album_id, artist_id, mbid, title, duration, tracknumber) SELECT (SELECT album_id FROM album WHERE mbid = '" << ambide << "'), (SELECT artist_id FROM artist WHERE mbid = '" << tambide << "'), '" << tmbide << "', '" << ttitlee << "', " << track.duration << ", " << a + 1 << " WHERE NOT EXISTS (SELECT true FROM track WHERE mbid = '" << tmbide << "')";
			locutus->database->query(query.str());
			query.str("");
			query << "UPDATE track SET album_id = (SELECT album_id FROM album WHERE mbid = '" << ambide << "'), artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << tambide << "'), title = '" << ttitlee << "', duration = " << track.duration << ", tracknumber = " << a + 1 << " WHERE mbid = '" << tmbide << "'";
			locutus->database->query(query.str());
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
	puid_cache_lifetime = locutus->settings->loadSetting(setting_class_id, PUID_CACHE_LIFETIME_KEY, PUID_CACHE_LIFETIME_VALUE, PUID_CACHE_LIFETIME_DESCRIPTION);
}

vector<Metadata> WebService::searchMetadata(string wsquery) {
	if (wsquery == "")
		return vector<Metadata>();
	string url = metadata_search_url;
	url.append("?type=xml&");
	url.append(wsquery);
	vector<Metadata> tracks;
	if (fetch(url.c_str()) && root->children["metadata"].size() > 0 && root->children["metadata"][0]->children["track-list"].size() > 0) {
		for (vector<XMLNode *>::size_type a = 0; a < root->children["metadata"][0]->children["track-list"][0]->children["track"].size(); ++a) {
			XMLNode *tracknode = root->children["metadata"][0]->children["track-list"][0]->children["track"][a];
			Metadata track;
			string tmbid = tracknode->children["id"][0]->value;
			track.setValue(MUSICBRAINZ_TRACKID, tmbid);
			string tmbide = locutus->database->escapeString(tmbid);
			string ttitle = tracknode->children["title"][0]->value;
			track.setValue(TITLE, ttitle);
			string ttitlee = locutus->database->escapeString(ttitle);
			if (tracknode->children["duration"].size() > 0)
				track.duration = atoi(tracknode->children["duration"][0]->value.c_str());
			string armbid = tracknode->children["artist"][0]->children["id"][0]->value;
			track.setValue(MUSICBRAINZ_ARTISTID, armbid);
			string armbide = locutus->database->escapeString(armbid);
			string arname = tracknode->children["artist"][0]->children["name"][0]->value;
			track.setValue(ARTIST, arname);
			string arnamee = locutus->database->escapeString(arname);
			string almbid = tracknode->children["release-list"][0]->children["release"][0]->children["id"][0]->value;
			track.setValue(MUSICBRAINZ_ALBUMID, almbid);
			string almbide = locutus->database->escapeString(almbid);
			string altitle = tracknode->children["release-list"][0]->children["release"][0]->children["title"][0]->value;
			track.setValue(ALBUM, altitle);
			string altitlee = locutus->database->escapeString(altitle);
			string offset = tracknode->children["release-list"][0]->children["release"][0]->children["track-list"][0]->children["offset"][0]->value;
			int tracknum = atoi(offset.c_str()) + 1;
			ostringstream num;
			num << tracknum;
			track.setValue(TRACKNUMBER, num.str());
			ostringstream query;
			query.str("");
			query << "INSERT INTO artist(mbid, name) SELECT '" << armbide << "', '" << arnamee << "' WHERE NOT EXISTS (SELECT true FROM artist WHERE mbid = '" << armbide << "')";
			locutus->database->query(query.str());
			query.str("");
			query << "UPDATE artist SET name = '" << arnamee << "' WHERE mbid = '" << armbide << "'";
			locutus->database->query(query.str());
			query.str("");
			query << "INSERT INTO album(artist_id, mbid, title) SELECT (SELECT artist_id FROM artist WHERE mbid = '" << armbide << "'), '" << almbide << "', '" << altitlee << "' WHERE NOT EXISTS (SELECT true FROM album WHERE mbid = '" << almbide << "')";
			locutus->database->query(query.str());
			query.str("");
			query << "UPDATE album SET artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << armbide << "'), title = '" << altitlee << "' WHERE mbid = '" << almbide << "'";
			locutus->database->query(query.str());
			query.str("");
			query << "INSERT INTO track(album_id, artist_id, mbid, title, duration, tracknumber) SELECT (SELECT album_id FROM album WHERE mbid = '" << almbide << "'), (SELECT artist_id FROM artist WHERE mbid = '" << armbide << "'), '" << tmbide << "', '" << ttitlee << "', " << track.duration << ", " << tracknum << " WHERE NOT EXISTS (SELECT true FROM track WHERE mbid = '" << tmbide << "')";
			locutus->database->query(query.str());
			query.str("");
			query << "UPDATE track SET album_id = (SELECT album_id FROM album WHERE mbid = '" << almbide << "'), artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << armbide << "'), title = '" << ttitlee << "', duration = " << track.duration << ", tracknumber = " << tracknum << " WHERE mbid = '" << tmbide << "'";
			locutus->database->query(query.str());
			tracks.push_back(track);
		}
	}
	pthread_mutex_unlock(&mutex);
	return tracks;
}

vector<Metadata> WebService::searchPUID(string puid) {
	vector<Metadata> tracks;
	if (puid.size() != 36)
		return tracks;
	/* first see if we got this puid in database, and if it's recently updated(?) */
	string epuid = locutus->database->escapeString(puid);
	ostringstream query;
	/* then look up on musicbrainz */
	string wsquery = "puid=";
	wsquery.append(puid);
	tracks = searchMetadata(wsquery);
	for (vector<Metadata>::size_type a = 0; a < tracks.size(); ++a) {
		/* puid isn't returned from query, so set it manually */
		tracks[a].setValue(MUSICIP_PUID, puid);
		/* update puid in database */
		string embid = locutus->database->escapeString(tracks[a].getValue(MUSICBRAINZ_TRACKID));
		if (embid == "")
			continue;
		query.str("");
		query << "INSERT INTO puid(track_id, puid) SELECT ('" << embid << "', '" << epuid << "') WHERE NOT EXISTS (SELECT true FROM puid WHERE puid = '" << epuid << "')";
		locutus->database->query(query.str());
	}
	return tracks;
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
	char *urle = new char[65536];
	urle = urlEncode(url, urle, 65536);
	cout << urle << endl;
	status = get(urle);
	delete [] urle;
	if (status) {
		cout << "failed; reason=" << status << endl;
		close();
		return false;
	}
	delete root;
	root = new XMLNode;
	root->parent = NULL;
	root->key = "root";
	root->value = "";
	curnode = root;
	if (!parse())
		cout << "not well formed..." << endl;
	close();
	printXML(root, 0);
	return true;
}

void WebService::printXML(XMLNode *startnode, int indent) {
	if (startnode == NULL)
		return;
	for (int a = 0; a < indent; ++a)
		cout << "  ";
	if (startnode->parent == NULL)
		cout << startnode->key << ": " << startnode->value << endl;
	else
		cout << startnode->key << " @" << startnode << ": " << startnode->value << " (parent: " << startnode->parent->key << " @" << startnode->parent << ")" << endl;
	for (map<string, vector<XMLNode *> >::iterator it = startnode->children.begin(); it != startnode->children.end(); ++it) {
		for (vector<XMLNode *>::size_type a = 0; a < it->second.size(); ++a)
			printXML(it->second[a], indent + 1);
	}
}

int WebService::read(unsigned char *buffer, size_t len) {
	URLStream::read((char *) buffer, len);
	return gcount();
}

void WebService::startElement(const unsigned char *name, const unsigned char **attr) {
	XMLNode *childnode = new XMLNode;
	childnode->parent = curnode;
	childnode->key = (char *) name;
	childnode->value = "";
	curnode->children[childnode->key].push_back(childnode);
	curnode = curnode->children[childnode->key][curnode->children[childnode->key].size() - 1];
	if (attr != NULL) {
		while (*attr != NULL) {
			childnode = new XMLNode;
			childnode->parent = curnode;
			childnode->key = (char *) *(attr++);
			childnode->value = (char *) *(attr++);
			curnode->children[childnode->key].push_back(childnode);
		}
	}
}
