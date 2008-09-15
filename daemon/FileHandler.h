#ifndef FILEHANDLER_H
/* defines */
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
/* album
 * albumartist
 * albumartistsort
 * artist
 * artistsort
 * musicbrainz_albumartistid
 * musicbrainz_albumid
 * musicbrainz_artistid
 * musicbrainz_trackid
 * musicip_puid
 * title
 * tracknumber
 * date
 *
 * custom_artist = custom_artist_sortname, albumartistsort (unless va), artistsort
 */
#define FILENAME_FORMAT_KEY "filename_format"
#define FILENAME_FORMAT_VALUE "%1custom_artist/%custom_artist/%album - %tracknumber - %artist - %title"
#define FILENAME_FORMAT_DESCRIPTION "Output filename format. Available keys: %album, %albumartist, %albumartistsort, %artist, %artistsort, %musicbrainz_albumartistid, %musicbrainz_albumid, %musicbrainz_artistid, %musicbrainz_trackid, %musicip_puid, %title, %tracknumber, %date, %custom_artist. Specify a number after '%' and before the key to limit the length of the value"

/* forward declare */
class FileHandler;

/* includes */
#include <list>
#include <map>
#include <string>
#include "Database.h"
#include "Locutus.h"
#include "Metafile.h"
#include "Track.h"

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
		void saveFiles(const map<Metafile *, Track*> &files);
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
