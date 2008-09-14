#ifndef FILEHANDLER_H
/* defines */
#define FILEHANDLER_H
/* settings */
#define MUSIC_OUTPUT_KEY "output_directory"
#define MUSIC_OUTPUT_VALUE "/media/music/sorted/"
#define MUSIC_OUTPUT_DESCRIPTION "Output directory"
#define MUSIC_INPUT_KEY "input_directory"
#define MUSIC_INPUT_VALUE "/media/music/unsorted/"
#define MUSIC_INPUT_DESCRIPTION "Input directory"
#define MUSIC_DUPLICATE_KEY "duplicate_directory"
#define MUSIC_DUPLICATE_VALUE "/media/music/duplicates/"
#define MUSIC_DUPLICATE_DESCRIPTION "Directory for duplicate files"

/* forward declare */
class FileHandler;

/* includes */
#include <list>
#include <string>
#include "Locutus.h"
#include "Metafile.h"

/* namespaces */
using namespace std;

/* FileHandler */
class FileHandler {
	public:
		/* variables */
		bool ready;
		string duplicate_dir;
		string input_dir;
		string output_dir;

		/* constructors */
		FileHandler(Locutus *locutus);

		/* destructors */
		~FileHandler();

		/* methods */
		void loadSettings();
		void scanFiles(const string &directory);

	private:
		/* variables */
		Locutus *locutus;
		list<string> dir_queue;
		list<string> file_queue;

		/* methods */
		bool parseDirectory();
		bool parseFile();
};
#endif
