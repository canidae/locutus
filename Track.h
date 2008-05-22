#ifndef TRACK_H
/* defines */
#define TRACK_H

/* forward declare */
class Track;

/* includes */
#include <string>
#include "Album.h"
#include "Locutus.h"

/* namespaces */
using namespace std;

/* Track */
class Track {
	public:
		/* variables */
		Album *album;
		int duration;
		string artist;
		string artistid;
		string artistsort;
		string puid;
		string released;
		string title;
		string trackid;
		string tracknumber;

		/* constructors */
		Track(Locutus *locutus, Album *album);

		/* destructors */
		~Track();

		/* methods */
		bool saveToCache();

	private:
		/* variables */
		Locutus *locutus;

		/* methods */
};
#endif
