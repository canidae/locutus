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

#ifndef WEBSERVICE_H
#define WEBSERVICE_H

#include <cc++/common.h>
#include <map>
#include <string>
#include <vector>

#define TIMEOUT 180
#define CHAR_BUFFER 4096

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
	XMLNode *fetch(const char *url, const char **args);

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
