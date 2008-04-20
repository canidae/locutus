#ifndef LOCUTUS_H
/* defines */
#define LOCUTUS_H

/* includes */
#include <iostream>
#include "FileMetadata.h"
#include "Levenshtein.h"
#include "Metadata.h"
#include "WebService.h"

/* namespace */
using namespace std;

/* Locutus */
class Locutus {
	public:
		/* variables */
		Levenshtein *levenshtein;
		WebService *webservice;

		/* constructors */
		Locutus();

		/* destructors */
		~Locutus();

		/* methods */
		void run();
};
#endif
