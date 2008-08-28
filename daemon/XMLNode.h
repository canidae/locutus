#ifndef XMLNODE_H
/* defines */
#define XMLNODE_H

/* includes */
#include <map>
#include <string>
#include <vector>

/* namespaces */
using namespace std;

/* XMLNode */
class XMLNode {
	public:
		/* variables */
		XMLNode *parent;
		map<string, vector<XMLNode *> > children;
		string key;
		string value;

		/* constructors */
		XMLNode();

		/* destructors */
		~XMLNode();
};
#endif
