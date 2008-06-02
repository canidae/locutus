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
		int loadClassID(string name, string description);
		double loadSetting(int class_id, string key, double default_value, string description);
		int loadSetting(int class_id, string key, int default_value, string description);
		string loadSetting(int class_id, string key, string default_value, string description);

	private:
		/* variables */
		Locutus *locutus;
};
#endif
