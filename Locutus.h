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
#include "Settings.h"
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
		vector<FileMetadata> files;
		map<string, vector<int> > grouped_files; // album/directory, files
		vector<int> no_puid_files; // files missing puid
		vector<int> puid_files; // files with puid

		/* constructors */
		Locutus();

		/* destructors */
		~Locutus();

		/* methods */
		void loadSettings();
		void run();

	private:
		/* variables */
		FileReader *filereader;
};
#endif
