#include "FileReader.h"

/* constructors */
FileReader::FileReader(Locutus *locutus) {
	this->locutus = locutus;
	active = false;
}

/* destructors */
FileReader::~FileReader() {
}

/* methods */
void FileReader::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEREADER_CLASS, FILEREADER_CLASS_DESCRIPTION);
	input_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_SORTED_KEY, MUSIC_SORTED_VALUE, MUSIC_SORTED_DESCRIPTION);
	output_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_UNSORTED_KEY, MUSIC_UNSORTED_VALUE, MUSIC_UNSORTED_DESCRIPTION);
	duplicate_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_DUPLICATE_KEY, MUSIC_DUPLICATE_VALUE, MUSIC_DUPLICATE_DESCRIPTION);
}

void FileReader::scanFiles(string directory) {
	dir_queue.push_back(directory);
	active = true;
	while (dir_queue.size() > 0 || file_queue.size() > 0) {
		/* first files */
		if (parseFile())
			continue;
		/* then directories */
		if (parseDirectory())
			continue;
	}
	active = false;
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
	FileMetadata file(locutus, filename);
	list<Entry>::iterator ei = file.entries.begin();
	while (ei != file.entries.end()) {
		cout << ei->key << ": " << ei->value << endl;
		++ei;
	}
	locutus->files.push_back(file);
	locutus->grouped_files[file.getGroup()].push_back(locutus->files.size() - 1);
	if (file.getValue(MUSICIP_PUID) == "")
		locutus->gen_puid_queue.push_back(locutus->files.size() - 1);
	return true;
}
