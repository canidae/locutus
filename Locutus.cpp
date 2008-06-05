#include "Locutus.h"

/* constructors */
Locutus::Locutus() {
	debugfile = new ofstream("locutus.log", ios::app);
	database = new Database(this);
	levenshtein = new Levenshtein();
	settings = new Settings(this);
	fmconst = new FileMetadataConstants(this);
	webservice = new WebService(this);
	filereader = new FileReader(this);
	puidgen = new PUIDGenerator(this);
	webfetcher = new WebFetcher(this);
}

/* destructors */
Locutus::~Locutus() {
	for (vector<Metafile *>::iterator mf = files.begin(); mf != files.end(); ++mf)
		delete (*mf);
	debugfile->close();
	delete debugfile;
	delete puidgen;
	delete webfetcher;
	delete webservice;
	delete settings;
	delete filereader;
	delete fmconst;
	delete levenshtein;
	delete database;
}

/* methods */
void Locutus::debug(int level, string text) {
	time_t rawtime;
	time(&rawtime);
	string t = asctime(localtime(&rawtime));
	t.erase(t.size() - 1);
	*debugfile << "[" << t << "] ";
	switch (level) {
		case DEBUG_ERROR:
			*debugfile << "[ERROR]  ";
			break;

		case DEBUG_WARNING:
			*debugfile << "[WARNING]  ";
			break;

		case DEBUG_NOTICE:
			*debugfile << "[NOTICE]  ";
			break;

		case DEBUG_INFO:
			*debugfile << "[INFO]  ";
			break;

		default:
			*debugfile << "[UNKNOWN]  ";
			break;
	}
	*debugfile << text << endl;
}

long Locutus::run() {
	/* load settings */
	loadSettings();
	/* clean cache */
	cleanCache();
	/* parse sorted directory */
	scanDirectory(filereader->output_dir);
	/* parse unsorted directory */
	scanDirectory(filereader->input_dir);
	/* submit new puids? */
	/* return */
	return 10000;
}

/* private methods */
void Locutus::cleanCache() {
	/* delete old data from database */
	/* album */
	ostringstream query;
	query << "DELETE FROM album WHERE last_updated + INTERVAL '" << album_cache_lifetime << " months' < now()";
	database->query(query.str());
	/* metatrack */
	ostringstream query;
	query << "DELETE FROM metatrack WHERE last_updated + INTERVAL '" << metatrack_cache_lifetime << " months' < now()";
	database->query(query.str());
	/* puid_track */
	query.str("");
	query << "DELETE FROM puid_metatrack WHERE last_updated + INTERVAL '" << puid_cache_lifetime << " months' < now()";
	database->query(query.str());
	/* artist */
	query.str("");
	query << "DELETE FROM artist WHERE artist_id NOT IN (SELECT artist_id FROM album UNION SELECT artist_id FROM track)";
	database->query(query.str());
}

void Locutus::loadSettings() {
	/* load general settings */
        setting_class_id = settings->loadClassID(LOCUTUS_CLASS, LOCUTUS_CLASS_DESCRIPTION);
        album_cache_lifetime = settings->loadSetting(setting_class_id, ALBUM_CACHE_LIFETIME_KEY, ALBUM_CACHE_LIFETIME_VALUE, ALBUM_CACHE_LIFETIME_DESCRIPTION);
        metatrack_cache_lifetime = settings->loadSetting(setting_class_id, METATRACK_CACHE_LIFETIME_KEY, METATRACK_CACHE_LIFETIME_VALUE, METATRACK_CACHE_LIFETIME_DESCRIPTION);
        puid_cache_lifetime = settings->loadSetting(setting_class_id, PUID_CACHE_LIFETIME_KEY, PUID_CACHE_LIFETIME_VALUE, PUID_CACHE_LIFETIME_DESCRIPTION);

	/* load settings for other classes */
	fmconst->loadSettings();
	filereader->loadSettings();
	webservice->loadSettings();
	puidgen->loadSettings();
	webfetcher->loadSettings();
}

void Locutus::scanDirectory(string directory) {
	/* clear data */
	grouped_files.clear();
	files.clear();
	/* parse directory */
	filereader->scanFiles(directory);
	/* generate puids */
	puidgen->generatePUIDs();
	/* lookup */
	webfetcher->lookup();
	/* save changes */
	// TODO
}

/* main */
int main() {
	//while (true) {
		Locutus *locutus = new Locutus();
		long sleeptime = locutus->run();
		delete locutus;
		usleep(sleeptime);
	//}
	return 0;
}
