#ifndef ALBUM_H
/* defines */
#define ALBUM_H

/* includes */
#include <vector>
#include "Metadata.h"

/* namespaces */
using namespace std;

/* Release */
/* TODO
 * http://musicbrainz.org/ws/1/release/4e0d7112-28cc-429f-ab55-6a495ce30192?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels
 * http://musicbrainz.org/ws/1/release/40ce5b7b-f9bf-4620-a250-c657dfb69e64?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels
 */
class Album {
	public:
		/* variables */
		vector<Metadata> tracks;
		string mbid;
		string type;
		string title;
		string released;
		string asin;

		/* constructors */
		Album();

		/* destructors */
		~Album();

		/* methods */
		void clear();

	private:
		/* variables */

		/* methods */
};
#endif
