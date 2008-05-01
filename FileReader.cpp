#include "FileReader.h"

/* constructors */
FileReader::FileReader(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
FileReader::~FileReader() {
}

/* methods */
void FileReader::run() {
	active = true;
	while (active) {
		/* first files */
		if (parseFile())
			continue;
		/* then directories */
		if (parseDirectory())
			continue;
	}
}

void FileReader::stop() {
	active = false;
	join();
}

/* private methods */
void FileReader::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEREADER_CLASS, FILEREADER_CLASS_DESCRIPTION);
	input_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_SORTED_KEY, MUSIC_SORTED_VALUE, MUSIC_SORTED_DESCRIPTION);
	output_dir = locutus->settings->loadSetting(setting_class_id, MUSIC_UNSORTED_KEY, MUSIC_UNSORTED_VALUE, MUSIC_UNSORTED_DESCRIPTION);
}

bool FileReader::parseDirectory() {
	if (dir_queue.size() <= 0)
		return false;
	string directory(*dir_queue.begin());
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
	file_queue.pop_front();
	FileMetadata file(locutus, filename);
	locutus->files[file.getGroup()].push_back(file);
	return true;
}
