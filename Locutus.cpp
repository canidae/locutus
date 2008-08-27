#include "Locutus.h"

/* constructors */
Locutus::Locutus() {
	debugfile = new ofstream("locutus.log", ios::app);
	database = new Database(this);
	levenshtein = new Levenshtein();
	settings = new Settings(this);
	webservice = new WebService(this);
	filereader = new FileReader(this);
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
	delete filereader;
	delete levenshtein;
	delete database;
}

/* methods */
void Locutus::debug(const int &level, const string &text) {
	time_t rawtime;
	time(&rawtime);
	string t = asctime(localtime(&rawtime));
	t.erase(t.size() - 1);
	*debugfile << "[" << t << "] ";
	switch (level) {
		case DEBUG_ERROR:
			*debugfile << "[ERROR]   ";
			break;

		case DEBUG_WARNING:
			*debugfile << "[WARNING] ";
			break;

		case DEBUG_NOTICE:
			*debugfile << "[NOTICE]  ";
			break;

		case DEBUG_INFO:
			*debugfile << "[INFO]    ";
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
	scanDirectory(filereader->output_dir);
	/* parse unsorted directory */
	debug(DEBUG_INFO, "Scanning input directory");
	scanDirectory(filereader->input_dir);
	/* submit new puids? */
	/* return */
	return 10000;
}

/* private methods */
void Locutus::loadSettings() {
	/* load general settings */
        setting_class_id = settings->loadClassID(LOCUTUS_CLASS, LOCUTUS_CLASS_DESCRIPTION);
        album_cache_lifetime = settings->loadSetting(setting_class_id, ALBUM_CACHE_LIFETIME_KEY, ALBUM_CACHE_LIFETIME_VALUE, ALBUM_CACHE_LIFETIME_DESCRIPTION);
        metatrack_cache_lifetime = settings->loadSetting(setting_class_id, METATRACK_CACHE_LIFETIME_KEY, METATRACK_CACHE_LIFETIME_VALUE, METATRACK_CACHE_LIFETIME_DESCRIPTION);
        puid_cache_lifetime = settings->loadSetting(setting_class_id, PUID_CACHE_LIFETIME_KEY, PUID_CACHE_LIFETIME_VALUE, PUID_CACHE_LIFETIME_DESCRIPTION);
	album_weight = settings->loadSetting(setting_class_id, ALBUM_WEIGHT_KEY, ALBUM_WEIGHT_VALUE, ALBUM_WEIGHT_DESCRIPTION);
	artist_weight = settings->loadSetting(setting_class_id, ARTIST_WEIGHT_KEY, ARTIST_WEIGHT_VALUE, ARTIST_WEIGHT_DESCRIPTION);
	combine_threshold = settings->loadSetting(setting_class_id, COMBINE_THRESHOLD_KEY, COMBINE_THRESHOLD_VALUE, COMBINE_THRESHOLD_DESCRIPTION);
	duration_limit = settings->loadSetting(setting_class_id, DURATION_LIMIT_KEY, DURATION_LIMIT_VALUE, DURATION_LIMIT_DESCRIPTION);
	duration_weight = settings->loadSetting(setting_class_id, DURATION_WEIGHT_KEY, DURATION_WEIGHT_VALUE, DURATION_WEIGHT_DESCRIPTION);
	title_weight = settings->loadSetting(setting_class_id, TITLE_WEIGHT_KEY, TITLE_WEIGHT_VALUE, TITLE_WEIGHT_DESCRIPTION);
	tracknumber_weight = settings->loadSetting(setting_class_id, TRACKNUMBER_WEIGHT_KEY, TRACKNUMBER_WEIGHT_VALUE, TRACKNUMBER_WEIGHT_DESCRIPTION);

	/* load settings for other classes */
	filereader->loadSettings();
	webservice->loadSettings();
	puidgen->loadSettings();
	matcher->loadSettings();
}

void Locutus::scanDirectory(const string &directory) {
	/* clear data */
	grouped_files.clear();
	files.clear();
	/* parse directory */
	filereader->scanFiles(directory);
	/* generate puids */
	puidgen->generatePUIDs();
	/* match files */
	//matcher->match();
	/* save changes */
	// TODO
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
