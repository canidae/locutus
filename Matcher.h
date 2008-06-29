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

/* structs */
struct MatchGroup {
	Album *album;
	vector<map<string, Match> > scores; // tracknum, filename, match
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
		void match(const string &group, const vector<Metafile *> &files);

	private:
		/* variables */
		Locutus *locutus;
		map<string, MatchGroup> mgs;
		int setting_class_id;
		double puid_min_score;
		double metadata_min_score;

		/* methods */
		void compareFilesWithAlbum(const string &mbid, const vector<Metafile *> &files);
		void clearMatchGroup();
		string escapeWSString(const string &text) const;
		bool loadAlbum(const string &mbid);
		void lookupMBIDs(const vector<Metafile *> &files);
		void lookupPUIDs(const vector<Metafile *> &files);
		string makeWSTrackQuery(const string &group, const Metafile &mf) const;
		void matchFilesToAlbums();
		bool saveMatchToCache(const string &filename, const string &track_mbid, const double &score) const;
		void searchMetadata(const string &group, const vector<Metafile *> &files);
};
#endif
