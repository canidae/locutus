#include "Album.h"
#include "Database.h"
#include "Debug.h"
#include "FileHandler.h"
#include "Levenshtein.h"
#include "Locutus.h"
#include "Metafile.h"
#include "PostgreSQL.h"
#include "PUIDGenerator.h"
#include "Matcher.h"
#include "WebService.h"

using namespace std;

/* constructors/destructor */
Locutus::Locutus() {
	database = new PostgreSQL("host=localhost user=locutus password=locutus dbname=locutus");
	webservice = new WebService(database);
	filehandler = new FileHandler(this);
	puidgen = new PUIDGenerator();
	matcher = new Matcher(this);
}

Locutus::~Locutus() {
	for (vector<Metafile *>::iterator mf = files.begin(); mf != files.end(); ++mf)
		delete (*mf);
	delete puidgen;
	delete matcher;
	delete webservice;
	delete filehandler;
	delete database;
}

/* methods */
long Locutus::run() {
	/* load settings */
	Debug::info("Loading settings");
	loadSettings();
	/* parse sorted directory */
	Debug::info("Scanning output directory");
	scanDirectory(filehandler->output_dir);
	/* parse unsorted directory */
	Debug::info("Scanning input directory");
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
        metatrack_cache_lifetime = database->loadSetting(METATRACK_CACHE_LIFETIME_KEY, METATRACK_CACHE_LIFETIME_VALUE, METATRACK_CACHE_LIFETIME_DESCRIPTION);
        puid_cache_lifetime = database->loadSetting(PUID_CACHE_LIFETIME_KEY, PUID_CACHE_LIFETIME_VALUE, PUID_CACHE_LIFETIME_DESCRIPTION);
	album_weight = database->loadSetting(ALBUM_WEIGHT_KEY, ALBUM_WEIGHT_VALUE, ALBUM_WEIGHT_DESCRIPTION);
	artist_weight = database->loadSetting(ARTIST_WEIGHT_KEY, ARTIST_WEIGHT_VALUE, ARTIST_WEIGHT_DESCRIPTION);
	combine_threshold = database->loadSetting(COMBINE_THRESHOLD_KEY, COMBINE_THRESHOLD_VALUE, COMBINE_THRESHOLD_DESCRIPTION);
	duration_limit = database->loadSetting(DURATION_LIMIT_KEY, DURATION_LIMIT_VALUE, DURATION_LIMIT_DESCRIPTION);
	duration_weight = database->loadSetting(DURATION_WEIGHT_KEY, DURATION_WEIGHT_VALUE, DURATION_WEIGHT_DESCRIPTION);
	title_weight = database->loadSetting(TITLE_WEIGHT_KEY, TITLE_WEIGHT_VALUE, TITLE_WEIGHT_DESCRIPTION);
	tracknumber_weight = database->loadSetting(TRACKNUMBER_WEIGHT_KEY, TRACKNUMBER_WEIGHT_VALUE, TRACKNUMBER_WEIGHT_DESCRIPTION);

	/* load settings for other classes */
	filehandler->loadSettings();
	webservice->loadSettings();
	puidgen->loadSettings();
	matcher->loadSettings();
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
		/* initialize static classes */
		Debug::open("locutus.log");
		Levenshtein::initialize();

		Locutus *locutus = new Locutus();
		Debug::info("Checking files...");
		long sleeptime = locutus->run();
		Debug::info("Finished checking files");
		delete locutus;

		/* clear static classes */
		Levenshtein::clear();
		Debug::close();

		usleep(sleeptime);
	//}
	return 0;
}
