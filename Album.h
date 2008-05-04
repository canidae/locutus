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
		string mbid;
		string type;
		string title;
		string released;
		string asin;
		string artist_mbid;
		string artist_type;
		string artist_name;
		string artist_sortname;

		/* constructors */
		Album();

		/* destructors */
		~Album();

		/* methods */
		void clear();
};
#endif
