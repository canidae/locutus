#ifndef MATCHER_H
#define MATCHER_H
/* settings */
#define PUID_MIN_SCORE_KEY "puid_min_score"
#define PUID_MIN_SCORE_VALUE 0.50
#define PUID_MIN_SCORE_DESCRIPTION "Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0"
#define METADATA_MIN_SCORE_KEY "metadata_min_score"
#define METADATA_MIN_SCORE_VALUE 0.75
#define METADATA_MIN_SCORE_DESCRIPTION "Minimum value for when a metadata lookup is considered a match. Must be between 0.0 and 1.0"
#define ALBUM_WEIGHT_KEY "album_weight"
#define ALBUM_WEIGHT_VALUE 100.0
#define ALBUM_WEIGHT_DESCRIPTION ""
#define ARTIST_WEIGHT_KEY "artist_weight"
#define ARTIST_WEIGHT_VALUE 100.0
#define ARTIST_WEIGHT_DESCRIPTION ""
#define DURATION_LIMIT_KEY "duration_limit"
#define DURATION_LIMIT_VALUE 15000.0
#define DURATION_LIMIT_DESCRIPTION ""
#define DURATION_WEIGHT_KEY "duration_weight"
#define DURATION_WEIGHT_VALUE 100.0
#define DURATION_WEIGHT_DESCRIPTION ""
#define TITLE_WEIGHT_KEY "title_weight"
#define TITLE_WEIGHT_VALUE 100.0
#define TITLE_WEIGHT_DESCRIPTION ""
#define TRACKNUMBER_WEIGHT_KEY "tracknumber_weight"
#define TRACKNUMBER_WEIGHT_VALUE 100.0
#define TRACKNUMBER_WEIGHT_DESCRIPTION ""

#include <map>
#include <sstream>
#include <string>
#include <vector>
#include "Metafile.h"
#include "Metatrack.h"

/* XXX */
#include "Database.h"
#include "FileNamer.h"
#include "WebService.h"
/* XXX */

class Album;
class Locutus;

struct Match {
	bool mbid_match;
	bool puid_match;
	double meta_score;
};

struct MatchGroup {
	Album *album;
	std::vector<std::map<Metafile *, Match> > scores; // tracknum, file, match
};

class Matcher {
	public:
		explicit Matcher(Locutus *locutus);
		~Matcher();

		void match(const std::string &group, const std::vector<Metafile *> &files);

	private:
		Locutus *locutus;
		std::map<std::string, MatchGroup> mgs;
		double puid_min_score;
		double metadata_min_score;
		double album_weight;
		double artist_weight;
		double duration_weight;
		double duration_limit;
		double title_weight;
		double tracknumber_weight;

		void compareFilesWithAlbum(const std::string &mbid, const std::vector<Metafile *> &files);
		Match compareMetafileWithMetatrack(const Metafile &metafile, const Metatrack &metatrack);
		void clearMatchGroup();
		std::string escapeWSString(const std::string &text) const;
		bool loadAlbum(const std::string &mbid);
		void lookupMBIDs(const std::vector<Metafile *> &files);
		void lookupPUIDs(const std::vector<Metafile *> &files);
		std::string makeWSTrackQuery(const std::string &group, const Metafile &mf) const;
		void matchFilesToAlbums(const std::vector<Metafile *> &files);
		bool saveMatchToCache(const std::string &filename, const std::string &track_mbid, const Match &match) const;
		void searchMetadata(const std::string &group, const std::vector<Metafile *> &files);
};
#endif
