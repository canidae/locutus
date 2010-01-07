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

using namespace std;

bool Debug::initialized = false;
string Debug::timestamp;
ofstream Debug::debugfile;

void Debug::close() {
	if (!initialized)
		return;
	debugfile.close();
	initialized = false;
	return;
}

ofstream& Debug::error() {
	debugfile << "[" << printTime() << "] [ERROR  ] ";
	return debugfile;
}

ofstream& Debug::info() {
	debugfile << "[" << printTime() << "] [INFO   ] ";
	return debugfile;
}

ofstream& Debug::notice() {
	debugfile << "[" << printTime() << "] [NOTICE ] ";
	return debugfile;
}

void Debug::open(const string& file) {
	if (initialized)
		close();
	initialized = true;
	debugfile.open(file.c_str(), ios_base::app);
}

ofstream& Debug::warning() {
	debugfile << "[" << printTime() << "] [WARNING] ";
	return debugfile;
}

string& Debug::printTime() {
	time_t rawtime;
	time(&rawtime);
	timestamp = asctime(localtime(&rawtime));
	return timestamp.erase(timestamp.size() - 1);
}
