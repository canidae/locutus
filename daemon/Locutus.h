#ifndef LOCUTUS_H
#define LOCUTUS_H
/* settings */
#define MUSIC_OUTPUT_KEY "output_directory"
#define MUSIC_OUTPUT_VALUE "/media/music/sorted/"
#define MUSIC_OUTPUT_DESCRIPTION "Output directory"
#define MUSIC_INPUT_KEY "input_directory"
#define MUSIC_INPUT_VALUE "/media/music/unsorted/"
#define MUSIC_INPUT_DESCRIPTION "Input directory"
#define LOOKUP_GENRE_KEY "lookup_genre"
#define LOOKUP_GENRE_VALUE true
#define LOOKUP_GENRE_DESCRIPTION "Fetch genre (or tag) from Audioscrobbler before saving a file. If no genre is found then genre is set to an empty string. If this option is set to false, the genre field is left unmodified."

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
		bool lookup_genre;
		std::list<std::string> dir_queue;
		std::list<std::string> file_queue;
		std::map<std::string, std::vector<Metafile *> > grouped_files;
		std::string input_dir;
		std::string output_dir;

		void clearFiles();
		std::string findDuplicateFilename(Metafile *file);
		bool moveFile(Metafile *file, const std::string &filename);
		bool parseDirectory();
		bool parseFile();
		void removeGoneFiles();
		void saveFile(Metafile *file);
		void scanFiles(const std::string &directory);
};
#endif
