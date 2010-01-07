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

extern "C" {
#include <sys/stat.h>
}

using namespace std;

bool Debug::initialized = false;
string Debug::timestamp;
ofstream Debug::debugfile;

void Debug::open(const string& file) {
	if (initialized)
		close();
	initialized = true;
	debugfile.open(file.c_str(), ios_base::app);
}

void Debug::close() {
	if (!initialized)
		return;
	debugfile.close();
	initialized = false;
	return;
}

ofstream& Debug::info() {
	debugfile << "[" << getTime() << "] [INFO   ] ";
	return debugfile;
}

ofstream& Debug::notice() {
	debugfile << "[" << getTime() << "] [NOTICE ] ";
	return debugfile;
}

ofstream& Debug::warning() {
	debugfile << "[" << getTime() << "] [WARNING] ";
	return debugfile;
}

ofstream& Debug::error() {
	debugfile << "[" << getTime() << "] [ERROR  ] ";
	return debugfile;
}

string& Debug::getTime() {
	time_t rawtime;
	time(&rawtime);
	timestamp = asctime(localtime(&rawtime));
	return timestamp.erase(timestamp.size() - 1);
}
