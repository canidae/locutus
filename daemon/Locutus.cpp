#include "Album.h"
#include "Database.h"
#include "Debug.h"
#include "FileNamer.h"
#include "Levenshtein.h"
#include "Locutus.h"
#include "Matcher.h"
#include "Metafile.h"
#include "PostgreSQL.h"
#include "PUIDGenerator.h"
#include "Track.h"
#include "WebService.h"

using namespace std;

/* constructors/destructor */
Locutus::Locutus(Database *database) : database(database) {
	webservice = new WebService(database);
	filenamer = new FileNamer(database);
	puidgen = new PUIDGenerator();
	matcher = new Matcher(this);

	input_dir = database->loadSetting(MUSIC_INPUT_KEY, MUSIC_INPUT_VALUE, MUSIC_INPUT_DESCRIPTION);
	output_dir = database->loadSetting(MUSIC_OUTPUT_KEY, MUSIC_OUTPUT_VALUE, MUSIC_OUTPUT_DESCRIPTION);
	duplicate_dir = database->loadSetting(MUSIC_DUPLICATE_KEY, MUSIC_DUPLICATE_VALUE, MUSIC_DUPLICATE_DESCRIPTION);
}

Locutus::~Locutus() {
	for (vector<Metafile *>::iterator mf = files.begin(); mf != files.end(); ++mf)
		delete (*mf);
	delete puidgen;
	delete matcher;
	delete webservice;
	delete filenamer;
}

/* methods */
long Locutus::run() {
	/* load settings */
	Debug::info("Loading settings");
	loadSettings();
	/* parse sorted directory */
	Debug::info("Scanning output directory");
	scanDirectory(output_dir);
	/* parse unsorted directory */
	Debug::info("Scanning input directory");
	scanDirectory(input_dir);
	/* match files */
	for (map<string, vector<Metafile *> >::iterator gf = grouped_files.begin(); gf != grouped_files.end(); ++gf)
		matcher->match(gf->first, gf->second);
	/* submit new puids? */
	// TODO
	/* save changes */
	// TODO
	/* remove file entries where file doesn't exist */
	removeGoneFiles();
	/* return */
	return 10000;
}

/* private methods */
void Locutus::loadSettings() {
	/* load general settings */
        metatrack_cache_lifetime = database->loadSetting(METATRACK_CACHE_LIFETIME_KEY, METATRACK_CACHE_LIFETIME_VALUE, METATRACK_CACHE_LIFETIME_DESCRIPTION);
        puid_cache_lifetime = database->loadSetting(PUID_CACHE_LIFETIME_KEY, PUID_CACHE_LIFETIME_VALUE, PUID_CACHE_LIFETIME_DESCRIPTION);
	album_weight = database->loadSetting(ALBUM_WEIGHT_KEY, ALBUM_WEIGHT_VALUE, ALBUM_WEIGHT_DESCRIPTION);
	artist_weight = database->loadSetting(ARTIST_WEIGHT_KEY, ARTIST_WEIGHT_VALUE, ARTIST_WEIGHT_DESCRIPTION);
	combine_threshold = database->loadSetting(COMBINE_THRESHOLD_KEY, COMBINE_THRESHOLD_VALUE, COMBINE_THRESHOLD_DESCRIPTION);
	duration_limit = database->loadSetting(DURATION_LIMIT_KEY, DURATION_LIMIT_VALUE, DURATION_LIMIT_DESCRIPTION);
	duration_weight = database->loadSetting(DURATION_WEIGHT_KEY, DURATION_WEIGHT_VALUE, DURATION_WEIGHT_DESCRIPTION);
	title_weight = database->loadSetting(TITLE_WEIGHT_KEY, TITLE_WEIGHT_VALUE, TITLE_WEIGHT_DESCRIPTION);
	tracknumber_weight = database->loadSetting(TRACKNUMBER_WEIGHT_KEY, TRACKNUMBER_WEIGHT_VALUE, TRACKNUMBER_WEIGHT_DESCRIPTION);
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

void Locutus::removeGoneFiles() {
	/* FIXME: broke this when changing making database an own layer
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

void Locutus::saveFiles(const map<Metafile *, Track *> &files) {
	Debug::info("Saving files:");
	for (map<Metafile *, Track *>::const_iterator s = files.begin(); s != files.end(); ++s) {
		Debug::info(s->first->filename);
		/* first save metadata */
		if (!s->first->saveMetadata(s->second)) {
			/* unable to save metadata */
			continue;
		}
		/* move file */
		//filenamer->getFilename(s->first);
		/* and finally update file table */
		database->save(*(s->first));
	}
}

void Locutus::scanDirectory(const string &directory) {
	/* clear data */
	grouped_files.clear();
	files.clear();
	/* parse directory */
	scanFiles(directory);
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
	Metafile *mf = new Metafile(this);
	mf->filename = filename;
	if (!database->load(mf)) {
		if (mf->readFromFile(filename)) {
			/* save file to cache */
			database->save(*mf);
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
	files.push_back(mf);
	grouped_files[mf->getGroup()].push_back(mf);
	return true;
}

/* main */
int main() {
	/* initialize static classes */
	Debug::open("locutus.log");
	Levenshtein::initialize();

	/* connect to database */
	Database *database = new PostgreSQL("host=localhost user=locutus password=locutus dbname=locutus");

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
