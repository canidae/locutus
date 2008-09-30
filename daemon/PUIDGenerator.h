#ifndef PUIDGENERATOR_H
#define PUIDGENERATOR_H
#define INBUF_SIZE 4096

extern "C" {
#include <avcodec.h>
}
#include <sstream>
#include <string>

class Locutus; // XXX

class PUIDGenerator {
	public:
		/* constructors/destructor */
		PUIDGenerator(Locutus *locutus);
		~PUIDGenerator();

		/* methods */
		const std::string &generatePUID(const std::string &filename);
		void loadSettings();

	private:
		/* variables */
		Locutus *locutus;
		std::string puid;
};
#endif
