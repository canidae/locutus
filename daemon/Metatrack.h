#ifndef METATRACK_H
#define METATRACK_H

#include <string>

class Metatrack {
	public:
		int duration;
		int tracknumber;
		std::string album_mbid;
		std::string album_title;
		std::string artist_mbid;
		std::string artist_name;
		std::string puid;
		std::string track_mbid;
		std::string track_title;

		Metatrack();
		~Metatrack();
};
#endif
