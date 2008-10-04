#include "Album.h"
#include "Database.h"
#include "Debug.h"
#include "Metafile.h"
#include "WebService.h"

using namespace ost;
using namespace std;

/* constructors/destructor */
WebService::WebService(Database *database) : database(database), root(new XMLNode), curnode(root) {
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
	if (root->children["metadata"].size() <= 0 || root->children["metadata"][0]->children["release"].size() <= 0)
		return false;
	XMLNode *tmp = root->children["metadata"][0]->children["release"][0];
	album->mbid = (tmp->children["id"].size() > 0) ? tmp->children["id"][0]->value : "";
	album->type = (tmp->children["type"].size() > 0) ? tmp->children["type"][0]->value : "";
	album->title = (tmp->children["title"].size() > 0) ? tmp->children["title"][0]->value : "";
	if (tmp->children["release-event-list"].size() > 0 && tmp->children["release-event-list"][0]->children["event"].size() > 0 && tmp->children["release-event-list"][0]->children["event"][0]->children["date"].size() > 0) {
		album->released = tmp->children["release-event-list"][0]->children["event"][0]->children["date"][0]->value;
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
	if (tmp->children["artist"].size() <= 0)
		return false;
	XMLNode *tmp2 = tmp->children["artist"][0];
	album->artist->mbid = (tmp2->children["id"].size() > 0) ? tmp2->children["id"][0]->value : "";
	album->artist->name = (tmp2->children["name"].size() > 0) ? tmp2->children["name"][0]->value : "";
	album->artist->sortname = (tmp2->children["sort-name"].size() > 0) ? tmp2->children["sort-name"][0]->value : "";
	/* track data */
	if (tmp->children["track-list"].size() <= 0 || tmp->children["track-list"][0]->children["track"].size() <= 0)
		return false;
	tmp = tmp->children["track-list"][0];
	album->tracks.resize(tmp->children["track"].size(), new Track(album));
	for (vector<XMLNode *>::size_type a = 0; a < tmp->children["track"].size(); ++a) {
		/* track data */
		tmp2 = tmp->children["track"][a];
		album->tracks[a]->mbid = (tmp2->children["id"].size() > 0) ? tmp2->children["id"][0]->value : "";
		album->tracks[a]->title = (tmp2->children["title"].size() > 0) ? tmp2->children["title"][0]->value : "";
		album->tracks[a]->duration = (tmp2->children["duration"].size() > 0) ? atoi(tmp2->children["duration"][0]->value.c_str()) : 0;
		album->tracks[a]->tracknumber = a + 1;
		/* track artist data */
		if (tmp2->children["artist"].size() > 0) {
			tmp2 = tmp2->children["artist"][0];
			album->tracks[a]->artist->mbid = (tmp2->children["id"].size() > 0) ? tmp2->children["id"][0]->value : "";
			album->tracks[a]->artist->name = (tmp2->children["name"].size() > 0) ? tmp2->children["name"][0]->value : "";
			album->tracks[a]->artist->sortname = (tmp2->children["sort-name"].size() > 0) ? tmp2->children["sort-name"][0]->value : "";
		} else {
			album->tracks[a]->artist->mbid = album->artist->mbid;
			album->tracks[a]->artist->name = album->artist->name;
			album->tracks[a]->artist->sortname = album->artist->sortname;
		}
	}
	return true;
}

const vector<Metatrack> &WebService::searchMetadata(const string &group, const Metafile &metafile) {
	ostringstream query;
	string e_group = escapeString(group);
	string bnwe = escapeString(metafile.getBaseNameWithoutExtension());
	query << "limit=25&query=";
	query << "tnum:(" << escapeString(metafile.tracknumber) << " " << bnwe << ") ";
	if (metafile.duration > 0) {
		int lower = metafile.duration / 1000 - 10;
		int upper = metafile.duration / 1000 + 10;
		if (lower < 0)
			lower = 0;
		query << "qdur:[" << lower << " TO " << upper << "] ";
	}
	query << "artist:(" << escapeString(metafile.artist) << " " << bnwe << " " << e_group << ") ";
	query << "track:(" << escapeString(metafile.title) << " " << bnwe << " " << ") ";
	query << "release:(" << escapeString(metafile.album) << " " << bnwe << " " << e_group << ") ";
	return searchMetadata(query.str());
}

const vector<Metatrack> &WebService::searchPUID(const string &puid) {
	tracks.clear();
	if (puid.size() != 36)
		return tracks;
	string query = "puid=";
	query.append(puid);
	return searchMetadata(query);
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

string WebService::escapeString(const string &text) {
	/* escape these characters:
	 * + - && || ! ( ) { } [ ] ^ " ~ * ? : \ */
	/* also change "_" to " " */
	ostringstream str;
	for (string::size_type a = 0; a < text.size(); ++a) {
		char c = text[a];
		switch (c) {
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
				if (a + 1 < text.size() && text[a + 1] == c)
					str << '\\';
				break;

			case '_':
				c = ' ';
				break;                                                                                                                 

			default:
				break;
		}
		str << c;
	}
	return str.str();
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
	if (track == NULL)
		return false;
	metatrack.track_mbid = (track->children["id"].size() > 0) ? track->children["id"][0]->value : "";
	metatrack.track_title = (track->children["title"].size() > 0) ? track->children["title"][0]->value : "";
	metatrack.duration = (track->children["duration"].size() > 0) ? atoi(track->children["duration"][0]->value.c_str()) : 0;
	if (track->children["artist"].size() <= 0) {
		metatrack.artist_mbid = "";
		metatrack.artist_name = "";
		metatrack.album_mbid = "";
		metatrack.album_title = "";
		metatrack.tracknumber = 0;
		return false;
	}
	XMLNode *tmp = track->children["artist"][0];
	metatrack.artist_mbid = (tmp->children["id"].size() > 0) ? tmp->children["id"][0]->value : "";
	metatrack.artist_name = (tmp->children["name"].size() > 0) ? tmp->children["name"][0]->value : "";
	if (track->children["release-list"].size() <= 0 || track->children["release-list"][0]->children["release"].size() <= 0) {
		metatrack.album_mbid = "";
		metatrack.album_title = "";
		metatrack.tracknumber = 0;
		return false;
	}
	tmp = track->children["release-list"][0]->children["release"][0];
	metatrack.album_mbid = (tmp->children["id"].size() > 0) ? tmp->children["id"][0]->value : "";
	metatrack.album_title = (tmp->children["title"].size() > 0) ? tmp->children["title"][0]->value : "";
	metatrack.tracknumber = (tmp->children["track-list"].size() > 0 && tmp->children["track-list"][0]->children["offset"].size() > 0) ? atoi(tmp->children["track-list"][0]->children["offset"][0]->value.c_str()) + 1: 0;
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

const vector<Metatrack> &WebService::searchMetadata(const string &query) {
	tracks.clear();
	if (query == "")
		return tracks;
	string url = metadata_search_url;
	url.append("?type=xml&");
	url.append(query);
	if (fetch(url.c_str()) && root->children["metadata"].size() > 0 && root->children["metadata"][0]->children["track-list"].size() > 0) {
		for (vector<XMLNode *>::size_type a = 0; a < root->children["metadata"][0]->children["track-list"][0]->children["track"].size(); ++a) {
			if (getMetatrack(root->children["metadata"][0]->children["track-list"][0]->children["track"][a]))
				tracks.push_back(metatrack);
		}
	}
	return tracks;
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
