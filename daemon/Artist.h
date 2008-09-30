#ifndef ARTIST_H
#define ARTIST_H

#include <string>

class Artist {
	public:
		/* variables */
		std::string mbid;
		std::string name;
		std::string sortname;

		/* constructors/destructor */
		Artist();
		~Artist();
};
#endif
