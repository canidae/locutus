#ifndef MATCH_H
#define MATCH_H

#include <string>
#include "Metatrack.h"

class Metafile;

class Match {
	public:
		Metafile *metafile;
		Metatrack metatrack;
		bool mbid_match;
		bool puid_match;
		double meta_score;
		double total_score;

		Match(Metafile *metafile, const Metatrack &metatrack, bool mbid_match, bool puid_match, double meta_score);
		~Match();
};
#endif
