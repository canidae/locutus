#ifndef FILEREADER_H
/* defines */
#define FILEREADER_H
/* setting class */
#define FILEREADER_CLASS "FileReader"
#define FILEREADER_CLASS_DESCRIPTION "TODO"
/* music locations */
#define MUSIC_SORTED_KEY "sorted_directory"
#define MUSIC_SORTED_VALUE "/music/sorted/"
#define MUSIC_SORTED_DESCRIPTION "Output directory"
#define MUSIC_UNSORTED_KEY "unsorted_directory"
#define MUSIC_UNSORTED_VALUE "/music/unsorted/"
#define MUSIC_UNSORTED_DESCRIPTION "Input directory"

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
		string input_dir;
		string output_dir;

		/* methods */
		void loadSettings();
		bool parseDirectory();
		bool parseFile();
};
#endif
