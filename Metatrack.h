#ifndef METATRACK_H
/* defines */
#define METATRACK_H

/* forward declare */
class Metatrack;

/* includes */
#include <string>
#include "Locutus.h"
#include "XMLNode.h"

/* namespaces */
using namespace std;

/* Metatrack */
class Metatrack {
	public:
		/* variables */
		int duration;
		int tracknumber;
		string track_mbid;
		string track_title;
		string artist_mbid;
		string artist_name;
		string album_mbid;
		string album_title;
		string puid;

		/* constructors */
		Metatrack(Locutus *locutus);

		/* destructors */
		~Metatrack();

		/* methods */
		bool readFromXML(XMLNode *track);
		bool saveToCache();

	private:
		/* variables */
		Locutus *locutus;
};
#endif
