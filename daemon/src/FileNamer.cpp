// Copyright © 2008-2009 Vidar Wahlberg <canidae@exent.net>
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

#include <ostream>
#include <stdlib.h>
#include <string.h>
#include <taglib/tstring.h>
#include "Database.h"
#include "Debug.h"
#include "FileNamer.h"
#include "Metafile.h"

using namespace std;

FileNamer::FileNamer(Database *database) : database(database) {
	/* set up iconv */
	u2w = iconv_open("WCHAR_T", "UTF8");
	w2u = iconv_open("UTF8", "WCHAR_T");

	/* test file format */
	/*
	Metafile f("/media/music/unsorted/Within Temptation - The Silent Force (Limited Premium Edition)/12. A Dangerous Mind (Bonus Track).mp3");
	f.album = "The Silent Force";
	f.albumartist = "Within Temptation";
	f.albumartistsort = "Within Temptation";
	f.artist = "Within Temptation, ÆØÅæøå";
	f.artistsort = "Within Temptation";
	f.musicbrainz_albumartistid = "eace2373-31c8-4aba-9a5c-7bce22dd140a";
	f.musicbrainz_albumid = "7d4af6bd-62de-4b0f-a39b-3fbd337416a7";
	f.musicbrainz_artistid = "eace2373-31c8-4aba-9a5c-7bce22dd140a";
	f.musicbrainz_trackid = "fba916cf-8324-4941-a8b3-5dfb4e424456";
	f.title = "A Dangerous Mind, ÆØÅæøå";
	f.tracknumber = "12";
	f.released = "2004-11-15";
	f.genre = "gothic rock";
	file_format = "$if($eq(%musicbrainz_albumartistid%,89ad4ac3-39f7-470e-963a-56509c546377),$left(%artistsort%,1)/%artistsort%,$left(%albumartistsort%,1)/%albumartistsort%)/%album% - $num(%tracknumber%,2) - %artist% - %title%";
	setupFields(0, file_format.size(), &fields);
	cout << getFilename(&f) << endl;
	fields.clear();
	*/
	/* end testing file format */

	file_format = database->loadSettingString(FILENAME_FORMAT_KEY, FILENAME_FORMAT_VALUE, FILENAME_FORMAT_DESCRIPTION);
	illegal_characters = database->loadSettingString(FILENAME_ILLEGAL_CHARACTERS_KEY, FILENAME_ILLEGAL_CHARACTERS_VALUE, FILENAME_ILLEGAL_CHARACTERS_DESCRIPTION);
	string::size_type pos = illegal_characters.find('_', 0);
	if (pos != string::npos)
		illegal_characters.erase(pos, 1); // some idiot added "_" to illegal_characters

	setupFields(0, file_format.size(), &fields);
}

FileNamer::~FileNamer() {
	/* close iconv */
	iconv_close(u2w);
	iconv_close(w2u);
}

const string &FileNamer::getFilename(const Metafile &file) {
	filename.clear();
	for (vector<Field>::const_iterator f = fields.begin(); f != fields.end(); ++f)
		filename.append(parseField(file, f));
	return filename;
}

void FileNamer::convertIllegalCharacters(string *text) {
	string::size_type pos = 0;
	while ((pos = text->find_first_of(illegal_characters), pos) != string::npos)
		text->replace(pos, 1, "_");
}

wstring FileNamer::convertUnicodeToWide(const string &text) {
	if (text.size() <= 0)
		return wstring(L"");
	char src[text.size()];
	char *src_ptr = (char *) src;
	size_t src_size = sizeof (src);
	wchar_t dest[text.size()];
	char *dest_ptr = (char *) dest;
	size_t dest_size = sizeof (dest);
	for (string::size_type a = 0; a < text.size(); ++a)
		src[a] = text[a];
	if (iconv(u2w, &src_ptr, &src_size, &dest_ptr, &dest_size) == (size_t) -1)
		Debug::warning() << "Unable to convert unicode string to wide character string: " << text << endl;
	return wstring(dest, (sizeof (dest) - dest_size) / sizeof (wchar_t));
}

