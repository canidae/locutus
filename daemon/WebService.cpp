#include "Album.h"
#include "Database.h"
#include "Debug.h"
#include "WebService.h"

using namespace ost;
using namespace std;

/* constructors/destructor */
WebService::WebService(Database *database) : database(database) {
	root = new XMLNode;
	metadata_search_url = database->loadSetting(METADATA_SEARCH_URL_KEY, METADATA_SEARCH_URL_VALUE, METADATA_SEARCH_URL_DESCRIPTION);
	release_lookup_url = database->loadSetting(RELEASE_LOOKUP_URL_KEY, RELEASE_LOOKUP_URL_VALUE, RELEASE_LOOKUP_URL_DESCRIPTION);
}

WebService::~WebService() {
	clearXMLNode(root);
	delete root;
}

/* methods */
bool WebService::lookupAlbum(Album *album) {
	if (album == NULL || album->mbid.size() != 36 || album->mbid[8] != '-' || album->mbid[13] != '-' || album->mbid[18] != '-' || album->mbid[23] != '-')
		return false;
	string url = release_lookup_url;
	url.append(album->mbid);
	url.append("?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels");
	if (!fetch(url.c_str()))
		return false;
	/* album data */
	if (root->children["metadata"].size() <= 0)
		return false;
	XMLNode *xml_album = root->children["metadata"][0]->children["release"][0];
	album->mbid = xml_album->children["id"][0]->value;
	album->type = xml_album->children["type"][0]->value;
	album->title = xml_album->children["title"][0]->value;
	if (xml_album->children["release-event-list"].size() > 0) {
		album->released = xml_album->children["release-event-list"][0]->children["event"][0]->children["date"][0]->value;
		if (album->released.size() == 10 && album->released[4] == '-' && album->released[7] == '-') {
			/* ok as it is, probably a valid date */
		} else if (album->released.size() == 4) {
			/* only year, make month & day 01 */
			album->released.append("-01-01");
		} else {
			/* possibly not a valid date, ignore it */
			album->released = "";
		}
	}
	/* artist data */
	album->artist.mbid = xml_album->children["artist"][0]->children["id"][0]->value;
	album->artist.name = xml_album->children["artist"][0]->children["name"][0]->value;
	album->artist.sortname = xml_album->children["artist"][0]->children["sort-name"][0]->value;
	/* track data */
	album->tracks.resize(xml_album->children["track-list"][0]->children["track"].size(), Track(album));
	for (vector<XMLNode *>::size_type a = 0; a < xml_album->children["track-list"][0]->children["track"].size(); ++a) {
		/* track data */
		album->tracks[a].mbid = xml_album->children["track-list"][0]->children["track"][a]->children["id"][0]->value;
		album->tracks[a].title = xml_album->children["track-list"][0]->children["track"][a]->children["title"][0]->value;
		album->tracks[a].duration = atoi(xml_album->children["track-list"][0]->children["track"][a]->children["duration"][0]->value.c_str());
		album->tracks[a].tracknumber = a + 1;
		/* track artist data */
		if (xml_album->children["track-list"][0]->children["track"][a]->children["artist"].size() > 0) {
			album->tracks[a].artist.mbid = xml_album->children["track-list"][0]->children["track"][a]->children["artist"][0]->children["id"][0]->value;
			album->tracks[a].artist.name = xml_album->children["track-list"][0]->children["track"][a]->children["artist"][0]->children["name"][0]->value;
			album->tracks[a].artist.sortname = xml_album->children["track-list"][0]->children["track"][a]->children["artist"][0]->children["sort-name"][0]->value;
		} else {
			album->tracks[a].artist.mbid = album->artist.mbid;
			album->tracks[a].artist.name = album->artist.name;
			album->tracks[a].artist.sortname = album->artist.sortname;
		}
	}
	return true;
}

const vector<Metatrack> &WebService::searchMetadata(const string &wsquery) {
	tracks.clear();
	if (wsquery == "")
		return tracks;
	string url = metadata_search_url;
	url.append("?type=xml&");
	url.append(wsquery);
	if (fetch(url.c_str()) && root->children["metadata"].size() > 0 && root->children["metadata"][0]->children["track-list"].size() > 0) {
		for (vector<XMLNode *>::size_type a = 0; a < root->children["metadata"][0]->children["track-list"][0]->children["track"].size(); ++a) {
			if (getMetatrack(root->children["metadata"][0]->children["track-list"][0]->children["track"][a]))
				tracks.push_back(metatrack);
		}
	}
	return tracks;
}

const vector<Metatrack> &WebService::searchPUID(const string &puid) {
	tracks.clear();
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

void WebService::clearXMLNode(XMLNode *node) {
	for (map<string, vector<XMLNode *> >::iterator it = node->children.begin(); it != node->children.end(); ++it) {
		for (vector<XMLNode *>::size_type a = 0; a < it->second.size(); ++a) {
			clearXMLNode(it->second[a]);
			delete it->second[a];
		}
	}
}

void WebService::close() {
	URLStream::close();
}

void WebService::endElement(const unsigned char *name) {
	if (curnode != NULL)
		curnode = curnode->parent;
}

bool WebService::fetch(const char *url) {
	char *urle = new char[4096];
	urle = urlEncode(url, urle, 4096);
	Debug::info(urle);
	status = get(urle);
	delete [] urle;
	if (status) {
		//cout << "failed; reason=" << status << endl;
		Debug::warning("Unable to fetch data");
		close();
		return false;
	}
	clearXMLNode(root);
	delete root;
	root = new XMLNode;
	root->parent = NULL;
	root->key = "root";
	root->value = "";
	curnode = root;
	if (!parse())
		Debug::warning("XML is not well formed");
	close();
	//printXML(root, 0);
	return true;
}

bool WebService::getMetatrack(XMLNode *track) {
	metatrack.track_mbid = track->children["id"][0]->value;
	metatrack.track_title = track->children["title"][0]->value;
	if (track->children["duration"].size() > 0)
		metatrack.duration = atoi(track->children["duration"][0]->value.c_str());
	metatrack.artist_mbid = track->children["artist"][0]->children["id"][0]->value;
	metatrack.artist_name = track->children["artist"][0]->children["name"][0]->value;
	metatrack.album_mbid = track->children["release-list"][0]->children["release"][0]->children["id"][0]->value;
	metatrack.album_title = track->children["release-list"][0]->children["release"][0]->children["title"][0]->value;
	string offset = track->children["release-list"][0]->children["release"][0]->children["track-list"][0]->children["offset"][0]->value;
	metatrack.tracknumber = atoi(offset.c_str()) + 1;
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
