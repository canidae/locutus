#include <ostream>
#include "Database.h"
#include "Debug.h"
#include "FileNamer.h"
#include "Metafile.h"

using namespace std;

/* constructors/destructor */
FileNamer::FileNamer(Database *database) : database(database) {
	file_format = database->loadSettingString(FILENAME_FORMAT_KEY, FILENAME_FORMAT_VALUE, FILENAME_FORMAT_DESCRIPTION);
	illegal_characters = database->loadSettingString(FILENAME_ILLEGAL_CHARACTERS_KEY, FILENAME_ILLEGAL_CHARACTERS_VALUE, FILENAME_ILLEGAL_CHARACTERS_DESCRIPTION);
	string::size_type pos = illegal_characters.find('_', 0);
	if (pos != string::npos)
		illegal_characters.erase(pos, 1); // some idiot added "_" to illegal_characters

	setupFields(0, file_format.size(), &fields);
}

FileNamer::~FileNamer() {
}

/* methods */
const string &FileNamer::getFilename(Metafile *file) {
	filename.clear();
	for (vector<Field>::const_iterator f = fields.begin(); f != fields.end(); ++f)
		filename.append(parseField(file, f));
	convertIllegalCharacters(&filename);
	return filename;
}

/* private methods */
void FileNamer::convertIllegalCharacters(string *text) {
	string::size_type pos = 0;
	while ((pos = text->find_first_of(illegal_characters), pos) != string::npos)
		text->replace(pos, 1, "_");
}

const std::string &FileNamer::parseField(Metafile *file, const vector<Field>::const_iterator field) {
	tmp_field.clear();
	switch (field->type) {
		/* static */
		case TYPE_STATIC:
			return field->data;

		/* variables */
		case TYPE_ALBUM:
			return file->album;

		case TYPE_ALBUMARTIST:
			return file->albumartist;

		case TYPE_ALBUMARTISTSORT:
			return file->albumartistsort;

		case TYPE_ARTIST:
			return file->artist;

		case TYPE_ARTISTSORT:
			return file->artistsort;

		case TYPE_MUSICBRAINZ_ALBUMARTISTID:
			return file->musicbrainz_albumartistid;

		case TYPE_MUSICBRAINZ_ALBUMID:
			return file->musicbrainz_albumid;

		case TYPE_MUSICBRAINZ_ARTISTID:
			return file->musicbrainz_artistid;

		case TYPE_MUSICBRAINZ_TRACKID:
			return file->musicbrainz_trackid;

		case TYPE_MUSICIP_PUID:
			return file->puid;

		case TYPE_TITLE:
			return file->title;

		case TYPE_TRACKNUMBER:
			return file->tracknumber;

		case TYPE_DATE:
			return file->released;

		case TYPE_GENRE:
			return file->genre;

		/* functions */
		case TYPE_IF:
			/* return field->fields[1] if field->fields[0] is not empty,
			 * otherwise return field->fields[2] */
			if (field->fields.size() == 3) {
				vector<Field>::const_iterator f = field->fields.begin();
				if (parseField(file, f++) != "")
					return (parseField(file, f));
				return (parseField(file, ++f));
			}
			break;

		case TYPE_COALESCE:
			/* return first non-empty field */
			for (vector<Field>::const_iterator f = field->fields.begin(); f != field->fields.end(); ++f) {
				if (parseField(file, f) != "")
					return tmp_field;
			}
			break;

		case TYPE_LOWER:
			/* return data in lower case */
			if (field->fields.size() == 1) {
				ostringstream tmp;
				tmp << nouppercase << parseField(file, field->fields.begin());
				tmp_field = tmp.str();
				return tmp_field;
			}
			break;

		case TYPE_UPPER:
			/* return data in upper case */
			if (field->fields.size() == 1) {
				ostringstream tmp;
				tmp << uppercase << parseField(file, field->fields.begin());
				tmp_field = tmp.str();
				return tmp_field;
			}
			break;

		/* error */
		default:
			Debug::warning() << "Field not implemented. Type: " << field->type << ", data: " << field->data << ", fields: " << field->fields.size() << endl;
			break;
	}
	return tmp_field;
}

void FileNamer::removeEscapes(string *text) {
	/* remove backslashes properly */
	if (text == NULL || text->size() <= 0)
		return;
	string::size_type pos = -1;
	while (pos - 1 < text->size() && (pos = text->find('\\', pos + 1)) != string::npos)
		text->erase(pos, 1);
}

