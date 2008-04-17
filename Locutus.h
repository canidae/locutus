#ifndef LOCUTUS_H
/* defines */
#define LOCUTUS_H

/* includes */
#include <iostream>
#include "Matcher.h"
#include "WebService.h"

/* namespace */
using namespace std;

/* Locutus */
class Locutus {
	public:
		/* variables */
		Matcher *matcher;
		WebService *webservice;

		/* constructors */
		Locutus();

		/* destructors */
		~Locutus();

		/* methods */
		void run();
};
#endif
