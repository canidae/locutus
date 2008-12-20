#ifndef CONFIG_H
#define CONFIG_H

#define CONFIG_COMMENT "#"
#define CONFIG_DELIMITER "="
#define CONFIG_WHITESPACE " \t"

#include <map>
#include <string>

class Config {
	public:
		Config();
		~Config();

		std::string getSettingValue(const std::string &setting);

	private:
		std::map<std::string, std::string> settings;
};
#endif
