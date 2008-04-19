#include "Locutus.h"

/* constructors */
Locutus::Locutus() {
	webservice = new WebService();
}

/* destructors */
Locutus::~Locutus() {
	delete webservice;
}

/* methods */
void Locutus::run() {
	webservice->fetchRelease("blahblahblah");
}

/* main */
int main() {
	Locutus locutus;
	locutus.run();
	return 0;
}
