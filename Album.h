#ifndef ALBUM_H
/* defines */
#define ALBUM_H

/* forward declare */
class Album;

/* includes */
#include <string>
#include <vector>
#include "Artist.h"
#include "Locutus.h"
#include "Track.h"

/* namespaces */
using namespace std;

/* Album */
class Album {
	public:
		/* variables */
		Artist *artist;
		string mbid;
		string released;
		string title;
		string type;
		vector<Track *> tracks;

		/* constructors */
		Album(Locutus *locutus);

		/* destructors */
		~Album();

		/* methods */
		bool loadFromCache(string mbid);
		bool saveToCache();

	private:
		/* variables */
		Locutus *locutus;
};
#endif
