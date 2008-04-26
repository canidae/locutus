#ifndef LOCUTUS_H
/* defines */
#define LOCUTUS_H

/* forward declare */
class Locutus;

/* includes */
#include <iostream>
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

		/* constructors */
		Locutus();

		/* destructors */
		~Locutus();

		/* methods */
		void run();

	private:
		/* variables */
		FileReader *filereader;
};
#endif