string FileNamer::convertWideToUnicode(const wstring &text) {
	if (text.size() <= 0)
		return string("");
	wchar_t src[text.size()];
	char *src_ptr = (char *) src;
	size_t src_size = sizeof (src);
	char dest[text.size() * sizeof (wchar_t)];
	char *dest_ptr = (char *) dest;
	size_t dest_size = sizeof (dest);
	for (wstring::size_type a = 0; a < text.size(); ++a)
		src[a] = text[a];
	if (iconv(w2u, &src_ptr, &src_size, &dest_ptr, &dest_size) == (size_t) -1)
		Debug::warning() << "Unable to convert wide character string to unicode string: " << text << endl;
	return string(dest, (sizeof (dest) - dest_size));
}

const std::string FileNamer::parseField(const Metafile &file, const vector<Field>::const_iterator field) {
	string tmp_field("");
	string::size_type pos;
	switch (field->type) {
		/* static */
		case TYPE_STATIC:
			/* we do not convert illegal characters from static entries.
			 * directory separators are set here */
			return field->data;

		/* variables */
		case TYPE_ALBUM:
			tmp_field = file.album;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_ALBUMARTIST:
			tmp_field = file.albumartist;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_ALBUMARTISTSORT:
			tmp_field = file.albumartistsort;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_ARTIST:
			tmp_field = file.artist;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_ARTISTSORT:
			tmp_field = file.artistsort;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_MUSICBRAINZ_ALBUMARTISTID:
			tmp_field = file.musicbrainz_albumartistid;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_MUSICBRAINZ_ALBUMID:
			tmp_field = file.musicbrainz_albumid;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_MUSICBRAINZ_ARTISTID:
			tmp_field = file.musicbrainz_artistid;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_MUSICBRAINZ_TRACKID:
			tmp_field = file.musicbrainz_trackid;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_TITLE:
			tmp_field = file.title;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_TRACKNUMBER:
			tmp_field = file.tracknumber;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_DATE:
			tmp_field = file.released;
			convertIllegalCharacters(&tmp_field);
			break;

		case TYPE_GENRE:
			tmp_field = file.genre;
			convertIllegalCharacters(&tmp_field);
			break;

		/* delimiter */
		case TYPE_DELIMITER:
			/* we shouldn't call parseField() for delimiter type.
			 * this is not dangerous at all, but let's issue a notice */
			Debug::notice() << "Method 'parseFields()' was called for a delimiter field, please report this as a bug along with your 'filename_format' setting" << endl;
			break;

		/* functions */
		case TYPE_IF:
			/* return second non-delimiter field(s) if first non-delimiter field
			 * is empty, otherwise return third non-delimiter field(s) */
			if (field->fields.size() >= 5) {
				string tmp("");
				vector<Field>::const_iterator f = field->fields.begin();
				while (f != field->fields.end() && f->type != TYPE_DELIMITER)
					tmp.append(parseField(file, f++));
				if (f == field->fields.end()) {
					/* hmm, looks like user error */
					break;
				}
				++f;
				if (tmp.empty()) {
					/* "if" is empty, return 2nd non-delimiter field(s) */
					while (f != field->fields.end() && f->type != TYPE_DELIMITER)
						++f;
					if (f == field->fields.end()) {
						/* hmm, looks like user error */
						break;
					}
					++f;
				}
				tmp.clear();
				while (f != field->fields.end() && f->type != TYPE_DELIMITER)
					tmp.append(parseField(file, f++));
				tmp_field = tmp;
				break;
			}
			break;

		case TYPE_COALESCE:
			/* return first non-empty non-delimiter field */
			if (field->fields.size() > 0) {
				string tmp("");
				for (vector<Field>::const_iterator f = field->fields.begin(); f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER) {
						if (!tmp.empty()) {
							/* found a non-empty non-delimiter field */
							tmp_field = tmp;
							break;
						}
						continue;
					}
					tmp.append(parseField(file, f));
				}
			}
			break;

		case TYPE_LOWER:
			/* return data in lower case */
			if (field->fields.size() > 0) {
				string tmp("");
				for (vector<Field>::const_iterator f = field->fields.begin(); f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER)
						continue;
					tmp.append(parseField(file, f));
				}
				wstring tmp2 = convertUnicodeToWide(tmp);
				for (wstring::size_type a = 0; a < tmp2.size(); ++a)
					tmp2[a] = towlower(tmp2[a]);
				tmp_field = convertWideToUnicode(tmp2);
			}
			break;

		case TYPE_UPPER:
			/* return data in upper case */
			if (field->fields.size() > 0) {
				string tmp("");
				for (vector<Field>::const_iterator f = field->fields.begin(); f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER)
						continue;
					tmp.append(parseField(file, f));
				}
				wstring tmp2 = convertUnicodeToWide(tmp);
				for (wstring::size_type a = 0; a < tmp2.size(); ++a)
					tmp2[a] = towupper(tmp2[a]);
				tmp_field = convertWideToUnicode(tmp2);
			}
			break;

		case TYPE_LEFT:
			/* return first n characters */
			if (field->fields.size() >= 3) {
				string tmp("");
				vector<Field>::const_iterator f;
				for (f = field->fields.begin(); f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER) {
						++f;
						break;
					}
					tmp.append(parseField(file, f));
				}
				if (f != field->fields.end()) {
					int chars = atoi(parseField(file, f).c_str());
					if (chars < 0)
						chars = 0;
					wstring tmp2 = convertUnicodeToWide(tmp);
					if (chars < (int) tmp2.size())
						tmp2.erase(chars);
					tmp_field = convertWideToUnicode(tmp2);
				}
			}
			break;

		case TYPE_RIGHT:
			/* return last n characters */
			if (field->fields.size() >= 3) {
				string tmp("");
				vector<Field>::const_iterator f;
				for (f = field->fields.begin(); f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER) {
						++f;
						break;
					}
					tmp.append(parseField(file, f));
				}
				if (f != field->fields.end()) {
					int erase = atoi(parseField(file, f).c_str());
					wstring tmp2 = convertUnicodeToWide(tmp);
					erase = tmp2.size() - erase;
					if (erase > 0)
						tmp2.erase(0, erase);
					tmp_field = convertWideToUnicode(tmp2);
				}
			}
			break;

		case TYPE_NUM:
			/* zeropad text to n characters */
			if (field->fields.size() >= 3) {
				string tmp("");
				vector<Field>::const_iterator f;
				for (f = field->fields.begin(); f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER) {
						++f;
						break;
					}
					tmp.append(parseField(file, f));
				}
				if (f != field->fields.end()) {
					int chars = atoi(parseField(file, f).c_str());
					for (; chars > (int) tmp.size(); --chars)
						tmp_field.push_back('0');
					tmp_field.append(tmp);
				}
			}
			break;

		case TYPE_EQ:
			/* return "true" if fields are equal, "" if not */
			if (field->fields.size() >= 3) {
				string tmp("");
				vector<Field>::const_iterator f;
				for (f = field->fields.begin(); f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER) {
						++f;
						break;
					}
					tmp.append(parseField(file, f));
				}
				string tmp2("");
				for (; f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER)
						break;
					tmp2.append(parseField(file, f));
				}
				if (tmp == tmp2)
					tmp_field = "true";
				else
					tmp_field = "";
			}
			break;

		case TYPE_BYTES_LEFT:
			/* return first n bytes, without messing up characters */
			if (field->fields.size() >= 3) {
				string tmp("");
				vector<Field>::const_iterator f;
				for (f = field->fields.begin(); f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER) {
						++f;
						break;
					}
					tmp.append(parseField(file, f));
				}
				if (f != field->fields.end()) {
					int chars = atoi(parseField(file, f).c_str());
					if (chars < 0)
						chars = 0;
					wstring tmp2 = convertUnicodeToWide(tmp);
					if (chars < (int) tmp2.size())
						tmp2.erase(chars);
					tmp_field = convertWideToUnicode(tmp2);
					/* erase last character until size is less than our limit */
					while ((int) tmp_field.size() > chars) {
						wstring tmp2 = convertUnicodeToWide(tmp_field);
						tmp2.erase(tmp2.size() - 1);
						tmp_field = convertWideToUnicode(tmp2);
					}
				}
			}
			break;

		case TYPE_BYTES_RIGHT:
			/* return last n bytes, without messing up characters */
			if (field->fields.size() >= 3) {
				string tmp("");
				vector<Field>::const_iterator f;
				for (f = field->fields.begin(); f != field->fields.end(); ++f) {
					if (f->type == TYPE_DELIMITER) {
						++f;
						break;
					}
					tmp.append(parseField(file, f));
				}
				if (f != field->fields.end()) {
					int chars = atoi(parseField(file, f).c_str());
					wstring tmp2 = convertUnicodeToWide(tmp);
					int erase = tmp2.size() - chars;
					if (erase > 0)
						tmp2.erase(0, erase);
					tmp_field = convertWideToUnicode(tmp2);
					/* erase first character until size is less than our limit */
					while ((int) tmp_field.size() > chars) {
						wstring tmp2 = convertUnicodeToWide(tmp_field);
						tmp2.erase(0, 1);
						tmp_field = convertWideToUnicode(tmp2);
					}
				}
			}
			break;

		case TYPE_EXTENSION:
			/* filename extension */
			pos = file.filename.find_last_of('.');
			if (pos != string::npos)
				tmp_field = file.filename.substr(pos + 1);
			else
				tmp_field = "";
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

