#ifndef MATCH_H
#define MATCH_H

#include <string>

class Metafile;
class Track;

class Match {
	public:
		Metafile *metafile;
		Track *track;
		bool mbid_match;
		bool puid_match;
		double meta_score;
		double total_score;

		explicit Match(Metafile *metafile = NULL, Track *track = NULL, bool mbid_match = false, bool puid_match = false, double meta_score = 0.0);
		~Match();
};
#endif
