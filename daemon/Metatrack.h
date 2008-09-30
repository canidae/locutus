#ifndef METATRACK_H
#define METATRACK_H

#include <string>

class XMLNode;

class Metatrack {
	public:
		/* variables */
		int duration;
		int tracknumber;
		std::string track_mbid;
		std::string track_title;
		std::string artist_mbid;
		std::string artist_name;
		std::string album_mbid;
		std::string album_title;
		std::string puid;

		/* constructors/destructor */
		Metatrack();
		~Metatrack();

		/* methods */
		bool readFromXML(XMLNode *track);
		bool saveToCache() const;
};
#endif
