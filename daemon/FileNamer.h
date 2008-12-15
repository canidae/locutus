#ifndef FILENAMER_H
#define FILENAMER_H
#define VARIOUS_ARTISTS_MBID "89ad4ac3-39f7-470e-963a-56509c546377"
/* settings */
#define FILENAME_FORMAT_KEY "filename_format"
#define FILENAME_FORMAT_VALUE "%albumartist%/%album%/%tracknumber% - %artist% - %title%"
#define FILENAME_FORMAT_DESCRIPTION "Output filename format. Available keys: %album%, %albumartist%, %albumartistsort%, %artist%, %artistsort%, %musicbrainz_albumartistid%, %musicbrainz_albumid%, %musicbrainz_artistid%, %musicbrainz_trackid%, %musicip_puid%, %title%, %tracknumber%, %date%, %custom_artist%, %genre%."
#define FILENAME_ILLEGAL_CHARACTERS_KEY "filename_illegal_characters"
#define FILENAME_ILLEGAL_CHARACTERS_VALUE "/"
#define FILENAME_ILLEGAL_CHARACTERS_DESCRIPTION "Characters in metadata that will be converted to '_' in filename."
/* types */
/* static */
#define TYPE_STATIC 0
/* variables */
#define TYPE_ALBUM 1
#define TYPE_ALBUMARTIST 2
#define TYPE_ALBUMARTISTSORT 3
#define TYPE_ARTIST 4
#define TYPE_ARTISTSORT 5
#define TYPE_MUSICBRAINZ_ALBUMARTISTID 6
#define TYPE_MUSICBRAINZ_ALBUMID 7
#define TYPE_MUSICBRAINZ_ARTISTID 8
#define TYPE_MUSICBRAINZ_TRACKID 9
#define TYPE_MUSICIP_PUID 10
#define TYPE_TITLE 11
#define TYPE_TRACKNUMBER 12
#define TYPE_DATE 13
#define TYPE_GENRE 14
/* delimiter */
#define TYPE_DELIMITER 100
/* functions */
#define TYPE_IF 101
#define TYPE_COALESCE 102
#define TYPE_LOWER 103
#define TYPE_UPPER 104
#define TYPE_LEFT 105
#define TYPE_RIGHT 106
#define TYPE_NUM 107

#include <string>
#include <vector>

struct Field {
	int type;
	std::string data;
	std::vector<Field> fields;
};

class Database;
class Metafile;

class FileNamer {
	public:
		explicit FileNamer(Database *database);
		~FileNamer();

		const std::string &getFilename(Metafile *file);

	private:
		Database *database;
		std::string filename;
		std::string tmp_field;
		std::string file_format;
		std::string illegal_characters;
		std::vector<Field> fields;

		void convertIllegalCharacters(std::string *text);
		const std::string &parseField(Metafile *file, const std::vector<Field>::const_iterator field);
		void removeEscapes(std::string *text);
		void setupFields(std::string::size_type start, std::string::size_type stop, std::vector<Field> *fields, bool split_on_comma = false);
};
#endif
