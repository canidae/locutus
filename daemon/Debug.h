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
		static bool close();
		static void error(const std::string &text);
		static void info(const std::string &text);
		static bool open(const std::string &file);
		static void notice(const std::string &text);
		static void warning(const std::string &text);

	private:
		static bool initialized;
		static std::ofstream debugfile;
		static std::string timestamp;

		static std::string &printTime();
};
#endif
