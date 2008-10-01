#ifndef PUIDGENERATOR_H
#define PUIDGENERATOR_H
#define INBUF_SIZE 4096

extern "C" {
#include <avcodec.h>
}
#include <sstream>
#include <string>

class PUIDGenerator {
	public:
		PUIDGenerator();
		~PUIDGenerator();

		const std::string &generatePUID(const std::string &filename);
		void loadSettings();

	private:
		std::string puid;
};
#endif
