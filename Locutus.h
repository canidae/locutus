#ifndef LOCUTUS_H
/* defines */
#define LOCUTUS_H

/* forward declare */
class Locutus;

/* includes */
#include <iostream>
#include "Database.h"
#include "FileMetadata.h"
#include "FileReader.h"
#include "Levenshtein.h"
#include "Metadata.h"
#include "WebService.h"

/* namespace */
using namespace ost;
using namespace std;

/* Locutus */
class Locutus {
	public:
		/* variables */
		Database *database;
		Levenshtein *levenshtein;
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
