#include "Locutus.h"

/* constructors */
Locutus::Locutus() {
	levenshtein = new Levenshtein();
	webservice = new WebService();
}

/* destructors */
Locutus::~Locutus() {
	delete levenshtein;
	delete webservice;
}

/* methods */
void Locutus::run() {
	//webservice->fetchRelease("blahblahblah");
	Metadata t1(42);
	Metadata t2(40);
	t1.setValue(ARTIST, "Europe");
	t1.setValue(ALBUM, "The Final Countdown");
	t1.setValue(TITLE, "The Final Countdown");
	t1.setValue(TRACKNUMBER, "1");
	t2.setValue(ARTIST, "Europe");
	t2.setValue(ALBUM, "The Final Countdown");
	t2.setValue(TITLE, "The Final Countdown");
	t2.setValue(TRACKNUMBER, "1");
	cout << t1.equalMetadata(t2) << endl;

	FileMetadata t3(levenshtein, "FIXME", 38);
	t3.setValue(ARTIST, "The Final Countdown");
	t3.setValue(ALBUM, "The Final Countdown");
	t3.setValue(TITLE, "The Final Countdown");
	t3.setValue(TRACKNUMBER, "1");
	cout << t3.compareWithMetadata(t1) << endl;
}

/* main */
int main() {
	Locutus locutus;
	locutus.run();
	return 0;
}
