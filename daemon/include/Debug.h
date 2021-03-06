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

#ifndef DEBUG_H
#define DEBUG_H

#include <fstream>
#include <string>

class Debug {
public:
	static void open(const std::string& file);
	static void close();
	static std::ofstream& info();
	static std::ofstream& notice();
	static std::ofstream& warning();
	static std::ofstream& error();

private:
	static bool initialized;
	static std::string timestamp;
	static std::ofstream debugfile;

	static std::string& getTime();
};
#endif
