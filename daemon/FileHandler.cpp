#include "FileHandler.h"

/* constructors */
FileHandler::FileHandler(Locutus *locutus) {
	this->locutus = locutus;
	format_mapping["%album%"] = TYPE_ALBUM;
	format_mapping["%albumartist%"] = TYPE_ALBUMARTIST;
	format_mapping["%albumartistsort%"] = TYPE_ALBUMARTISTSORT;
	format_mapping["%artist%"] = TYPE_ARTIST;
	format_mapping["%artistsort%"] = TYPE_ARTISTSORT;
	format_mapping["%musicbrainz_albumartistid%"] = TYPE_MUSICBRAINZ_ALBUMARTISTID;
	format_mapping["%musicbrainz_albumid%"] = TYPE_MUSICBRAINZ_ALBUMID;
	format_mapping["%musicbrainz_artistid%"] = TYPE_MUSICBRAINZ_ARTISTID;
	format_mapping["%musicbrainz_trackid%"] = TYPE_MUSICBRAINZ_TRACKID;
	format_mapping["%musicip_puid%"] = TYPE_MUSICIP_PUID;
	format_mapping["%title%"] = TYPE_TITLE;
	format_mapping["%tracknumber%"] = TYPE_TRACKNUMBER;
	format_mapping["%date%"] = TYPE_DATE;
	format_mapping["%custom_artist%"] = TYPE_CUSTOM_ARTIST;
}

/* destructors */
FileHandler::~FileHandler() {
}

/* methods */
void FileHandler::loadSettings() {
	input_dir = locutus->settings->loadSetting(MUSIC_INPUT_KEY, MUSIC_INPUT_VALUE, MUSIC_INPUT_DESCRIPTION);
	output_dir = locutus->settings->loadSetting(MUSIC_OUTPUT_KEY, MUSIC_OUTPUT_VALUE, MUSIC_OUTPUT_DESCRIPTION);
	duplicate_dir = locutus->settings->loadSetting(MUSIC_DUPLICATE_KEY, MUSIC_DUPLICATE_VALUE, MUSIC_DUPLICATE_DESCRIPTION);
	file_format = locutus->settings->loadSetting(FILENAME_FORMAT_KEY, FILENAME_FORMAT_VALUE, FILENAME_FORMAT_DESCRIPTION);
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
bool FileHandler::moveFile(Metafile *file) {
	if (file_format.size() <= 0) {
		locutus->debug(DEBUG_WARNING, "File format for output is way too short, refuse to save file");
		return false;
	}
	string filename = output_dir;
	string::size_type start = filename.size() - 1;
	filename.append(file_format);
	while (start < filename.size() && (start = filename.find('%', start + 1)) != string::npos) {
		string::size_type stop = filename.find('%', start + 1);
		if (stop == string::npos)
			break; // no more '%'
		map<string, int>::iterator replace = format_mapping.find(filename.substr(start, stop - start + 1)); // "+ 1" to include last '%'
		if (replace != format_mapping.end()) {
			/* we should replace something */
			string tmp;
			switch (replace->second) {
				case TYPE_ALBUM:
					tmp = file->album;
					break;

				case TYPE_ALBUMARTIST:
					tmp = file->albumartist;
					break;

				case TYPE_ALBUMARTISTSORT:
					tmp = file->albumartistsort;
					break;

				case TYPE_ARTIST:
					tmp = file->artist;
					break;

				case TYPE_ARTISTSORT:
					tmp = file->artistsort;
					break;

				case TYPE_MUSICBRAINZ_ALBUMARTISTID:
					tmp = file->musicbrainz_albumartistid;
					break;

				case TYPE_MUSICBRAINZ_ALBUMID:
					tmp = file->musicbrainz_albumid;
					break;

				case TYPE_MUSICBRAINZ_ARTISTID:
					tmp = file->musicbrainz_artistid;
					break;

				case TYPE_MUSICBRAINZ_TRACKID:
					tmp = file->musicbrainz_trackid;
					break;

				case TYPE_MUSICIP_PUID:
					tmp = file->puid;
					break;

				case TYPE_TITLE:
					tmp = file->title;
					break;

				case TYPE_TRACKNUMBER:
					tmp = file->tracknumber;
					break;

				case TYPE_DATE:
					tmp = file->released;
					break;

				case TYPE_CUSTOM_ARTIST:
					/*
					if (file->custom_artist_sortname != "") {
						tmp = file->custom_artist_sortname;
					} else {
					*/
					if (file->musicbrainz_artistid != VARIOUS_ARTISTS_MBID) {
						tmp = file->albumartistsort;
					} else {
						tmp = file->artistsort;
					}
					/*
					}
					*/
					break;

				default:
					/* didn't match anything, probably static entry */
					tmp = replace->first;
					break;
			}
			filename.erase(start, replace->first.size());
			filename.insert(start, tmp);
			start += tmp.size();
		}
	}
	locutus->debug(DEBUG_INFO, filename);
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
