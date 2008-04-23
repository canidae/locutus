#ifndef FILEREADER_H
/* defines */
#define FILEREADER_H

/* forward declare */
class FileReader;

/* includes */
#include <cc++/thread.h>
#include <list>
#include <string>
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
		list<string> dir_queue;
		list<string> file_queue;

		/* methods */
		bool parseDirectory();
		bool parseFile();
};
#endif
