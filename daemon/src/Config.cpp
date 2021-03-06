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

/* methods */
string Config::getSettingValue(const string& setting) const {
	map<string, string>::const_iterator s = settings.find(setting);
	if (s == settings.end())
		return "";
	return s->second;
}
