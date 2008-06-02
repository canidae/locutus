#ifndef LOCUTUS_H
/* defines */
#define LOCUTUS_H
#define DEBUG_ERROR 3 // error that will kill locutus
#define DEBUG_WARNING 2 // a serious problem, but won't kill locutus
#define DEBUG_NOTICE 1 // usually follows a warning for more context
#define DEBUG_INFO 0 // just telling the user what we're doing
/* settings */
#define LOCUTUS_CLASS "Locutus"
#define LOCUTUS_CLASS_DESCRIPTION "General settings for Locutus"
#define ALBUM_CACHE_LIFETIME_KEY "album_cache_lifetime"
#define ALBUM_CACHE_LIFETIME_VALUE 3
#define ALBUM_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."
#define PUID_CACHE_LIFETIME_KEY "puid_cache_lifetime"
#define PUID_CACHE_LIFETIME_VALUE 3
#define PUID_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since puid was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."

/* forward declare */
class Locutus;

/* includes */
#include <iostream>
#include <map>
#include <string>
#include <vector>
#include "Album.h"
#include "Database.h"
#include "FileMetadataConstants.h"
#include "FileReader.h"
#include "Levenshtein.h"
#include "Metafile.h"
#include "PUIDGenerator.h"
#include "Settings.h"
#include "WebFetcher.h"
#include "WebService.h"

/* namespace */
using namespace std;

/* Locutus */
class Locutus {
	public:
		/* variables */
		Database *database;
		FileMetadataConstants *fmconst;
		Levenshtein *levenshtein;
		Settings *settings;
		WebService *webservice;
		FileReader *filereader;
		PUIDGenerator *puidgen;
		WebFetcher *webfetcher;
		vector<Metafile *> files;
		map<string, vector<Metafile *> > grouped_files;

		/* constructors */
		Locutus();

		/* destructors */
		~Locutus();

		/* methods */
		void debug(int level, string text);
		long run();

	private:
		/* variables */
		ofstream *debugfile;
		int setting_class_id;
		int album_cache_lifetime;
		int puid_cache_lifetime;

		/* methods */
		void cleanCache();
		void loadSettings();
		void scanDirectory(string directory);
};
#endif
