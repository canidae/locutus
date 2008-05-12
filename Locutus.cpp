#include "Locutus.h"

/* constructors */
Locutus::Locutus() {
	database = new Database();
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
long Locutus::run() {
	/* load settings */
	loadSettings();
	/* parse sorted directory */
	filereader->scanFiles(filereader->output_dir);
	/* generate puids */
	/* lookup */
	/* save changes */
	/* clear data */
	lookup_puid_queue.clear();
	gen_puid_queue.clear();
	grouped_files.clear();
	files.clear();
	/* parse unsorted directory */
	filereader->scanFiles(filereader->input_dir);
	/* generate puids */
	/* lookup */
	/* save changes */
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

/* main */
int main() {
	while (true) {
		Locutus *locutus = new Locutus();
		long sleeptime = locutus->run();
		delete locutus;
		sleep(sleeptime);
	}
	return 0;
}
