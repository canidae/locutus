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

#ifndef WEBSERVICE_H
#define WEBSERVICE_H

#include <cc++/common.h>
#include <map>
#include <string>
#include <vector>

struct XMLNode {
	XMLNode *parent;
	std::map<std::string, std::vector<XMLNode *> > children;
	std::string key;
	std::string value;
};

class WebService : public ost::URLStream, public ost::XMLStream {
public:
	WebService();
	~WebService();

protected:
	XMLNode *fetch(const char *url);

private:
	URLStream::Error status;
	XMLNode *root;
	XMLNode *curnode;

	void characters(const unsigned char *text, size_t len);
	void clearXMLNode(XMLNode *node);
	void close();
	void endElement(const unsigned char *);
	void printXML(XMLNode *startnode, int indent) const;
	int read(unsigned char *buffer, size_t len);
	void startElement(const unsigned char *name, const unsigned char **attr);
};
#endif
