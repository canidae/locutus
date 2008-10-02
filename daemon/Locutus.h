#ifndef LOCUTUS_H
#define LOCUTUS_H
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

extern "C" {
#include <dirent.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
};
#include <list>
#include <map>
#include <string>
#include <vector>

class Database;
class FileNamer;
class Matcher;
class Metafile;
class PUIDGenerator;
class Track;
class WebService;

class Locutus {
	public:
		/* FIXME: these variables should be private */
		Database *database;
		WebService *webservice;
		FileNamer *filenamer;
		PUIDGenerator *puidgen;
		Matcher *matcher;

		explicit Locutus(Database *database);
		~Locutus();

		long run();

	private:
		std::vector<Metafile *> files;
		std::map<std::string, std::vector<Metafile *> > grouped_files;
		std::list<std::string> dir_queue;
		std::list<std::string> file_queue;
		std::string duplicate_dir;
		std::string input_dir;
		std::string output_dir;

		void clearFiles();
		bool moveFile(Metafile *file, const std::string &filename);
		bool parseDirectory();
		bool parseFile();
		void removeGoneFiles();
		void scanDirectory(const std::string &directory);
		void scanFiles(const std::string &directory);
};
#endif
