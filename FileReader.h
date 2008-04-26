#ifndef FILEREADER_H
/* defines */
#define FILEREADER_H
/* music locations */
#define MUSIC_SORTED_KEY "sorted_directory"
#define MUSIC_SORTED_VALUE "/music/sorted/"
#define MUSIC_UNSORTED_KEY "unsorted_directory"
#define MUSIC_UNSORTED_VALUE "/music/unsorted/"

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
		int setting_class_id;

		/* methods */
		bool loadSettings();
		bool parseDirectory();
		bool parseFile();
};
#endif
