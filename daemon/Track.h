#ifndef TRACK_H
#define TRACK_H

#include <string>
#include "Artist.h"
#include "Metatrack.h"

class Album;

class Track {
	public:
		/* variables */
		Album *album;
		Artist artist;
		int id;
		int duration;
		int tracknumber;
		std::string mbid;
		std::string title;

		/* constructors/destructor */
		Track(Album *album = NULL);
		~Track();

		/* methods */
		Metatrack getAsMetatrack() const;
};
#endif
