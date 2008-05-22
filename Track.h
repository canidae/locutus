#ifndef TRACK_H
/* defines */
#define TRACK_H

/* includes */
#include <string>

/* namespaces */
using namespace std;

/* Track */
class Track {
	public:
		/* variables */
		string album;
		string albumartist;
		string albumartistid;
		string albumartistsort;
		string artist;
		string artistid;
		string artistsort;
		string puid;
		string title;
		string trackid;
		string tracknumber;
		string year;
		int duration;

		/* constructors */
		Track();

		/* destructors */
		~Track();

		/* methods */

	private:
		/* variables */

		/* methods */
};
#endif
