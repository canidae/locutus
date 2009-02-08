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

#include "Debug.h"

using namespace std;

/* static variables */
bool Debug::initialized = false;
string Debug::timestamp;
ofstream Debug::debugfile;

/* static methods */
bool Debug::close() {
	if (!initialized)
		return true;
	debugfile.close();
	initialized = false;
	return true;
}

ofstream &Debug::error() {
	debugfile << "[" << printTime() << "] [ERROR  ] ";
	return debugfile;
}

ofstream &Debug::info() {
	debugfile << "[" << printTime() << "] [INFO   ] ";
	return debugfile;
}

ofstream &Debug::notice() {
	debugfile << "[" << printTime() << "] [NOTICE ] ";
	return debugfile;
}

bool Debug::open(const string &file) {
	if (initialized)
		close();
	initialized = true;
	debugfile.open(file.c_str(), ios_base::app);
	return true;
}

ofstream &Debug::warning() {
	debugfile << "[" << printTime() << "] [WARNING] ";
	return debugfile;
}

/* private static methods */
string &Debug::printTime() {
	time_t rawtime;
	time(&rawtime);
	timestamp = asctime(localtime(&rawtime));
	return timestamp.erase(timestamp.size() - 1);
}
