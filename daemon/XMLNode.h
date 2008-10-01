#ifndef XMLNODE_H
#define XMLNODE_H

#include <map>
#include <string>
#include <vector>

class XMLNode {
	public:
		XMLNode *parent;
		std::map<std::string, std::vector<XMLNode *> > children;
		std::string key;
		std::string value;

		XMLNode();

		~XMLNode();
};
#endif
