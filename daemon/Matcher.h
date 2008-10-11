#ifndef MATCHER_H
#define MATCHER_H
/* settings */
#define ALBUM_WEIGHT_KEY "album_weight"
#define ALBUM_WEIGHT_VALUE 100.0
#define ALBUM_WEIGHT_DESCRIPTION ""
#define ARTIST_WEIGHT_KEY "artist_weight"
#define ARTIST_WEIGHT_VALUE 100.0
#define ARTIST_WEIGHT_DESCRIPTION ""
#define COMBINE_THRESHOLD_KEY "combine_threshold"
#define COMBINE_THRESHOLD_VALUE 0.80
#define COMBINE_THRESHOLD_DESCRIPTION ""
#define DURATION_LIMIT_KEY "duration_limit"
#define DURATION_LIMIT_VALUE 15000.0
#define DURATION_LIMIT_DESCRIPTION ""
#define DURATION_MUST_MATCH_KEY "duration_must_match"
#define DURATION_MUST_MATCH_VALUE true
#define DURATION_MUST_MATCH_DESCRIPTION "Demand that the difference between duration of file and track we're matching against is less or equal to duration_limit"
#define DURATION_WEIGHT_KEY "duration_weight"
#define DURATION_WEIGHT_VALUE 100.0
#define DURATION_WEIGHT_DESCRIPTION ""
#define MBID_LOOKUP_KEY "mbid_lookup"
#define MBID_LOOKUP_VALUE true
#define MBID_LOOKUP_DESCRIPTION "Look up tracks using MBID if it's present"
#define METADATA_MIN_SCORE_KEY "metadata_min_score"
#define METADATA_MIN_SCORE_VALUE 0.75
#define METADATA_MIN_SCORE_DESCRIPTION "Minimum value for when a metadata lookup is considered a match. Must be between 0.0 and 1.0"
#define ONLY_SAVE_COMPLETE_ALBUMS_KEY "only_save_complete_albums"
#define ONLY_SAVE_COMPLETE_ALBUMS_VALUE true
#define ONLY_SAVE_COMPLETE_ALBUMS_DESCRIPTION "Only save albums where we found a file for every track"
#define ONLY_SAVE_IF_ALL_MATCH_KEY "only_save_if_all_match"
#define ONLY_SAVE_IF_ALL_MATCH_VALUE true
#define ONLY_SAVE_IF_ALL_MATCH_DESCRIPTION "Only save files if every file in a group match a track"
#define PUID_LOOKUP_KEY "puid_lookup"
#define PUID_LOOKUP_VALUE true
#define PUID_LOOKUP_DESCRIPTION "Look up tracks using PUID which will be generated if necessary"
#define PUID_MIN_SCORE_KEY "puid_min_score"
#define PUID_MIN_SCORE_VALUE 0.50
#define PUID_MIN_SCORE_DESCRIPTION "Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0"
#define SAVE_MATCH_THRESHOLD_KEY "save_match_threshold"
#define SAVE_MATCH_THRESHOLD_VALUE 0.25
#define SAVE_MATCH_THRESHOLD_DESCRIPTION "Minimum value for a match to be saved"
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

class Album;
class Database;
class Match;
class Metafile;
class Metatrack;
class WebService;

struct AlbumMatch {
	Album *album;
	std::map<std::string, std::vector<Match *> > matches;
};

class Matcher {
	public:
		Matcher(Database *database, WebService *webservice);
		~Matcher();

		void match(const std::string &group, const std::vector<Metafile *> &files);

	private:
		Database *database;
		WebService *webservice;
		bool duration_must_match;
		bool mbid_lookup;
		bool only_save_complete_albums;
		bool only_save_if_all_match;
		bool puid_lookup;
		double album_weight;
		double artist_weight;
		double combine_threshold;
		double duration_limit;
		double duration_weight;
		double metadata_min_score;
		double puid_min_score;
		double save_match_threshold;
		double title_weight;
		double tracknumber_weight;
		std::map<std::string, AlbumMatch> ams;

		void clearAlbumMatch();
		void compareFilesWithAlbum(AlbumMatch *am, const std::vector<Metafile *> &files);
		Match *compareMetafileWithMetatrack(Metafile *metafile, Metatrack *metatrack, Track *track = NULL);
		bool loadAlbum(const std::string &mbid, const std::vector<Metafile *> files);
		void lookupMBIDs(const std::vector<Metafile *> &files);
		void lookupPUIDs(const std::vector<Metafile *> &files);
		void matchFilesToAlbums(const std::vector<Metafile *> &files);
		void searchMetadata(const std::string &group, const std::vector<Metafile *> &files);
};
#endif
