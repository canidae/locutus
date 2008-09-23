#include "FileHandler.h"

/* constructors */
FileHandler::FileHandler(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
FileHandler::~FileHandler() {
}

/* methods */
void FileHandler::loadSettings() {
	input_dir = locutus->settings->loadSetting(MUSIC_INPUT_KEY, MUSIC_INPUT_VALUE, MUSIC_INPUT_DESCRIPTION);
	output_dir = locutus->settings->loadSetting(MUSIC_OUTPUT_KEY, MUSIC_OUTPUT_VALUE, MUSIC_OUTPUT_DESCRIPTION);
	duplicate_dir = locutus->settings->loadSetting(MUSIC_DUPLICATE_KEY, MUSIC_DUPLICATE_VALUE, MUSIC_DUPLICATE_DESCRIPTION);
	createFileFormatList(locutus->settings->loadSetting(FILENAME_FORMAT_KEY, FILENAME_FORMAT_VALUE, FILENAME_FORMAT_DESCRIPTION));
}

void FileHandler::saveFiles(const map<Metafile *, Track *> &files) {
	locutus->debug(DEBUG_INFO, "Saving files:");
	for (map<Metafile *, Track *>::const_iterator s = files.begin(); s != files.end(); ++s) {
		locutus->debug(DEBUG_INFO, s->first->filename);
		/* first save metadata */
		if (!s->first->saveMetadata(s->second)) {
			/* unable to save metadata */
			continue;
		}
		/* move file */
		moveFile(s->first);
		/* and finally update file table */
		s->first->saveToCache();
	}
}

void FileHandler::scanFiles(const string &directory) {
	dir_queue.push_back(directory);
	while (dir_queue.size() > 0 || file_queue.size() > 0) {
		/* first files */
		if (parseFile())
			continue;
		/* then directories */
		if (parseDirectory())
			continue;
	}
}

/* private methods */
void FileHandler::createFileFormatList(const string &file_format) {
	file_format_list.clear();
	string::size_type stop = 0;
	string::size_type start = 0;
	FilenameEntry entry;
	while (stop != string::npos && start < file_format.size()) {
		start = stop;
		stop = file_format.find_first_of("%", stop + 1);
		if (file_format[start] != '%' || stop - start == 1) {
			/* static entry */
			entry.limit = -1;
			entry.type = TYPE_STATIC;
			entry.custom = file_format.substr(start, stop - start);
			file_format_list.push_back(entry);
			continue;
		}
		string::size_type limit_stop = file_format.find_first_not_of("%0123456789", start);
		entry.custom = file_format.substr(limit_stop, stop - limit_stop);
		if (limit_stop != string::npos)
			entry.limit = atoi(file_format.substr(start + 1, limit_stop - start - 1).c_str()); // limit entry
		else
			entry.limit = -1;
		if (entry.custom == "album")
			entry.type = TYPE_ALBUM;
		else if (entry.custom == "albumartist")
			entry.type = TYPE_ALBUMARTIST;
		else if (entry.custom == "albumartistsort")
			entry.type = TYPE_ALBUMARTISTSORT;
		else if (entry.custom == "artist")
			entry.type = TYPE_ARTIST;
		else if (entry.custom == "artistsort")
			entry.type = TYPE_ARTISTSORT;
		else if (entry.custom == "musicbrainz_albumartistid")
			entry.type = TYPE_MUSICBRAINZ_ALBUMARTISTID;
		else if (entry.custom == "musicbrainz_albumid")
			entry.type = TYPE_MUSICBRAINZ_ALBUMID;
		else if (entry.custom == "musicbrainz_artistid")
			entry.type = TYPE_MUSICBRAINZ_ARTISTID;
		else if (entry.custom == "musicbrainz_trackid")
			entry.type = TYPE_MUSICBRAINZ_TRACKID;
		else if (entry.custom == "musicip_puid")
			entry.type = TYPE_MUSICIP_PUID;
		else if (entry.custom == "title")
			entry.type = TYPE_TITLE;
		else if (entry.custom == "tracknumber")
			entry.type = TYPE_TRACKNUMBER;
		else if (entry.custom == "date")
			entry.type = TYPE_DATE;
		else if (entry.custom == "custom_artist")
			entry.type = TYPE_CUSTOM_ARTIST;
		else
			entry.type = TYPE_STATIC;
		if (entry.type == TYPE_STATIC)
			entry.custom = file_format.substr(start, stop - start);
		else
			entry.custom.clear();
		file_format_list.push_back(entry);
	}
	if (file_format_list.size() <= 0)
		locutus->debug(DEBUG_WARNING, "Output file format is empty, won't be able to save files");
}

bool FileHandler::moveFile(Metafile *file) {
	string filename = output_dir;
	for (list<FilenameEntry>::iterator entry = file_format_list.begin(); entry != file_format_list.end(); ++entry) {
	}
	return false;
}

bool FileHandler::parseDirectory() {
	if (dir_queue.size() <= 0)
		return false;
	string directory(*dir_queue.begin());
	locutus->debug(DEBUG_INFO, directory);
	dir_queue.pop_front();
	DIR *dir = opendir(directory.c_str());
	if (dir == NULL)
		return true;
	dirent *entity;
	while ((entity = readdir(dir)) != NULL) {
		string entityname = entity->d_name;
		if (entityname == "." || entityname == "..")
			continue;
		string ford = directory;
		if (ford[ford.size() - 1] != '/')
			ford.append("/");
		ford.append(entityname);
		/* why isn't always "entity->d_type == DT_DIR" when the entity is a directory? */
		DIR *tmpdir = opendir(ford.c_str());
		if (tmpdir != NULL)
			dir_queue.push_back(ford);
		else
			file_queue.push_back(ford);
		closedir(tmpdir);
	}
	closedir(dir);
	return true;
}

bool FileHandler::parseFile() {
	if (file_queue.size() <= 0)
		return false;
	string filename(*file_queue.begin());
	locutus->debug(DEBUG_INFO, filename);
	file_queue.pop_front();
	Metafile *mf = new Metafile(locutus);
	if (!mf->loadFromCache(filename)) {
		if (mf->readFromFile(filename)) {
			/* save file to cache */
			mf->saveToCache();
		} else {
			/* unable to read this file */
			delete mf;
			return false;
		}
	}
	/* TODO:
	 * should be settings which lookups we want to run */
	mf->puid_lookup = true;
	mf->mbid_lookup = true;
	mf->meta_lookup = true;
	locutus->files.push_back(mf);
	locutus->grouped_files[mf->getGroup()].push_back(mf);
	return true;
}
