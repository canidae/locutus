#ifndef MATCHER_H
#define MATCHER_H
/* settings */
#define PUID_MIN_SCORE_KEY "puid_min_score"
#define PUID_MIN_SCORE_VALUE 0.50
#define PUID_MIN_SCORE_DESCRIPTION "Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0"
#define METADATA_MIN_SCORE_KEY "metadata_min_score"
#define METADATA_MIN_SCORE_VALUE 0.75
#define METADATA_MIN_SCORE_DESCRIPTION "Minimum value for when a metadata lookup is considered a match. Must be between 0.0 and 1.0"

#include <map>
#include <sstream>
#include <string>
#include <vector>
#include "Metafile.h"
#include "Metatrack.h"

/* XXX */
#include "Database.h"
#include "FileHandler.h"
#include "WebService.h"
/* XXX */

class Album;
class Locutus;

struct MatchGroup {
	Album *album;
	std::vector<std::map<Metafile *, Match> > scores; // tracknum, file, match
};

class Matcher {
	public:
		Matcher(Locutus *locutus);
		~Matcher();

		void match(const std::string &group, const std::vector<Metafile *> &files);

	private:
		Locutus *locutus;
		std::map<std::string, MatchGroup> mgs;
		double puid_min_score;
		double metadata_min_score;

		void compareFilesWithAlbum(const std::string &mbid, const std::vector<Metafile *> &files);
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
