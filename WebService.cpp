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
	if (mbid == "")
		return album;
	/* check if it's in database and updated recently first */
	string url = release_lookup_url;
	url.append(mbid);
	url.append("?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels");
	if (fetch(url.c_str()) && root.children["metadata"].size() > 0) {
		XMLNode release = root.children["metadata"][0].children["release"][0];
		album.mbid = release.children["id"][0].value;
		album.type = release.children["type"][0].value;
		album.title = release.children["title"][0].value;
		album.artist_mbid = release.children["artist"][0].children["id"][0].value;
		album.artist_type = release.children["artist"][0].children["type"][0].value;
		album.artist_name = release.children["artist"][0].children["name"][0].value;
		album.artist_sortname = release.children["artist"][0].children["sort-name"][0].value;
		for (vector<XMLNode>::size_type a = 0; a < release.children["track-list"][0].children["track"].size(); ++a) {
			Metadata track;
			track.setValue(MUSICBRAINZ_TRACKID, release.children["track-list"][0].children["track"][a].children["id"][0].value);
			track.setValue(TITLE, release.children["track-list"][0].children["track"][a].children["title"][0].value);
			track.duration = atoi(release.children["track-list"][0].children["track"][a].children["duration"][0].value.c_str());
			if (release.children["track-list"][0].children["track"][a].children["artist"].size() > 0) {
				track.setValue(MUSICBRAINZ_ARTISTID, release.children["track-list"][0].children["track"][a].children["artist"][0].children["id"][0].value);
				track.setValue(ARTIST, release.children["track-list"][0].children["track"][a].children["artist"][0].children["name"][0].value);
				track.setValue(ARTISTSORT, release.children["track-list"][0].children["track"][a].children["artist"][0].children["sort-name"][0].value);
			}
		}
	}
	pthread_mutex_unlock(&mutex);
	return album;
}

void WebService::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(WEBSERVICE_CLASS, WEBSERVICE_CLASS_DESCRIPTION);
	metadata_search_url = locutus->settings->loadSetting(setting_class_id, METADATA_SEARCH_URL_KEY, METADATA_SEARCH_URL_VALUE, METADATA_SEARCH_URL_DESCRIPTION);
	release_lookup_url = locutus->settings->loadSetting(setting_class_id, RELEASE_LOOKUP_URL_KEY, RELEASE_LOOKUP_URL_VALUE, RELEASE_LOOKUP_URL_DESCRIPTION);
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
