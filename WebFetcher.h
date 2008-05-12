#ifndef WEBFETCHER_H
/* defines */
#define WEBFETCHER_H
/* setting class */
#define WEBFETCHER_CLASS "WebFetcher"
#define WEBFETCHER_CLASS_DESCRIPTION "TODO"
/* default values */
#define PUID_MIN_MATCH_KEY "puid_min_match"
#define PUID_MIN_MATCH_VALUE 0.50
#define PUID_MIN_MATCH_DESCRIPTION "Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0"

/* forward declare */
class WebFetcher;

/* includes */
#include <list>
#include <string>
#include "Album.h"
#include "Locutus.h"

/* namespaces */
using namespace std;

/* WebFetcher */
class WebFetcher {
	public:
		/* variables */

		/* constructors */
		WebFetcher(Locutus *locutus);

		/* destructors */
		~WebFetcher();

		/* methods */
		void loadSettings();
		void lookup();

	private:
		/* variables */
		Locutus *locutus;
		int setting_class_id;
		double puid_min_match;
};
#endif
