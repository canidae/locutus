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

#ifndef DEBUG_H
#define DEBUG_H

extern "C" {
#include <sys/stat.h>
};
#include <fstream>
#include <iostream>
#include <string>

class Debug {
public:
	static std::ofstream debugfile;

	static bool close();
	static std::ofstream &error();
	static std::ofstream &info();
	static bool open(const std::string &file);
	static std::ofstream &notice();
	static std::ofstream &warning();

private:
	static bool initialized;
	static std::string timestamp;

	static std::string &printTime();
};
#endif
