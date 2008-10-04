#include "Match.h"

using namespace std;

Match::Match(const string &filename, const string &track_mbid, bool mbid_match, bool puid_match, double meta_score) : filename(filename), track_mbid(track_mbid), mbid_match(mbid_match), puid_match(puid_match), meta_score(meta_score), total_score(meta_score * (mbid_match ? 3 : (puid_match ? 2 : 1))) {
}

Match::~Match() {
}
