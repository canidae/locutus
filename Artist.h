#ifndef ARTIST_H
/* defines */
#define ARTIST_H

/* forward declare */
class Artist;

/* includes */
#include <string>
#include "Locutus.h"

/* namespaces */
using namespace std;

/* Artist */
class Artist {
	public:
		/* variables */
		string mbid;
		string name;
		string sortname;

		/* constructors */
		Artist(Locutus *locutus);

		/* destructors */
		~Artist();

		/* methods */
		bool saveToCache();

	private:
		/* variables */
		Locutus *locutus;
};
#endif
