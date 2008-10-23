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
#define FORCE_GENRE_LOOKUP_KEY "force_genre_lookup"
#define FORCE_GENRE_LOOKUP_VALUE true
#define FORCE_GENRE_LOOKUP_DESCRIPTION "Always fetch genre (or tag) from Audioscrobbler when saving a file, even if genre tag already exist for the file."

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

class Audioscrobbler;
class Database;
class FileNamer;
class Matcher;
class Metafile;
class MusicBrainz;
//class PUIDGenerator;

class Locutus {
	public:
		explicit Locutus(Database *database);
		~Locutus();

		static void trim(std::string *text);

		long run();

	private:
		Audioscrobbler *audioscrobbler;
		Database *database;
		FileNamer *filenamer;
		Matcher *matcher;
		//PUIDGenerator *puidgen;
		MusicBrainz *musicbrainz;
		bool force_genre_lookup;
		std::list<std::string> dir_queue;
		std::list<std::string> file_queue;
		std::map<std::string, std::vector<Metafile *> > grouped_files;
		std::string duplicate_dir;
		std::string input_dir;
		std::string output_dir;

		void clearFiles();
		bool moveFile(Metafile *file, const std::string &filename);
		bool parseDirectory();
		bool parseFile();
		void removeGoneFiles();
		void scanFiles(const std::string &directory);
};
#endif
