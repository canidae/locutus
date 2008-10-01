#ifndef FILENAMER_H
#define FILENAMER_H
#define VARIOUS_ARTISTS_MBID "89ad4ac3-39f7-470e-963a-56509c546377"
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

#include <map>
#include <string>

class Database;
class Metafile;

class FileNamer {
	public:
		FileNamer(Database *database);
		~FileNamer();

		const std::string &getFilename(Metafile *file);

	private:
		Database *database;
		std::string filename;
		std::string file_format;
		std::map<std::string, int> format_mapping;
};
#endif
