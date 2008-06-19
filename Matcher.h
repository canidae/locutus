#ifndef MATCHER_H
/* defines */
#define MATCHER_H
/* setting class */
#define MATCHER_CLASS "Matcher"
#define MATCHER_CLASS_DESCRIPTION "TODO"
/* default values */
#define PUID_MIN_SCORE_KEY "puid_min_score"
#define PUID_MIN_SCORE_VALUE 0.50
#define PUID_MIN_SCORE_DESCRIPTION "Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0"
#define METADATA_MIN_SCORE_KEY "metadata_min_score"
#define METADATA_MIN_SCORE_VALUE 0.75
#define METADATA_MIN_SCORE_DESCRIPTION "Minimum value for when a metadata lookup is considered a match. Must be between 0.0 and 1.0"

/* forward declare */
class Matcher;

/* includes */
#include <map>
#include <string>
#include <vector>
#include "Album.h"
#include "Metafile.h"
#include "Metatrack.h"
#include "Locutus.h"

/* namespaces */
using namespace std;

/* matching */
struct Match {
	bool mbid_match;
	bool puid_match;
	double meta_score;
};

struct MatchGroup {
	map<string, Album *> albums;
	map<string, Match> best_score;
	map<string, vector<map<string, Match> > > scores;
};

/* Matcher */
class Matcher {
	public:
		/* variables */

		/* constructors */
		Matcher(Locutus *locutus);

		/* destructors */
		~Matcher();

		/* methods */
		void loadSettings();
		void match();

	private:
		/* variables */
		Locutus *locutus;
		MatchGroup mg;
		int setting_class_id;
		double puid_min_score;
		double metadata_min_score;

		/* methods */
		void compareFilesWithAlbum(vector<Metafile *> *files, string album_mbid);
		void clearMatchGroup();
		string escapeWSString(string text);
		string makeWSTrackQuery(string group, Metafile *mf);
		bool saveMatchToCache(string filename, string track_mbid, double score);
		void setBestScore(string filename, Match match);
};
#endif
