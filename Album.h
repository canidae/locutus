#ifndef ALBUM_H
/* defines */
#define ALBUM_H

/* includes */
#include <vector>
#include "Metadata.h"

/* namespaces */
using namespace std;

/* Release */
class Album {
	public:
		/* variables */
		vector<Metadata> tracks;
		string artist_mbid;
		string artist_name;
		string artist_sortname;
		string mbid;
		string released;
		string title;
		string type;

		/* constructors */
		Album();

		/* destructors */
		~Album();

		/* methods */
		void clear();
};
#endif
