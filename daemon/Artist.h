#ifndef ARTIST_H
/* defines */
#define ARTIST_H

/* forward declare */
class Artist;

/* includes */
#include <string>

/* namespaces */
using namespace std;

/* Artist */
class Artist {
	public:
		/* variables */
		string mbid;
		string name;
		string sortname;

		/* constructors */
		Artist();

		/* destructors */
		~Artist();
};
#endif
