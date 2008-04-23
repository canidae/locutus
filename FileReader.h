#ifndef FILEREADER_H
/* defines */
#define FILEREADER_H

/* includes */
#include <cc++/thread.h>
#include "Locutus.h"

/* namespaces */
using namespace ost;
using namespace std;

/* FileReader */
class FileReader : public Thread {
	public:
		/* variables */

		/* constructors */
		FileReader(Locutus *locutus);

		/* destructors */
		~FileReader();

		/* methods */
		void stop();
		void run();

	private:
		/* variables */
		Locutus *locutus;
		bool active;

		/* methods */
};
#endif
