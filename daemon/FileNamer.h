// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
// 
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
// 
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef FILENAMER_H
#define FILENAMER_H

#include <iconv.h>
#include <string>
#include <vector>

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
#define TYPE_EQ 108
#define TYPE_BYTES_LEFT 109
#define TYPE_BYTES_RIGHT 110
#define TYPE_EXTENSION 111

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

	const std::string &getFilename(const Metafile &file);

private:
	Database *database;
	std::string filename;
	std::string file_format;
	std::string illegal_characters;
	std::vector<Field> fields;
	iconv_t u2w;
	iconv_t w2u;

	void convertIllegalCharacters(std::string *text);
	std::wstring convertUnicodeToWide(const std::string &text);
	std::string convertWideToUnicode(const std::wstring &text);
	const std::string parseField(const Metafile &file, const std::vector<Field>::const_iterator field);
	void removeEscapes(std::string *text);
	void setupFields(std::string::size_type start, std::string::size_type stop, std::vector<Field> *fields, bool split_on_comma = false);
};
#endif
