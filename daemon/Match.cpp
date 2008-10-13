#include "Match.h"

using namespace std;

/* constructors/destructor */
Match::Match(Metafile *metafile, const Metatrack &metatrack, bool mbid_match, bool puid_match, double meta_score) : metafile(metafile), metatrack(metatrack), mbid_match(mbid_match), puid_match(puid_match), meta_score(meta_score), total_score(meta_score * (mbid_match ? 3 : (puid_match ? 2 : 1))) {
}

Match::~Match() {
}
