#ifndef LOCUTUS_H
/* defines */
#define LOCUTUS_H

/* forward declare */
class Locutus;

/* includes */
#include <iostream>
#include <map>
#include <vector>
#include "Database.h"
#include "FileMetadata.h"
#include "FileMetadataConstants.h"
#include "FileReader.h"
#include "Levenshtein.h"
#include "Metadata.h"
#include "PUIDGenerator.h"
#include "Settings.h"
#include "WebFetcher.h"
#include "WebService.h"

/* namespace */
using namespace ost;
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
		vector<FileMetadata> files;
		map<string, vector<int> > grouped_files; // album/directory, files
		vector<int> gen_puid_queue; // files missing puid
		vector<int> lookup_puid_queue; // files with puid

		/* constructors */
		Locutus();

		/* destructors */
		~Locutus();

		/* methods */
		void loadSettings();
		long run();
};
#endif
