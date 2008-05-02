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
	/* check if it's in database and updated recently first */
	string url = release_lookup_url;
	url.append(mbid);
	url.append("?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels");
	Album album;
	if (fetch(url.c_str())) {
	}
	pthread_mutex_unlock(&mutex);
	return album;
}

void WebService::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(WEBSERVICE_CLASS, WEBSERVICE_CLASS_DESCRIPTION);
	metadata_search_url = locutus->settings->loadSetting(setting_class_id, METADATA_SEARCH_URL_KEY, METADATA_SEARCH_URL_VALUE, METADATA_SEARCH_URL_DESCRIPTION);
	puid_search_url = locutus->settings->loadSetting(setting_class_id, PUID_SEARCH_URL_KEY, PUID_SEARCH_URL_VALUE, PUID_SEARCH_URL_DESCRIPTION);
	release_lookup_url = locutus->settings->loadSetting(setting_class_id, RELEASE_LOOKUP_URL_KEY, RELEASE_LOOKUP_URL_VALUE, RELEASE_LOOKUP_URL_DESCRIPTION);
}

vector<Metadata> WebService::searchMetadata(string query) {
	string url = metadata_search_url;
	url.append("?type=xml&");
	url.append(query);
	vector<Metadata> tracks;
	if (fetch(url.c_str())) {
	}
	pthread_mutex_unlock(&mutex);
	return tracks;
}

vector<Metadata> WebService::searchPUID(string puid) {
	/* check if it's in database and updated recently first */
	string url = puid_search_url;
	url.append("?type=xml&puid=");
	url.append(puid);
	vector<Metadata> tracks;
	if (fetch(url.c_str())) {
	}
	pthread_mutex_unlock(&mutex);
	return tracks;
}

/* private methods */
void WebService::characters(const unsigned char *text, size_t len) {
	curnode->value = string((char *) text, len);
	cout << "DATA: " << curnode->value << endl;
}

void WebService::close() {
	URLStream::close();
}

void WebService::endElement(const unsigned char *name) {
	cout << "</" << name << ">" << endl;
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
	cout << "Parsing..." << endl;
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
	cout << "<" << name << ">" << endl;
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
