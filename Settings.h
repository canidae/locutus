#ifndef SETTINGS_H
/* defines */
#define SETTINGS_H

/* forward declare */
class Settings;

/* includes */
#include <string>
#include "Locutus.h"

/* namespaces */
using namespace std;

/* Settings */
class Settings {
	public:
		/* constructors */
		Settings(Locutus *locutus);

		/* destructors */
		~Settings();

		/* methods */
		int loadClassID(const string &name, const string &description) const;
		double loadSetting(int class_id, const string &key, double default_value, const string &description) const;
		int loadSetting(int class_id, const string &key, int default_value, const string &description) const;
		string loadSetting(int class_id, const string &key, const string &default_value, const string &description) const;

	private:
		/* variables */
		Locutus *locutus;
};
#endif
