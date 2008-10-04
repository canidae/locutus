#ifndef MATCH_H
#define MATCH_H

#include <string>

class Match {
	public:
		std::string filename;
		std::string track_mbid;
		bool mbid_match;
		bool puid_match;
		double meta_score;
		double total_score;

		Match(const std::string &filename = "", const std::string &track_mbid = "", bool mbid_match = false, bool puid_match = false, double meta_score = 0.0);
		~Match();
};
#endif
