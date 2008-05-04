#ifndef PUIDGENERATOR_H
/* defines */
#define PUIDGENERATOR_H
/* setting class */
#define PUIDGENERATOR_CLASS "PUIDGenerator"
#define PUIDGENERATOR_CLASS_DESCRIPTION "TODO"

/* forward declare */
class PUIDGenerator;

/* includes */
#include <cc++/thread.h>
#include <string>
#include "Locutus.h"

/* namespaces */
using namespace ost;
using namespace std;

/* PUIDGenerator */
class PUIDGenerator : public Thread {
	public:
		/* variables */

		/* constructors */
		PUIDGenerator(Locutus *locutus);

		/* destructors */
		~PUIDGenerator();

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
};
#endif
