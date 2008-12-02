#ifndef COMPARISON_H
#define COMPARISON_H

#include <string>
#include "Metatrack.h"

class Metafile;
class Track;

class Comparison {
	public:
		Metafile *metafile;
		Track *track;
		bool mbid_match;
		bool puid_match;
		double score;
		double total_score;

		Comparison(Metafile *metafile, Track *track, bool mbid_match, bool puid_match, double score);
		~Comparison();
};
#endif
