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
	webservice->cleanCache();
	/* parse sorted directory */
	scanDirectory(filereader->output_dir);
	/* parse unsorted directory */
	scanDirectory(filereader->input_dir);
	/* submit new puids? */
	/* return */
	return 10000;

	/* old */
	//webservice->fetchAlbum("4e0d7112-28cc-429f-ab55-6a495ce30192");
	/*
	FileMetadata t3(this, "FIXME");
	t3.setValue(ARTIST, "The Final Countdown");
	t3.setValue(ALBUM, "The Final Countdown");
	t3.setValue(TITLE, "The Final Countdown");
	t3.setValue(TRACKNUMBER, "1");
	cout << t3.compareWithMetadata(t1) << endl;
	*/
}

/* private methods */
void Locutus::loadSettings() {
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
