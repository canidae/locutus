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

#include <fstream>
#include "Config.h"
#include "Debug.h"

using namespace std;

Config::Config() {
	/* load configuration from locutus.conf */
	ifstream config;
	config.open("locutus.conf");
	if (!config) {
		Debug::error() << "Unable to read file 'locutus.conf'" << endl;
		return;
	}
	string line;
	while (getline(config, line)) {
		if (line.size() <= 0)
			continue; // empty line?
		string::size_type setting_start = line.find_first_not_of(CONFIG_COMMENT CONFIG_WHITESPACE);
		if (setting_start == string::npos)
			continue; // not a setting
		string::size_type pos = line.find(CONFIG_COMMENT);
		if (pos != string::npos && pos < setting_start)
			continue; // comment
		pos = line.find(CONFIG_DELIMITER);
		if (pos == string::npos || pos < setting_start)
			continue; // not a setting, no '=' or it's before the key
		string::size_type value_start = line.find_first_not_of(CONFIG_WHITESPACE, pos + 1);
		if (value_start == string::npos)
			continue; // no value?

		/* get setting */
		string::size_type setting_length = line.find_last_not_of(CONFIG_WHITESPACE, pos - 1) + 1 - setting_start;
		string setting = line.substr(setting_start, setting_length);

		/* get value */
		string::size_type value_length = line.find_first_of(CONFIG_WHITESPACE, value_start);
		if (value_length != string::npos)
			value_length -= value_start;
		string value = line.substr(value_start, value_length);

		/* and store in map */
		settings[setting] = value;
	}
}

Config::~Config() {
}

/* methods */
string Config::getSettingValue(const string &setting) {
	map<string, string>::iterator s = settings.find(setting);
	if (s == settings.end())
		return "";
	return s->second;
}
