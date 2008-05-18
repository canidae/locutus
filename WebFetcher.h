#ifndef WEBFETCHER_H
/* defines */
#define WEBFETCHER_H
/* setting class */
#define WEBFETCHER_CLASS "WebFetcher"
#define WEBFETCHER_CLASS_DESCRIPTION "TODO"
/* default values */
#define PUID_MIN_SCORE_KEY "puid_min_score"
#define PUID_MIN_SCORE_VALUE 0.50
#define PUID_MIN_SCORE_DESCRIPTION "Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0"
#define METADATA_MIN_SCORE_KEY "metadata_min_score"
#define METADATA_MIN_SCORE_VALUE 0.75
#define METADATA_MIN_SCORE_DESCRIPTION "Minimum value for when a metadata lookup is considered a match. Must be between 0.0 and 1.0"

/* forward declare */
class WebFetcher;

/* includes */
#include <list>
#include <map>
#include <string>
#include <vector>
#include "Locutus.h"

/* namespaces */
using namespace std;

/* matching */
struct Match {
	vector<int>::size_type file;
	bool mbid_match;
	bool puid_match;
	double meta_score;
};

struct AlbumMatch {
	int file;
	double score;
};

/* WebFetcher */
class WebFetcher {
	public:
		/* variables */

		/* constructors */
		WebFetcher(Locutus *locutus);

		/* destructors */
		~WebFetcher();

		/* methods */
		void loadSettings();
		void lookup();

	private:
		/* variables */
		Locutus *locutus;
		int setting_class_id;
		double puid_min_score;
		double metadata_min_score;
};
#endif
