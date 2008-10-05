#ifndef TRACK_H
#define TRACK_H

#include <string>
#include "Metatrack.h"

class Album;
class Artist;

class Track {
	public:
		Album *album;
		Artist *artist;
		int duration;
		int tracknumber;
		std::string mbid;
		std::string title;

		explicit Track(Album *album);
		~Track();

		Metatrack getAsMetatrack() const;
};
#endif
