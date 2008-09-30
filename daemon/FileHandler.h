#ifndef FILEHANDLER_H
#define FILEHANDLER_H
#define VARIOUS_ARTISTS_MBID "89ad4ac3-39f7-470e-963a-56509c546377"
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
/* file naming */
#define TYPE_ALBUM 0
#define TYPE_ALBUMARTIST 1
#define TYPE_ALBUMARTISTSORT 2
#define TYPE_ARTIST 3
#define TYPE_ARTISTSORT 4
#define TYPE_MUSICBRAINZ_ALBUMARTISTID 5
#define TYPE_MUSICBRAINZ_ALBUMID 6
#define TYPE_MUSICBRAINZ_ARTISTID 7
#define TYPE_MUSICBRAINZ_TRACKID 8
#define TYPE_MUSICIP_PUID 9
#define TYPE_TITLE 10
#define TYPE_TRACKNUMBER 11
#define TYPE_DATE 12
#define TYPE_CUSTOM_ARTIST 13 // custom_artist_sortname, albumartistsort (unless va), artistsort
#define FILENAME_FORMAT_KEY "filename_format"
#define FILENAME_FORMAT_VALUE "%custom_artist%/%album% - %tracknumber% - %artist% - %title%"
#define FILENAME_FORMAT_DESCRIPTION "Output filename format. Available keys: %album%, %albumartist%, %albumartistsort%, %artist%, %artistsort%, %musicbrainz_albumartistid%, %musicbrainz_albumid%, %musicbrainz_artistid%, %musicbrainz_trackid%, %musicip_puid%, %title%, %tracknumber%, %date%, %custom_artist%."

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

/* XXX */
#include "Database.h"

class Locutus;
class Metafile;
class Track;

class FileHandler {
	public:
		/* variables */
		bool ready;
		std::string duplicate_dir;
		std::string input_dir;
		std::string output_dir;

		/* constructors/destructor */
		FileHandler(Locutus *locutus);
		~FileHandler();

		/* methods */
		void loadSettings();
		void saveFiles(const std::map<Metafile *, Track*> &files);
		void scanFiles(const std::string &directory);

	private:
		/* variables */
		Locutus *locutus;
		std::list<std::string> dir_queue;
		std::list<std::string> file_queue;
		std::string file_format;
		std::map<std::string, int> format_mapping;

		/* methods */
		bool moveFile(Metafile *file);
		bool parseDirectory();
		bool parseFile();
};
#endif
