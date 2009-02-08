// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
// 
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
// 
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

#include "Debug.h"
#include "WebService.h"

using namespace ost;
using namespace std;

/* constructors/destructor */
WebService::WebService() : root(new XMLNode), curnode(root) {
}

WebService::~WebService() {
	clearXMLNode(root);
	delete root;
}

/* protected methods */
XMLNode *WebService::fetch(const char *url) {
	char *urle = new char[4096];
	urle = urlEncode(url, urle, 4096);
	Debug::info() << urle << endl;
	status = get(urle);
	if (status) {
		Debug::notice() << "Unable to fetch data. Reason: " << status << endl;
		close();
		Debug::notice() << "Trying once more..." << endl;
		sleep(3); // sleep a bit before trying again
		status = get(urle);
		if (status) {
			Debug::warning() << "Unable to fetch data. Reason: " << status << endl;
			close();
			delete [] urle;
			return NULL;
		}
	}
	delete [] urle;
	clearXMLNode(root);
	delete root;
	root = new XMLNode;
	root->parent = NULL;
	root->key = "root";
	root->value = "";
	curnode = root;
	if (!parse())
		Debug::warning() << "XML is not well formed" << endl;
	close();
	//printXML(root, 0);
	return root;
}

/* private methods */
void WebService::characters(const unsigned char *text, size_t len) {
	curnode->value.append(string((char *) text, len));
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
