#ifndef ALBUM_H
/* defines */
#define ALBUM_H

/* forward declare */
class Album;

/* includes */
#include <string>
#include <vector>
#include "Locutus.h"
#include "Track.h"

/* namespaces */
using namespace std;

/* Album */
class Album {
	public:
		/* variables */
		Locutus *locutus;
		vector<Track *> tracks;

		/* constructors */
		Album(Locutus *locutus);

		/* destructors */
		~Album();

		/* methods */
		bool loadFromCache(string mbid);

	private:
		/* variables */

		/* methods */
};
#endif
