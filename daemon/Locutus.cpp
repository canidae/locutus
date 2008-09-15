#include "Locutus.h"

/* constructors */
Locutus::Locutus() {
	debugfile = new ofstream("locutus.log", ios::app);
	database = new Database(this);
	levenshtein = new Levenshtein();
	settings = new Settings(this);
	webservice = new WebService(this);
	filehandler = new FileHandler(this);
	puidgen = new PUIDGenerator(this);
	matcher = new Matcher(this);
}

/* destructors */
Locutus::~Locutus() {
	for (vector<Metafile *>::iterator mf = files.begin(); mf != files.end(); ++mf)
		delete (*mf);
	debugfile->close();
	delete debugfile;
	delete puidgen;
	delete matcher;
	delete webservice;
	delete settings;
	delete filehandler;
	delete levenshtein;
	delete database;
}

/* methods */
void Locutus::debug(int level, const string &text) {
	time_t rawtime;
	time(&rawtime);
	string t = asctime(localtime(&rawtime));
	t.erase(t.size() - 1);
	*debugfile << "[" << t << "] ";
	switch (level) {
		case DEBUG_ERROR:
			*debugfile << "[ERROR  ] ";
			break;

		case DEBUG_WARNING:
			*debugfile << "[WARNING] ";
			break;

		case DEBUG_NOTICE:
			*debugfile << "[NOTICE ] ";
			break;

		case DEBUG_INFO:
			*debugfile << "[INFO   ] ";
			break;

		default:
			*debugfile << "[UNKNOWN] ";
			break;
	}
	*debugfile << text << endl;
}

long Locutus::run() {
	/* load settings */
	debug(DEBUG_INFO, "Loading settings");
	loadSettings();
	/* parse sorted directory */
	debug(DEBUG_INFO, "Scanning output directory");
	scanDirectory(filehandler->output_dir);
	/* parse unsorted directory */
	debug(DEBUG_INFO, "Scanning input directory");
	scanDirectory(filehandler->input_dir);
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
        album_cache_lifetime = settings->loadSetting(ALBUM_CACHE_LIFETIME_KEY, ALBUM_CACHE_LIFETIME_VALUE, ALBUM_CACHE_LIFETIME_DESCRIPTION);
        metatrack_cache_lifetime = settings->loadSetting(METATRACK_CACHE_LIFETIME_KEY, METATRACK_CACHE_LIFETIME_VALUE, METATRACK_CACHE_LIFETIME_DESCRIPTION);
        puid_cache_lifetime = settings->loadSetting(PUID_CACHE_LIFETIME_KEY, PUID_CACHE_LIFETIME_VALUE, PUID_CACHE_LIFETIME_DESCRIPTION);
	album_weight = settings->loadSetting(ALBUM_WEIGHT_KEY, ALBUM_WEIGHT_VALUE, ALBUM_WEIGHT_DESCRIPTION);
	artist_weight = settings->loadSetting(ARTIST_WEIGHT_KEY, ARTIST_WEIGHT_VALUE, ARTIST_WEIGHT_DESCRIPTION);
	combine_threshold = settings->loadSetting(COMBINE_THRESHOLD_KEY, COMBINE_THRESHOLD_VALUE, COMBINE_THRESHOLD_DESCRIPTION);
	duration_limit = settings->loadSetting(DURATION_LIMIT_KEY, DURATION_LIMIT_VALUE, DURATION_LIMIT_DESCRIPTION);
	duration_weight = settings->loadSetting(DURATION_WEIGHT_KEY, DURATION_WEIGHT_VALUE, DURATION_WEIGHT_DESCRIPTION);
	title_weight = settings->loadSetting(TITLE_WEIGHT_KEY, TITLE_WEIGHT_VALUE, TITLE_WEIGHT_DESCRIPTION);
	tracknumber_weight = settings->loadSetting(TRACKNUMBER_WEIGHT_KEY, TRACKNUMBER_WEIGHT_VALUE, TRACKNUMBER_WEIGHT_DESCRIPTION);

	/* load settings for other classes */
	filehandler->loadSettings();
	webservice->loadSettings();
	puidgen->loadSettings();
	matcher->loadSettings();
}

void Locutus::removeGoneFiles() {
	if (!database->query("SELECT file_id, filename FROM file"))
		return;
	struct stat file_info;
	ostringstream remove;
	remove.str("");
	for (int r = 0; r < database->getRows(); ++r) {
		if (stat(database->getString(r, 1).c_str(), &file_info) == 0)
			continue;
		/* unable to get info about this file, remove it from database */
		if (remove.str() == "")
			remove << "DELETE FROM file WHERE file_id IN (" << database->getInt(r, 0);
		else
			remove << ", " << database->getInt(r, 0);
	}
	if (remove.str() == "")
		return;
	/* there are entries in the file table that should go */
	remove << ")";
	database->query(remove.str());
}

void Locutus::scanDirectory(const string &directory) {
	/* clear data */
	grouped_files.clear();
	files.clear();
	/* parse directory */
	filehandler->scanFiles(directory);
}

/* main */
int main() {
	//while (true) {
		Locutus *locutus = new Locutus();
		locutus->debug(DEBUG_INFO, "Checking files...");
		long sleeptime = locutus->run();
		locutus->debug(DEBUG_INFO, "Finished checking files");
		delete locutus;
		usleep(sleeptime);
	//}
	return 0;
}
