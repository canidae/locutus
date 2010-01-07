// Copyright © 2008-2009 Vidar Wahlberg <canidae@exent.net>
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

#ifndef LOCUTUS_H
#define LOCUTUS_H

#include <list>
#include <map>
#include <string>

/* settings */
#define MUSIC_OUTPUT_KEY "output_directory"
#define MUSIC_OUTPUT_VALUE "/media/music/sorted/"
#define MUSIC_OUTPUT_DESCRIPTION "Output directory. This is the directory Locutus will place files that were matched to tracks in MusicBrainz. Should not be the same directory as, or a subdirectory of 'input_directory' or 'duplicate_directory'."
#define MUSIC_INPUT_KEY "input_directory"
#define MUSIC_INPUT_VALUE "/media/music/unsorted/"
#define MUSIC_INPUT_DESCRIPTION "Input directory. The directory that contains files not yet matched by Locutus. Should not be the same directory as, or a subdirectory of 'output_directory' or 'duplicate_directory'."
#define MUSIC_DUPLICATE_KEY "duplicate_directory"
#define MUSIC_DUPLICATE_VALUE "/media/music/duplicates/"
#define MUSIC_DUPLICATE_DESCRIPTION "Duplicate directory. When Locutus finds duplicates they are placed in this directory. Should not be the same directory as, or a subdirectory of 'input_directory' or 'output_directory'."
#define MAX_GROUP_SIZE_KEY "max_group_size"
#define MAX_GROUP_SIZE_VALUE 250
#define MAX_GROUP_SIZE_DESCRIPTION "Max size of a group. Groups with more files than this will be ignored. This is a precaution against directories with lots of files from different albums, but with no metadata. Such directories cause Locutus to use a lot of memory and CPU while significantly slowing Locutus down."
#define COMBINE_GROUPS_KEY "combine_groups"
#define COMBINE_GROUPS_VALUE true
#define COMBINE_GROUPS_DESCRIPTION "Temporary combine and relookup groups that loaded the same album. May be useful in archives where the files for the same album end up in different groups for some reason, but it will also slow down Locutus and may increase amount of mismatched files."
#define DRY_RUN_KEY "dry_run"
#define DRY_RUN_VALUE true
#define DRY_RUN_DESCRIPTION "Only read files and look them up, don't save and move files. Currently genre won't be looked up during a dry run."
#define LOOKUP_GENRE_KEY "lookup_genre"
#define LOOKUP_GENRE_VALUE false
#define LOOKUP_GENRE_DESCRIPTION "Fetch genre (or tag) from Audioscrobbler before saving a file. If no genre is found then genre is set to an empty string. If this option is set to false, the genre field is left unmodified. Locutus will only look up genre when there's no genre associated with the track or when the file is moved, this is because looking up tag significantly slows down Locutus."

/* how often we should check if we're still active and how often we should poll database */
#define CHECK_ACTIVE_INTERVAL 3
#define DATABASE_POLL_INTERVAL 300

class Audioscrobbler;
class Database;
class FileNamer;
class Matcher;
class Metafile;
class MusicBrainz;

class Locutus {
public:
	bool active;
	static std::string input_dir;
	static std::string output_dir;
	static std::string duplicate_dir;

	explicit Locutus(Database* database);
	~Locutus();

	static void trim(std::string* text);

	void run();

private:
	Audioscrobbler* audioscrobbler;
	Database* database;
	FileNamer* filenamer;
	Matcher* matcher;
	MusicBrainz* musicbrainz;
	bool combine_groups;
	bool dry_run;
	bool lookup_genre;
	int max_group_size;
	int total_files;
	std::list<std::string> dir_queue;
	std::list<std::string> file_queue;
	std::map<std::string, int> groups;

	std::string findDuplicateFilename(Metafile* file);
	bool moveFile(Metafile* file, const std::string& filename);
	bool parseDirectory();
	bool parseFile();
	void saveFile(Metafile* file);
	void scanFiles(const std::string& directory);
};
#endif
