#include "FileReader.h"

/* constructors */
FileReader::FileReader(Locutus *locutus) {
	this->locutus = locutus;
	active = false;
	loadSettings();
}

/* destructors */
FileReader::~FileReader() {
}

/* methods */
void FileReader::quit() {
	active = false;
	join();
}

void FileReader::run() {
	active = true;
	while (active) {
		/* first files */
		if (parseFile())
			continue;
		/* then directories */
		if (parseDirectory())
			continue;
		sleep(60);
	}
}

void FileReader::scanFiles() {
	dir_queue.push_back(input_dir);
	dir_queue.push_back(output_dir);
	dir_queue.push_back(duplicate_dir);
	if (!active)
		this->start();
}

/* private methods */
void FileReader::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEREADER_CLASS, FILEREADER_CLASS_DESCRIPTION);
	input_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_SORTED_KEY, MUSIC_SORTED_VALUE, MUSIC_SORTED_DESCRIPTION);
	output_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_UNSORTED_KEY, MUSIC_UNSORTED_VALUE, MUSIC_UNSORTED_DESCRIPTION);
	duplicate_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_DUPLICATE_KEY, MUSIC_DUPLICATE_VALUE, MUSIC_DUPLICATE_DESCRIPTION);
}

bool FileReader::parseDirectory() {
	if (dir_queue.size() <= 0)
		return false;
	string directory(*dir_queue.begin());
	cout << "Checking directory " << directory << endl;
	dir_queue.pop_front();
	DIR *dir = opendir(directory.c_str());
	if (dir == NULL)
		return false;
	dirent *entity;
	while ((entity = readdir(dir)) != NULL) {
		if (entity->d_type == DT_REG)
			file_queue.push_back(string(entity->d_name));
		else if (entity->d_type == DT_DIR)
			dir_queue.push_back(string(entity->d_name));
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
	locutus->files[file.getGroup()].push_back(file);
	return true;
}
