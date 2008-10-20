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
		void endElement(const unsigned char *name);
		void printXML(XMLNode *startnode, int indent) const;
		int read(unsigned char *buffer, size_t len);
		void startElement(const unsigned char *name, const unsigned char **attr);
};
#endif
