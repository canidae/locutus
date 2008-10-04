#ifndef MATCH_H
#define MATCH_H

class Metafile;
class Track;

class Match {
	public:
		Metafile *metafile;
		Track *track;
		bool mbid_match;
		bool puid_match;
		double meta_score;

		Match();
		~Match();
};
#endif
