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
bool FileReader::loadSettings() {
	return true;
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
	/* do taglib magic here */
	return true;
}
