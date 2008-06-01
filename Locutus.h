#ifndef LOCUTUS_H
/* defines */
#define LOCUTUS_H
#define DEBUG_ERROR 3 // error that will kill locutus
#define DEBUG_WARNING 2 // a serious problem, but won't kill locutus
#define DEBUG_NOTICE 1 // usually follows a warning for more context
#define DEBUG_INFO 0 // just telling the user what we're doing

/* forward declare */
class Locutus;

/* includes */
#include <iostream>
#include <map>
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
		/* reconsider structure of stuff below */
		vector<Metafile *> files;
		map<string, vector<Metafile *> > grouped_files; // album/directory, files

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

		/* methods */
		void loadSettings();
		void scanDirectory(string directory);
};
#endif
