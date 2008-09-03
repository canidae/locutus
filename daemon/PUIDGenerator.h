#ifndef PUIDGENERATOR_H
/* defines */
#define PUIDGENERATOR_H
/* buffer */
#define INBUF_SIZE 4096

/* forward declare */
class PUIDGenerator;

/* includes */
#include <avcodec.h>
#include <string>
#include "Metafile.h"
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
		const string &generatePUID(const string &filename, int filetype);
		void loadSettings();

	private:
		/* variables */
		Locutus *locutus;
		string puid;
};
#endif
