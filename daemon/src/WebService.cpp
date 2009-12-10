// Copyright © 2008-2009 Vidar Wahlberg <canidae@exent.net>
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

#include "Debug.h"
#include "WebService.h"

using namespace ost;
using namespace std;

WebService::WebService() : root(new XMLNode), curnode(root) {
}

WebService::~WebService() {
	clearXMLNode(root);
	delete root;
}

XMLNode *WebService::fetch(const char *url, const char **args) {
	char *urle = new char[CHAR_BUFFER];
	urle = urlEncode(url, urle, CHAR_BUFFER);
	if (args == NULL)
		status = get(urle);
	else
		status = submit(urle, args);
	if (status) {
		Debug::notice() << "Unable to fetch data. Reason: " << status << endl;
		Debug::notice() << "Trying once more..." << endl;
		close();
		sleep(3); // sleep a bit before trying again
		if (args == NULL)
			status = get(urle);
		else
			status = submit(urle, args);
		if (status) {
			ostringstream str;
			str << "Failed again, giving up. URL: " << urle;
			if (args != NULL && args[0] != NULL) {
				str << "?";
				str << args[0];
				int a = 0;
				while (args[++a] != NULL)
					str << "&" << args[a];
			}
			Debug::warning() << str.str() << endl;
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
	/* commoncpp may get stuck in a recvfrom if we get net hiccup.
	 * to prevent this we set up an alarm() which if we don't get a reply within
	 * TIMEOUT then we cancel the current system call.
	 * see bottom of Locutus.cpp for the handling of SIGALRM */
	alarm(TIMEOUT);
	if (!parse())
		Debug::warning() << "XML is not well formed" << endl;
	alarm(0); // reset alarm
	close();
	//printXML(root, 0);
	return root;
}

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

void WebService::endElement(const unsigned char *) {
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
