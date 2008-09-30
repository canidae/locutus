#ifndef DEBUG_H
#define DEBUG_H

extern "C" {
#include <sys/stat.h>
};
#include <fstream>
#include <iostream>
#include <string>

class Debug {
	public:
		Debug();
		~Debug();

		void error(const std::string &text);
		void info(const std::string &text);
		void notice(const std::string &text);
		void warning(const std::string &text);

	private:
		std::ofstream debugfile;
		std::string timestamp;

		std::string &printTime();
};
#endif
