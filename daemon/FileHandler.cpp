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
}

void FileHandler::saveFiles(const map<Metafile *, Track *> &files) {
	locutus->debug(DEBUG_INFO, "Saving files:");
	for (map<Metafile *, Track *>::const_iterator s = files.begin(); s != files.end(); ++s) {
		locutus->debug(DEBUG_INFO, s->first->filename);
		/* first save metadata */
		s->first->saveMetadata(s->second);
		/* TODO: then move file */
		/* and finally update file table */
		ostringstream query;
		query << "UPDATE file SET filename = '" << locutus->database->escapeString(s->first->filename) << "', ";
		query << "last_updated = now(), ";
		query << "puid_id = (SELECT puid_id FROM puid WHERE puid = '" << locutus->database->escapeString(s->first->puid) << "'), ";
		query << "album = '" << locutus->database->escapeString(s->first->album) << "', ";
		query << "albumartist = '" << locutus->database->escapeString(s->first->albumartist) << "', ";
		query << "albumartistsort = '" << locutus->database->escapeString(s->first->albumartistsort) << "', ";
		query << "artist = '" << locutus->database->escapeString(s->first->artist) << "', ";
		query << "artistsort = '" << locutus->database->escapeString(s->first->artistsort) << "', ";
		query << "musicbrainz_albumartistid = '" << locutus->database->escapeString(s->first->musicbrainz_albumartistid) << "', ";
		query << "musicbrainz_albumid = '" << locutus->database->escapeString(s->first->musicbrainz_albumid) << "', ";
		query << "musicbrainz_artistid = '" << locutus->database->escapeString(s->first->musicbrainz_artistid) << "', ";
		query << "musicbrainz_trackid = '" << locutus->database->escapeString(s->first->musicbrainz_trackid) << "', ";
		query << "title = '" << locutus->database->escapeString(s->first->title) << "', ";
		query << "tracknumber = '" << locutus->database->escapeString(s->first->tracknumber) << "', ";
		query << "released = '" << locutus->database->escapeString(s->first->released) << "', ";
		query << "track_id = " << s->second->id << " ";
		query << "WHERE file_id = " << s->first->id;
		if (!locutus->database->query(query.str())) {
			query.str("");
			query << "Unable to update database entry for file '" << s->first->filename << "'";
			locutus->debug(DEBUG_WARNING, query.str());
		}
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
