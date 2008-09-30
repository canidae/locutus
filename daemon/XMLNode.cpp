#include "XMLNode.h"

using namespace std;

/* constructors/destructor */
XMLNode::XMLNode() {
}

XMLNode::~XMLNode() {
	for (map<string, vector<XMLNode *> >::iterator it = children.begin(); it != children.end(); ++it) {
		for (vector<XMLNode *>::size_type a = 0; a < it->second.size(); ++a)
			delete it->second[a];
	}
}
