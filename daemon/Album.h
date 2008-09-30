#ifndef ALBUM_H
#define ALBUM_H

#include <string>
#include <vector>
#include "Artist.h"
#include "Track.h"

class Album {
	public:
		/* variables */
		Artist artist;
		std::string mbid;
		std::string released;
		std::string title;
		std::string type;
		std::vector<Track> tracks;

		/* constructors/destructor */
		Album(const std::string &mbid = "");
		~Album();
};
#endif
