#ifndef WEBFETCHER_H
/* defines */
#define WEBFETCHER_H
/* setting class */
#define WEBFETCHER_CLASS "WebFetcher"
#define WEBFETCHER_CLASS_DESCRIPTION "TODO"

/* forward declare */
class WebFetcher;

/* includes */
#include <cc++/thread.h>
#include <string>
#include "Locutus.h"

/* namespaces */
using namespace ost;
using namespace std;

/* WebFetcher */
class WebFetcher : public Thread {
	public:
		/* variables */

		/* constructors */
		WebFetcher(Locutus *locutus);

		/* destructors */
		~WebFetcher();

		/* methods */
		void loadSettings();
		void quit();
		void run();

	private:
		/* variables */
		Locutus *locutus;
		bool active;
		int setting_class_id;

		/* methods */
		bool lookup();
};
#endif
