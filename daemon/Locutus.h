#ifndef LOCUTUS_H
#define LOCUTUS_H
/* settings */
#define ALBUM_CACHE_LIFETIME_KEY "album_cache_lifetime"
#define ALBUM_CACHE_LIFETIME_VALUE 3
#define ALBUM_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."
#define METATRACK_CACHE_LIFETIME_KEY "metatrack_cache_lifetime"
#define METATRACK_CACHE_LIFETIME_VALUE 3
#define METATRACK_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since metatrack was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."
#define PUID_CACHE_LIFETIME_KEY "puid_cache_lifetime"
#define PUID_CACHE_LIFETIME_VALUE 3
#define PUID_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since puid was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."
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
#include <string>
#include <vector>

class Database;
class FileNamer;
class Metafile;
class PUIDGenerator;
class Matcher;
class WebService;

class Locutus {
	public:
		Database *database;
		WebService *webservice;
		FileNamer *filenamer;
		PUIDGenerator *puidgen;
		Matcher *matcher;
		std::vector<Metafile *> files;
		std::map<std::string, std::vector<Metafile *> > grouped_files;
		double album_weight;
		double artist_weight;
		double combine_threshold;
		double duration_weight;
		double duration_limit;
		double title_weight;
		double tracknumber_weight;
		int album_cache_lifetime;
		int metatrack_cache_lifetime;
		int puid_cache_lifetime;

		Locutus(Database *database);
		~Locutus();

		long run();

	private:
		void loadSettings();
		void removeGoneFiles();
		void scanDirectory(const std::string &directory);
};
#endif