void FileNamer::setupFields(string::size_type start, string::size_type stop, vector<Field> *fields) {
	/* setup fields for filename pattern */
	string::size_type pos = start - 1;
	string::size_type prev = start;
	while ((pos = file_format.find_first_of("%$", pos + 1)) < stop && pos != string::npos) {
		int backslashes = 0;
		for (string::size_type a = pos - 1; a >= 0; --a) {
			if (file_format[a] != '\\')
				break;
			++backslashes;
		}
		if (backslashes % 2 == 0)
			continue; // this '%' or '$' is escaped, neither variable nor function
		if (prev < pos) {
			/* static field before variable/function */
			Field f;
			f.type = TYPE_STATIC;
			f.data = file_format.substr(prev, pos - prev);
			removeEscapes(&f.data);
			fields->push_back(f);
		}
		if (file_format[pos] == '%') {
			/* variable */
			int type;
			if (file_format.find("%musicbrainz_albumartistid%", pos) == 0)
				type = TYPE_MUSICBRAINZ_ALBUMARTISTID;
			else if (file_format.find("%musicbrainz_artistid%", pos) == 0)
				type = TYPE_MUSICBRAINZ_ARTISTID;
			else if (file_format.find("%musicbrainz_albumid%", pos) == 0)
				type = TYPE_MUSICBRAINZ_ALBUMID;
			else if (file_format.find("%musicbrainz_trackid%", pos) == 0)
				type = TYPE_MUSICBRAINZ_TRACKID;
			else if (file_format.find("%albumartistsort%", pos) == 0)
				type = TYPE_ALBUMARTISTSORT;
			else if (file_format.find("%musicip_puid%", pos) == 0)
				type = TYPE_MUSICIP_PUID;
			else if (file_format.find("%albumartist%", pos) == 0)
				type = TYPE_ALBUMARTIST;
			else if (file_format.find("%tracknumber%", pos) == 0)
				type = TYPE_TRACKNUMBER;
			else if (file_format.find("%artistsort%", pos) == 0)
				type = TYPE_ARTISTSORT;
			else if (file_format.find("%artist%", pos) == 0)
				type = TYPE_ARTIST;
			else if (file_format.find("%album%", pos) == 0)
				type = TYPE_ALBUM;
			else if (file_format.find("%genre%", pos) == 0)
				type = TYPE_GENRE;
			else if (file_format.find("%title%", pos) == 0)
				type = TYPE_TITLE;
			else if (file_format.find("%date%", pos) == 0)
				type = TYPE_DATE;
			else
				continue; // not matching any variable, must be static entry
			/* set pos to end '%' */
			pos = file_format.find("%", pos + 1);
			/* set prev to char after '%' */
			prev = pos + 1;
			/* add variable to field list */
			Field f;
			f.type = type;
			f.data = "";
			fields->push_back(f);
		} else if (file_format[pos] == '$') {
			/* function */
			int type;
			if (file_format.find("$coalesce(", pos) == 0)
				type = TYPE_COALESCE;
			else if (file_format.find("$lower(", pos) == 0)
				type = TYPE_LOWER;
			else if (file_format.find("$upper(", pos) == 0)
				type = TYPE_UPPER;
			else if (file_format.find("$if(", pos) == 0)
				type = TYPE_IF;
			else
				continue; // not matching any function, must be static entry
			/* find end parenthese */
			string::size_type end = pos;
			while ((end = file_format.find(")", end + 1)) != string::npos) {
				int backslashes = 0;
				for (string::size_type a = end - 1; a >= 0; --a) {
					if (file_format[a] != '\\')
						break;
					++backslashes;
				}
				if (backslashes % 2 == 0)
					break; // this parenthese is escaped, not the end parenthese
			}
			if (end == string::npos) {
				/* no end parenthese?
				 * user probably did something wrong or it's a static entry */
				continue;
			}
			/* set up function */
			Field f;
			f.type = type;
			f.data = "";
			/* call this method recursively for fields within parentheses in this function */
			setupFields(file_format.find("(", pos + 1) + 1, end - 1, &f.fields);
			/* add function to field list */
			fields->push_back(f);
			/* set pos to end parenthese */
			pos = end;
			/* set prev to char after end parenthese */
			prev = pos + 1;
		}
	}
	if (prev < stop) {
		/* static field after last variable/function */
		Field f;
		f.type = TYPE_STATIC;
		f.data = file_format.substr(prev);
		removeEscapes(&f.data);
		fields->push_back(f);
	}
}
