#ifndef PUIDGENERATOR_H
/* defines */
#define PUIDGENERATOR_H
/* setting class */
#define PUIDGENERATOR_CLASS "PUIDGenerator"
#define PUIDGENERATOR_CLASS_DESCRIPTION "TODO"

/* forward declare */
class PUIDGenerator;

/* includes */
#include <string>
#include "Locutus.h"

/* namespaces */
using namespace std;

/* PUIDGenerator */
class PUIDGenerator {
	public:
		/* variables */

		/* constructors */
		PUIDGenerator(Locutus *locutus);

		/* destructors */
		~PUIDGenerator();

		/* methods */
		void generatePUIDs();
		void loadSettings();

	private:
		/* variables */
		Locutus *locutus;
		int setting_class_id;
};
#endif
