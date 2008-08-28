#ifndef ALBUM_H
/* defines */
#define ALBUM_H

/* forward declare */
class Album;

/* includes */
#include <string>
#include <vector>
#include "Artist.h"
#include "Locutus.h"
#include "Track.h"
#include "XMLNode.h"

/* namespaces */
using namespace std;

/* Album */
class Album {
	public:
		/* variables */
		Artist *artist;
		string mbid;
		string released;
		string title;
		string type;
		vector<Track *> tracks;

		/* constructors */
		Album(Locutus *locutus = NULL);

		/* destructors */
		~Album();

		/* methods */
		bool loadFromCache(const string &mbid);
		bool retrieveFromWebService(const string &mbid);
		bool saveToCache() const;

	private:
		/* variables */
		Locutus *locutus;
};
#endif
