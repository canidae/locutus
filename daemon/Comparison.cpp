#include "Comparison.h"

using namespace std;

/* constructors/destructor */
Comparison::Comparison(Metafile *metafile, Track *track, bool mbid_match, bool puid_match, double score) : metafile(metafile), track(track), mbid_match(mbid_match), puid_match(puid_match), score(score), total_score(score * (mbid_match ? 3 : (puid_match ? 2 : 1))) {
}

Comparison::~Comparison() {
}