void FileNamer::setupFields(string::size_type start, string::size_type stop, vector<Field> *fields, bool split_on_comma) {
	/* setup fields for filename pattern */
	string::size_type pos = start - 1;
	string::size_type prev = start;
	Debug::info() << "Setting up fields for: " << file_format.substr(start, stop - start) << endl;
	while ((pos = file_format.find_first_of(",%$", pos + 1)) != string::npos && pos < stop) {
		if (!split_on_comma && file_format[pos] == ',')
			continue; // not using ',' as delimiter
		int backslashes = 0;
		for (string::size_type a = pos - 1; a < file_format.size(); --a) {
			if (file_format[a] != '\\')
				break;
			++backslashes;
		}
		if (backslashes % 2 != 0)
			continue; // this ',', '%' or '$' is escaped, neither delimiter, variable nor function
		if (prev < pos) {
			/* static field before delimiter/variable/function */
			Field f;
			f.type = TYPE_STATIC;
			f.data = file_format.substr(prev, pos - prev);
			removeEscapes(&f.data);
			fields->push_back(f);
			Debug::info() << "Adding static field: data = '" << f.data << "', prev = " << prev << ", pos = " << pos << endl;
		}
		if (file_format[pos] == ',') {
			/* delimiter */
			prev = pos + 1;
			Field f;
			f.type = TYPE_DELIMITER;
			f.data.clear();
			fields->push_back(f);
			Debug::info() << "Adding delimiter field: prev = " << prev << ", pos = " << pos << endl;
		} else if (file_format[pos] == '%') {
			/* variable */
			int type;
			if (file_format.find("%musicbrainz_albumartistid%", pos) == pos)
				type = TYPE_MUSICBRAINZ_ALBUMARTISTID;
			else if (file_format.find("%musicbrainz_artistid%", pos) == pos)
				type = TYPE_MUSICBRAINZ_ARTISTID;
			else if (file_format.find("%musicbrainz_albumid%", pos) == pos)
				type = TYPE_MUSICBRAINZ_ALBUMID;
			else if (file_format.find("%musicbrainz_trackid%", pos) == pos)
				type = TYPE_MUSICBRAINZ_TRACKID;
			else if (file_format.find("%albumartistsort%", pos) == pos)
				type = TYPE_ALBUMARTISTSORT;
			else if (file_format.find("%albumartist%", pos) == pos)
				type = TYPE_ALBUMARTIST;
			else if (file_format.find("%tracknumber%", pos) == pos)
				type = TYPE_TRACKNUMBER;
			else if (file_format.find("%artistsort%", pos) == pos)
				type = TYPE_ARTISTSORT;
			else if (file_format.find("%artist%", pos) == pos)
				type = TYPE_ARTIST;
			else if (file_format.find("%album%", pos) == pos)
				type = TYPE_ALBUM;
			else if (file_format.find("%genre%", pos) == pos)
				type = TYPE_GENRE;
			else if (file_format.find("%title%", pos) == pos)
				type = TYPE_TITLE;
			else if (file_format.find("%date%", pos) == pos)
				type = TYPE_DATE;
			else if (file_format.find("%ext%", pos) == pos)
				type = TYPE_EXTENSION;
			else
				continue; // not matching any variable, must be static entry
			/* set pos to end '%' */
			pos = file_format.find("%", pos + 1);
			/* set prev to char after '%' */
			prev = pos + 1;
			/* add variable to field list */
			Field f;
			f.type = type;
			f.data.clear();
			fields->push_back(f);
			Debug::info() << "Adding variable field: type = " << f.type << ", prev = " << prev << ", pos = " << pos << endl;
		} else if (file_format[pos] == '$') {
			/* function */
			int type;
			if (file_format.find("$bytes_right(", pos) == pos)
				type = TYPE_BYTES_RIGHT;
			else if (file_format.find("$bytes_left(", pos) == pos)
				type = TYPE_BYTES_LEFT;
			else if (file_format.find("$coalesce(", pos) == pos)
				type = TYPE_COALESCE;
			else if (file_format.find("$lower(", pos) == pos)
				type = TYPE_LOWER;
			else if (file_format.find("$right(", pos) == pos)
				type = TYPE_RIGHT;
			else if (file_format.find("$upper(", pos) == pos)
				type = TYPE_UPPER;
			else if (file_format.find("$left(", pos) == pos)
				type = TYPE_LEFT;
			else if (file_format.find("$num(", pos) == pos)
				type = TYPE_NUM;
			else if (file_format.find("$eq(", pos) == pos)
				type = TYPE_EQ;
			else if (file_format.find("$if(", pos) == pos)
				type = TYPE_IF;
			else
				continue; // not matching any function, must be static entry
			/* figure out where this function ends */
			string::size_type end = pos;
			int parentheses_open = 0;
			while ((end = file_format.find_first_of("()", end + 1)) != string::npos && end < stop) {
				int backslashes = 0;
				for (string::size_type a = end - 1; a < file_format.size(); --a) {
					if (file_format[a] != '\\')
						break;
					++backslashes;
				}
				if (backslashes % 2 != 0)
					continue; // this parenthese is escaped
				if (file_format[end] == '(')
					++parentheses_open;
				else
					--parentheses_open;
				if (parentheses_open <= 0)
					break;
			}
			if (end == string::npos) {
				/* no end parenthese?
				 * user probably did something wrong or it's a static entry */
				continue;
			}
			/* set up function */
			Field f;
			f.type = type;
			f.data.clear();
			/* call this method recursively for fields within parentheses in this function */
			string::size_type begin = file_format.find("(", pos + 1) + 1;
			setupFields(begin, end, &f.fields, true);
			/* add function to field list */
			fields->push_back(f);
			/* set pos to end parenthese */
			pos = end;
			/* set prev to char after end parenthese */
			prev = pos + 1;
			Debug::info() << "Adding function field: type = " << f.type << ", prev = " << prev << ", pos = " << pos << endl;
		}
	}
	if (prev != string::npos && prev < stop) {
		/* static field after last variable/function */
		Field f;
		f.type = TYPE_STATIC;
		f.data = file_format.substr(prev, stop - prev);
		removeEscapes(&f.data);
		fields->push_back(f);
		Debug::info() << "Adding last static field: data = '" << f.data << "', prev = " << prev << ", pos = " << pos << endl;
	}
}
