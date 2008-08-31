#ifndef FILEREADER_H
/* defines */
#define FILEREADER_H
/* settings */
#define MUSIC_OUTPUT_KEY "output_directory"
#define MUSIC_OUTPUT_VALUE "/music/sorted/"
#define MUSIC_OUTPUT_DESCRIPTION "Output directory"
#define MUSIC_INPUT_KEY "input_directory"
#define MUSIC_INPUT_VALUE "/music/unsorted/"
#define MUSIC_INPUT_DESCRIPTION "Input directory"
#define MUSIC_DUPLICATE_KEY "duplicate_directory"
#define MUSIC_DUPLICATE_VALUE "/music/duplicates/"
#define MUSIC_DUPLICATE_DESCRIPTION "Directory for duplicate files"

/* forward declare */
class FileReader;

/* includes */
#include <list>
#include <string>
#include "Locutus.h"
#include "Metafile.h"

/* namespaces */
using namespace std;

/* FileReader */
class FileReader {
	public:
		/* variables */
		bool ready;
		string duplicate_dir;
		string input_dir;
		string output_dir;

		/* constructors */
		FileReader(Locutus *locutus);

		/* destructors */
		~FileReader();

		/* methods */
		void loadSettings();
		void scanFiles(const string &directory);

	private:
		/* variables */
		Locutus *locutus;
		list<string> dir_queue;
		list<string> file_queue;
		int setting_class_id;

		/* methods */
		bool parseDirectory();
		bool parseFile();
};
#endif
