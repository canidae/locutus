#ifndef WEBFETCHER_H
/* defines */
#define WEBFETCHER_H
/* setting class */
#define WEBFETCHER_CLASS "WebFetcher"
#define WEBFETCHER_CLASS_DESCRIPTION "TODO"

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
};
#endif
