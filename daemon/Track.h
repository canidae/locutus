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
#include "Metatrack.h"

/* namespaces */
using namespace std;

/* Track */
class Track {
	public:
		/* variables */
		Album *album;
		Artist *artist;
		int id;
		int duration;
		int tracknumber;
		string mbid;
		string title;

		/* constructors */
		Track(Locutus *locutus, Album *album, Artist *artist);

		/* destructors */
		~Track();

		/* methods */
		Metatrack getAsMetatrack() const;
		bool saveToCache() const;

	private:
		/* variables */
		Locutus *locutus;
};
#endif
