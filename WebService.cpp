#include "WebService.h"

/* constructors */
WebService::WebService(Locutus *locutus) {
	this->locutus = locutus;
	root = new XMLNode;
	tracks = new vector<Metatrack>;
}

/* destructors */
WebService::~WebService() {
	delete root;
	delete tracks;
}

/* methods */
void WebService::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(WEBSERVICE_CLASS, WEBSERVICE_CLASS_DESCRIPTION);
	metadata_search_url = locutus->settings->loadSetting(setting_class_id, METADATA_SEARCH_URL_KEY, METADATA_SEARCH_URL_VALUE, METADATA_SEARCH_URL_DESCRIPTION);
	release_lookup_url = locutus->settings->loadSetting(setting_class_id, RELEASE_LOOKUP_URL_KEY, RELEASE_LOOKUP_URL_VALUE, RELEASE_LOOKUP_URL_DESCRIPTION);
}

XMLNode *WebService::lookupAlbum(const string &mbid) {
	if (mbid.size() != 36)
		return NULL;
	string url = release_lookup_url;
	url.append(mbid);
	url.append("?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels");
	if (fetch(url.c_str()))
		return root;
	return NULL;
}

vector<Metatrack> *WebService::searchMetadata(const string &wsquery) {
	tracks->clear();
	if (wsquery == "")
		return tracks;
	string url = metadata_search_url;
	url.append("?type=xml&");
	url.append(wsquery);
	if (fetch(url.c_str()) && root->children["metadata"].size() > 0 && root->children["metadata"][0]->children["track-list"].size() > 0) {
		for (vector<XMLNode *>::size_type a = 0; a < root->children["metadata"][0]->children["track-list"][0]->children["track"].size(); ++a) {
			Metatrack track(locutus);
			track.readFromXML(root->children["metadata"][0]->children["track-list"][0]->children["track"][a]);
			tracks->push_back(track);
		}
	}
	return tracks;
}

vector<Metatrack> *WebService::searchPUID(const string &puid) {
	tracks->clear();
	if (puid.size() != 36)
		return tracks;
	string wsquery = "puid=";
	wsquery.append(puid);
	return searchMetadata(wsquery);
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
	//printXML(root, 0);
	return true;
}

void WebService::printXML(XMLNode *startnode, int indent) const {
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
