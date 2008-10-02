#ifndef TRACK_H
#define TRACK_H

#include <string>
#include "Artist.h"
#include "Metatrack.h"

class Album;

class Track {
	public:
		Album *album;
		Artist artist;
		int id;
		int duration;
		int tracknumber;
		std::string mbid;
		std::string title;

		explicit Track(Album *album = NULL);
		~Track();

		Metatrack getAsMetatrack() const;
};
#endif
