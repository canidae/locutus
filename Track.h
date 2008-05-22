#ifndef TRACK_H
/* defines */
#define TRACK_H

/* forward declare */
class Track;

/* includes */
#include <string>
#include "Album.h"
#include "Artist.h"
#include "Locutus.h"

/* namespaces */
using namespace std;

/* Track */
class Track {
	public:
		/* variables */
		Album *album;
		Artist *artist;
		int duration;
		string mbid;
		string title;
		string tracknumber;

		/* constructors */
		Track(Locutus *locutus, Album *album, Artist *artist);

		/* destructors */
		~Track();

		/* methods */
		bool saveToCache();

	private:
		/* variables */
		Locutus *locutus;
};
#endif
