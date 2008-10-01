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
		PUIDGenerator(Locutus *locutus);
		~PUIDGenerator();

		const std::string &generatePUID(const std::string &filename);
		void loadSettings();

	private:
		Locutus *locutus;
		std::string puid;
};
#endif
