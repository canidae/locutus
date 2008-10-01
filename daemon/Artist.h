#ifndef ARTIST_H
#define ARTIST_H

#include <string>

class Artist {
	public:
		std::string mbid;
		std::string name;
		std::string sortname;

		Artist();
		~Artist();
};
#endif
