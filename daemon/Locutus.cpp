#include "Database.h"
#include "Debug.h"
#include "FileNamer.h"
#include "Levenshtein.h"
#include "Locutus.h"
#include "Matcher.h"
#include "Metafile.h"
#include "PostgreSQL.h"
//#include "PUIDGenerator.h"
#include "MusicBrainz.h"

using namespace std;

/* constructors/destructor */
Locutus::Locutus(Database *database) : database(database) {
	filenamer = new FileNamer(database);
	//puidgen = new PUIDGenerator();
	musicbrainz = new MusicBrainz(database);
	matcher = new Matcher(database, musicbrainz);

	input_dir = database->loadSettingString(MUSIC_INPUT_KEY, MUSIC_INPUT_VALUE, MUSIC_INPUT_DESCRIPTION);
	if (input_dir.size() <= 0 || input_dir[input_dir.size() - 1] != '/')
		input_dir.push_back('/');
	output_dir = database->loadSettingString(MUSIC_OUTPUT_KEY, MUSIC_OUTPUT_VALUE, MUSIC_OUTPUT_DESCRIPTION);
	if (output_dir.size() <= 0 || output_dir[output_dir.size() - 1] != '/')
		output_dir.push_back('/');
	duplicate_dir = database->loadSettingString(MUSIC_DUPLICATE_KEY, MUSIC_DUPLICATE_VALUE, MUSIC_DUPLICATE_DESCRIPTION);
	if (duplicate_dir.size() <= 0 || duplicate_dir[duplicate_dir.size() - 1] != '/')
		duplicate_dir.push_back('/');
}

Locutus::~Locutus() {
	clearFiles();
	//delete puidgen;
	delete matcher;
	delete musicbrainz;
	delete filenamer;
}

/* static methods */
void Locutus::trim(string *text) {
	if (text == NULL)
		return;
	string::size_type pos = text->find_last_not_of(" \t\n");
	if (pos != string::npos)
		text->erase(pos + 1);
	pos = text->find_first_not_of(" \t\n");
	if (pos != string::npos)
		text->erase(0, pos);
	if (text->size() > 0 && text->at(0) == ' ')
		text->erase();
}

/* methods */
long Locutus::run() {
	/* parse sorted directory */
	Debug::info("Scanning output directory");
	scanFiles(output_dir);
	/* parse unsorted directory */
	Debug::info("Scanning input directory");
	scanFiles(input_dir);
	/* match files */
	for (map<string, vector<Metafile *> >::iterator gf = grouped_files.begin(); gf != grouped_files.end(); ++gf) {
		matcher->match(gf->first, gf->second);
		/* save files with new metadata */
		for (vector<Metafile *>::iterator f = gf->second.begin(); f != gf->second.end(); ++f) {
			if (!(*f)->metadata_changed)
				continue;
			/*
			if (!(*f)->saveMetadata())
				continue;
			*/
			/* move file */
			string filename = output_dir;
			filename.append(filenamer->getFilename(*f));
			string old_filename = (*f)->filename;
			cout << "Would save: " << old_filename << endl;
			cout << "  Matching: " << (*f)->artist << " - " << (*f)->album << " - " << (*f)->tracknumber << " - " << (*f)->title << endl;
			//if (!moveFile(*f, filename)) {
				/* TODO: unable to move file */
			//}
			//database->saveMetafile(**f, old_filename); // metadata may have changed even if path haven't
		}
	}
	/* submit new puids? */
	// TODO
	/* remove file entries where file doesn't exist */
	removeGoneFiles();
	/* return */
	return 10000;
}

/* private methods */
void Locutus::clearFiles() {
	for (map<string, vector<Metafile *> >::iterator group = grouped_files.begin(); group != grouped_files.end(); ++group) {
		for (vector<Metafile *>::iterator file = group->second.begin(); file != group->second.end(); ++file)
			delete (*file);
	}
	grouped_files.clear();
}

bool Locutus::moveFile(Metafile *file, const string &filename) {
	string::size_type start = 0;
	string dirname;
	mode_t mode = S_IRUSR | S_IWUSR | S_IXUSR | S_IRGRP | S_IWGRP | S_IXGRP | S_IROTH | S_IXOTH;
	struct stat data;
	int result;
	while ((start = filename.find_first_of('/', start + 1)) != string::npos) {
		dirname = filename.substr(0, start);
		result = stat(dirname.c_str(), &data);
		if (result == 0 && S_ISDIR(data.st_mode))
			continue; // directory already exist
		result = mkdir(dirname.c_str(), mode);
		if (result == 0)
			continue;                                                                                                                      
		/* unable to create directory */
		dirname.insert(0, "Unable to create directory: ");
		Debug::warning(dirname);
		return false;
	}
	/* TODO: currently it overwrites files, not good */
	if (rename(file->filename.c_str(), filename.c_str()) == 0) {
		/* was able to move file, let's also try changing the permissions to 0664 */
		mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH;
		chmod(filename.c_str(), mode);
		file->filename = filename;
		return true;
	}
	/* unable to move file for some reason */
	dirname = "Unable to move file: ";
	dirname.append(filename);
	Debug::warning(dirname);
	return false;
}

bool Locutus::parseDirectory() {
	if (dir_queue.size() <= 0)
		return false;
	string directory(*dir_queue.begin());
	Debug::info(directory);
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

bool Locutus::parseFile() {
	if (file_queue.size() <= 0)
		return false;
	string filename(*file_queue.begin());
	Debug::info(filename);
	file_queue.pop_front();
	Metafile *mf = new Metafile(filename);
	if (!database->loadMetafile(mf)) {
		if (mf->readFromFile()) {
			/* save file to cache */
			database->saveMetafile(*mf);
		} else {
			/* unable to read this file */
			delete mf;
			return false;
		}
	}
	mf->meta_lookup = true;
	grouped_files[mf->getGroup()].push_back(mf);
	return true;
}

void Locutus::removeGoneFiles() {
	/* FIXME: this broke when we made the database layer
	if (!database->query("SELECT file_id, filename FROM file"))
		return;
	struct stat file_info;
	ostringstream remove;
	remove.str("");
	for (int r = 0; r < database->getRows(); ++r) {
		if (stat(database->getString(r, 1).c_str(), &file_info) == 0)
			continue;
		// unable to get info about this file, remove it from database
		if (remove.str() == "")
			remove << "DELETE FROM file WHERE file_id IN (" << database->getInt(r, 0);
		else
			remove << ", " << database->getInt(r, 0);
	}
	if (remove.str() == "")
		return;
	// there are entries in the file table that should go
	remove << ")";
	database->query(remove.str());
	*/
}

void Locutus::scanFiles(const string &directory) {
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

/* main */
int main() {
	/* initialize static classes */
	Debug::open("locutus.log");
	Levenshtein::initialize();

	/* connect to database */
	Database *database = new PostgreSQL("host=sql.samfundet.no user=locutus password=locutus dbname=locutus");

	//while (true) {
		Locutus *locutus = new Locutus(database);
		Debug::info("Checking files...");
		long sleeptime = locutus->run();
		Debug::info("Finished checking files");
		delete locutus;

		usleep(sleeptime);
	//}

	/* disconnect from database */
	delete database;

	/* clear static classes */
	Levenshtein::clear();
	Debug::close();

	return 0;
}
