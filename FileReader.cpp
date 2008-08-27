#include "FileReader.h"

/* constructors */
FileReader::FileReader(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
FileReader::~FileReader() {
}

/* methods */
void FileReader::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEREADER_CLASS, FILEREADER_CLASS_DESCRIPTION);
	input_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_INPUT_KEY, MUSIC_INPUT_VALUE, MUSIC_INPUT_DESCRIPTION);
	output_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_OUTPUT_KEY, MUSIC_OUTPUT_VALUE, MUSIC_OUTPUT_DESCRIPTION);
	duplicate_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_DUPLICATE_KEY, MUSIC_DUPLICATE_VALUE, MUSIC_DUPLICATE_DESCRIPTION);
}

void FileReader::scanFiles(const string &directory) {
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
bool FileReader::parseDirectory() {
	if (dir_queue.size() <= 0)
		return false;
	string directory(*dir_queue.begin());
	cout << "Checking directory " << directory << endl;
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

bool FileReader::parseFile() {
	if (file_queue.size() <= 0)
		return false;
	string filename(*file_queue.begin());
	cout << "Checking file " << filename << endl;
	file_queue.pop_front();
	Metafile *mf = new Metafile(locutus);
	if (!mf->loadFromCache(filename)) {
		if (!mf->readFromFile(filename)) {
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
