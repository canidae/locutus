// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
// 
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
// 
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

#include <csignal>
#include <vector>
#include "Audioscrobbler.h"
#include "Config.h"
#include "Database.h"
#include "Debug.h"
#include "FileNamer.h"
#include "Levenshtein.h"
#include "Locutus.h"
#include "Matcher.h"
#include "Metafile.h"
#include "MusicBrainz.h"
#include "PostgreSQL.h"

using namespace std;

Locutus::Locutus(Database *database) : active(true), database(database) {
	audioscrobbler = new Audioscrobbler(database);
	filenamer = new FileNamer(database);
	musicbrainz = new MusicBrainz(database);
	matcher = new Matcher(database, musicbrainz);

	max_group_size = database->loadSettingInt(MAX_GROUP_SIZE_KEY, MAX_GROUP_SIZE_VALUE, MAX_GROUP_SIZE_DESCRIPTION);
	combine_groups = database->loadSettingBool(COMBINE_GROUPS_KEY, COMBINE_GROUPS_VALUE, COMBINE_GROUPS_DESCRIPTION);
	dry_run = database->loadSettingBool(DRY_RUN_KEY, DRY_RUN_VALUE, DRY_RUN_DESCRIPTION);
	lookup_genre = database->loadSettingBool(LOOKUP_GENRE_KEY, LOOKUP_GENRE_VALUE, LOOKUP_GENRE_DESCRIPTION);
	input_dir = database->loadSettingString(MUSIC_INPUT_KEY, MUSIC_INPUT_VALUE, MUSIC_INPUT_DESCRIPTION);
	if (input_dir.size() <= 0 || input_dir[input_dir.size() - 1] != '/')
		input_dir.push_back('/');
	output_dir = database->loadSettingString(MUSIC_OUTPUT_KEY, MUSIC_OUTPUT_VALUE, MUSIC_OUTPUT_DESCRIPTION);
	if (output_dir.size() <= 0 || output_dir[output_dir.size() - 1] != '/')
		output_dir.push_back('/');
	duplicate_dir = database->loadSettingString(MUSIC_DUPLICATE_KEY, MUSIC_DUPLICATE_VALUE, MUSIC_DUPLICATE_DESCRIPTION);
	if (duplicate_dir.size() <= 0 || duplicate_dir[duplicate_dir.size() - 1] != '/')
		duplicate_dir.push_back('/');

	total_files = 0;
}

Locutus::~Locutus() {
	delete audioscrobbler;
	delete matcher;
	delete musicbrainz;
	delete filenamer;
}

void Locutus::trim(string *text) {
	if (text == NULL)
		return;
	string::size_type pos = text->find_last_not_of(" \t\n");
	if (pos != string::npos)
		text->erase(pos + 1);
	pos = text->find_first_not_of(" \t\n");
	if (pos != string::npos)
		text->erase(0, pos);
	if (text->size() > 0 && text->at(0) == ' ')
		text->erase();
}

void Locutus::run() {
	active = true;
	/* parse output directory */
	Debug::info() << "Scanning output directory" << endl;
	scanFiles(output_dir);
	/* parse input directory */
	if (active) {
		Debug::info() << "Scanning input directory" << endl;
		scanFiles(input_dir);
	}
	/* parse duplicate directory */
	if (active) {
		Debug::info() << "Scanning duplicate directory" << endl;
		scanFiles(duplicate_dir);
	}
	/* remove files that don't exist from database */
	if (active)
		database->removeGoneFiles();
	/* set up map for combining groups that load same album */
	map<string, vector<string> > combine;
	/* match files */
	int file_counter = 0;
	for (map<string, int>::iterator g = groups.begin(); g != groups.end() && active; ++g) {
		if (g->second > max_group_size) {
			/* too many files in this group, update progress and continue */
			file_counter += g->second;
			database->updateProgress(((double)file_counter + (double)combine.size() * 21.0) / (double)total_files);
			continue;
		}
		/* match files in group */
		vector<Metafile *> files = database->loadGroup(g->first);
		matcher->match(files);
		/* save files with new metadata */
		bool do_combine_groups = true;
		for (vector<Metafile *>::iterator f = files.begin(); f != files.end() && active; ++f) {
			if (!(*f)->matched) {
				/* file is not matched, but we [may] need to unset "track_id" */
				database->saveMetafile(**f);
				continue;
			}
			if (dry_run) {
				/* dry run, don't save, only update database */
				database->saveMetafile(**f);
			} else {
				/* this file (may) be updated, save it */
				saveFile(*f);
			}
			do_combine_groups = false;
		}
		/* combine groups */
		if (do_combine_groups && combine_groups) {
			vector<string> albums = matcher->getLoadedAlbums();
			for (vector<string>::iterator a = albums.begin(); a != albums.end(); ++a)
				combine[*a].push_back(g->first);
		}
		/* update progress */
		file_counter += g->second;
		database->updateProgress(((double)file_counter + (double)combine.size() * 21.0) / (double)total_files);
	}
	/* relookup combined groups */
	for (map<string, vector<string> >::iterator c = combine.begin(); c != combine.end() && active; ++c) {
		/* update progress */
		database->updateProgress(((double)file_counter + (double)combine.size() * 21.0) / (double)total_files);
		file_counter += 21;
		if (c->second.size() <= 1)
			continue; // only one group for this album
		/* need to cheat here, copy the Metafile objects */
		string groups_joined = "";
		vector<Metafile *> files;
		for (vector<string>::iterator g = c->second.begin(); g != c->second.end(); ++g) {
			groups_joined.append(" \"").append(*g).append("\"");
			vector<Metafile *> tmpfiles = database->loadGroup(*g);
			for (vector<Metafile *>::iterator f = tmpfiles.begin(); f != tmpfiles.end(); ++f)
				files.push_back(new Metafile(**f));
		}
		Debug::info() << "Joining groups that loaded album " << c->first << ":" << groups_joined << endl;
		/* match files */
		matcher->match(files, c->first);
		/* save files with new metadata */
		for (vector<Metafile *>::iterator f = files.begin(); f != files.end() && active; ++f) {
			if ((*f)->matched) {
				if (dry_run) {
					/* dry run, don't save, only update database */
					database->saveMetafile(**f);
				} else {
					/* this file (may) be updated, save it */
					saveFile(*f);
				}
			}
			/* delete metafile */
			delete (*f);
		}
	}
	/* just in case files disappeared from the database while we were working */
	database->updateProgress(1.0);
}

string Locutus::findDuplicateFilename(Metafile *file) {
	/* find a name for a duplicate */
	string tmp_filename = duplicate_dir;
	string tmp_gen_filename = filenamer->getFilename(*file);
	string::size_type pos = tmp_gen_filename.find_last_of('.');
	string tmp_extension = (pos == string::npos) ? "" : tmp_gen_filename.substr(pos);
	tmp_filename.append(tmp_gen_filename.substr(0, pos));

	ostringstream tmp;
	tmp << tmp_filename << tmp_extension;
	if (tmp.str() == file->filename)
		return file->filename; // it's the same file!
	struct stat data;
	if (stat(tmp.str().c_str(), &data) != 0) {
		/* can seemingly move file here */
		return tmp.str();
	}
	/* file already exist, add " (<copy>)" before extension
	 * until we find an available filename or <copy> reach 100 */
	for (int copy = 1; copy < 100; ++copy) {
		tmp.str("");
		tmp << tmp_filename << " (" << copy << ")" << tmp_extension;
		if (stat(tmp.str().c_str(), &data) == 0)
			continue;
		/* found available filename */
		return tmp.str();
	}
	return file->filename;
}

bool Locutus::moveFile(Metafile *file, const string &filename) {
	string::size_type start = 0;
	string dirname;
	mode_t mode = S_IRUSR | S_IWUSR | S_IXUSR | S_IRGRP | S_IWGRP | S_IXGRP | S_IROTH | S_IXOTH;
	struct stat data;
	int result;
	while ((start = filename.find_first_of('/', start + 1)) != string::npos) {
		dirname = filename.substr(0, start);
		result = stat(dirname.c_str(), &data);
		if (result == 0 && S_ISDIR(data.st_mode))
			continue; // directory already exist
		result = mkdir(dirname.c_str(), mode);
		if (result == 0)
			continue;                                                                                                                      
		/* unable to create directory */
		Debug::warning() << "Unable to create directory: " << dirname << endl;
		return false;
	}
	if (stat(filename.c_str(), &data) != 0 && rename(file->filename.c_str(), filename.c_str()) == 0) {
		/* was able to move file, let's also try changing the permissions to 0664 */
		mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH;
		chmod(filename.c_str(), mode);
		file->filename = filename;
		return true;
	}
	/* unable to move file for some reason */
	return false;
}

bool Locutus::parseDirectory() {
	if (dir_queue.size() <= 0)
		return false;
	string directory(*dir_queue.begin());
	Debug::info() << directory << endl;
	dir_queue.pop_front();
	DIR *dir = opendir(directory.c_str());
	if (dir == NULL)
		return true;
	dirent *entity;
	char symlinkbuf[1024];
	size_t symlinkbufsize = 1024;
	while ((entity = readdir(dir)) != NULL) {
		string entityname = entity->d_name;
		if (entityname == "." || entityname == "..")
			continue; // ignore directories "." and ".."
		string ford = directory;
		if (ford[ford.size() - 1] != '/')
			ford.append("/");
		ford.append(entityname);
		/* check if ford is symlink, we skip symlinks */
		if (readlink(ford.c_str(), symlinkbuf, symlinkbufsize) != -1)
			continue; // symlink, ignore it
		/* why isn't always "entity->d_type == DT_DIR" when the entity is a directory? */
		DIR *tmpdir = opendir(ford.c_str());
		if (tmpdir != NULL)
			dir_queue.push_back(ford);
		else
			file_queue.push_back(ford);
		closedir(tmpdir);
	}
	closedir(dir);
	return true;
}

bool Locutus::parseFile() {
	if (file_queue.size() <= 0)
		return false;
	string filename(*file_queue.begin());
	Debug::info() << filename << endl;
	file_queue.pop_front();
	Metafile *mf = new Metafile(filename);
	if (!database->loadMetafile(mf)) {
		if (mf->readFromFile()) {
			/* save file to cache */
			database->saveMetafile(*mf);
		} else {
			/* unable to read this file */
			delete mf;
			return false;
		}
	}
	map<string, int>::iterator g = groups.find(mf->getGroup());
	if (g == groups.end())
		groups[mf->getGroup()] = 1;
	else
		++(g->second);
	++total_files;
	delete mf;
	return true;
}

void Locutus::saveFile(Metafile *file) {
	/* genre */
	if (lookup_genre) {
		vector<string> tags = audioscrobbler->getTags(*file);
		if (tags.size() > 0)
			file->genre = tags[0];
		else
			file->genre = ""; // clear genre if we didn't find a tag
	}
	/* create new filename */
	string filename = output_dir;
	filename.append(filenamer->getFilename(*file));
	/* check if file (possibly with different extension) already exist */
	string filename_without_extension = filename.substr(0, filename.find_last_of('.'));
	vector<Metafile *> files = database->loadMetafiles(filename_without_extension);
	unsigned long file_quality = file->bitrate * file->channels * file->samplerate;
	for (vector<Metafile *>::iterator f = files.begin(); f != files.end(); ++f) {
		/* it is possible that loadMetafiles() return other tracks which happen
		 * to match current filename (we're searching for 'blabla%' which would
		 * match 'blablabla'), so we need to check that musicbrainz_trackid match */
		if (file->filename == (*f)->filename)
			continue; // it's the exact same file
		unsigned long old_quality = (*f)->bitrate * (*f)->channels * (*f)->samplerate;
		Debug::info() << "Duplicate file for " << file->filename << " found in output directory: " << (*f)->filename << " - Quality new / old: " << file_quality << " / " << old_quality << " - Pinned new / old: " << (file->pinned ? "true" : "false") << " / " << ((*f)->pinned ? "true" : "false") << endl;
		if ((old_quality >= file_quality && !file->pinned) || (*f)->pinned) {
			/* an existing file is better and new file isn't pinned, or old file is pinned.
			 * move the new file to duplicates and update its metadata */
			filename = findDuplicateFilename(file);
			/* also mark it as a duplicate */
			file->duplicate = true;
			break;
		}
		/* new file is better */
		/* find a new name for the existing file */
		string new_filename = findDuplicateFilename(*f);
		if (new_filename == (*f)->filename) {
			/* couldn't find a new filename for the existing file.
			 * we'll set filename to file->filename so we won't move
			 * the new file, despite it begin better */
			filename = file->filename;
			Debug::notice() << "Unable to find a new filename for duplicate file " << (*f)->filename << endl;
			break;
		}
		/* move the existing file */
		string tmp_old_filename = (*f)->filename;
		Debug::info() << "Moving duplicate file " << (*f)->filename << " to " << new_filename << endl;
		if (!moveFile(*f, new_filename)) {
			/* hmm, couldn't move the existing file.
			 * then we can't move new file either */
			filename = file->filename;
			Debug::notice() << "Unable to move duplicate file " << (*f)->filename << " to " << new_filename << endl;
			break;
		}
		/* mark existing file as a duplicate */
		(*f)->duplicate = true;
		/* update database for the existing file */
		database->saveMetafile(**f, tmp_old_filename);
	}
	Debug::info() << "Moving " << file->filename << " to " << filename << endl;
	/* save metadata */
	if (!file->saveMetadata()) {
		Debug::warning() << "Unable to save metadata for file " << file->filename << endl;
		return;
	}
	/* move file */
	string old_filename = file->filename;
	if (filename != file->filename) {
		if (!moveFile(file, filename)) {
			file->filename = old_filename;
			Debug::warning() << "Unable to move file " << old_filename << " to " << filename << endl;
		}
	}
	/* update database */
	database->saveMetafile(*file, old_filename); // metadata may have changed even if path haven't
}

void Locutus::scanFiles(const string &directory) {
	dir_queue.push_back(directory);
	while (active && (dir_queue.size() > 0 || file_queue.size() > 0)) {
		/* first files */
		if (parseFile())
			continue;
		/* then directories */
		if (parseDirectory())
			continue;
	}
}

/* main stuff */
bool active = true;
Locutus *locutus = NULL;

void abort(int) {
	Debug::notice() << "SIGINT received, aborting run" << endl;
	if (locutus != NULL)
		locutus->active = false;
}

void cancel(int) {
	/* this is purely a hack for WebService.
	 * commoncpp may get stuck in a recvfrom(), which it never returns from.
	 * tend to happen if you lose packets */
	Debug::warning() << "SIGALRM received, cancelling current system call (probably stuck reading from MusicBrainz or Audioscrobbler)" << endl;
}

void quit(int) {
	Debug::notice() << "SIGTERM received, shutting down" << endl;
	if (locutus != NULL)
		locutus->active = false;
	active = false;
}

int main(int argc, const char *argv[]) {
	/* initialize static classes */
	Debug::open("locutus.log");
	Levenshtein::initialize();

	/* check startup parameters */
	bool show_usage = false;
	bool daemon = false;
	if (argc > 1) {
		for (int a = 1; a < argc; ++a) {
			if (strlen(argv[a]) < 2) {
				show_usage = true;
				continue;
			}

			if (argv[a][0] == '-') {
				switch (argv[a][1]) {
				case 'h':
					show_usage = true;
					break;

				case 'd':
					daemon = true;
					break;

				default:
					cout << "Invalid argument " << argv[a] << endl;
					show_usage = true;
					break;
				}
			} else {
				cout << "Unknown argument specified." << endl;
				show_usage = true;
			}
		}

		if (show_usage) {
			cout << "Usage: " << argv[0] << " [-d]" << endl;
			cout << endl;
			cout << "\t-d  Daemonize Locutus" << endl;
			return 1;
		}
	}

	Debug::info() << "Locutus starting" << endl;

	/* connect signals */
	signal(SIGINT, abort);
	signal(SIGTERM, quit);
	struct sigaction sigalrm;
	sigemptyset(&sigalrm.sa_mask);
	sigalrm.sa_handler = cancel;
	sigalrm.sa_flags = 0;
	sigaction(SIGALRM, &sigalrm, NULL);

	/* get configuration */
	Config config;
	string db_host = config.getSettingValue("database_host");
	string db_user = config.getSettingValue("database_user");
	string db_pass = config.getSettingValue("database_pass");
	string db_name = config.getSettingValue("database_name");

	/* connect to database */
	Database *database = new PostgreSQL(db_host, db_user, db_pass, db_name);
	database->init();

	while (active) {
		/* check whether we should run */
		int counter = DATABASE_POLL_INTERVAL / CHECK_ACTIVE_INTERVAL;
		while (active && daemon) {
			if (++counter > DATABASE_POLL_INTERVAL / CHECK_ACTIVE_INTERVAL) {
				/* query database */
				database->init();
				if (database->shouldRun())
					break;
				counter = 0;
			}
			sleep(CHECK_ACTIVE_INTERVAL);
		}

		/* need to check "active" again */
		if (!active)
			break;

		/* all set, check files */
		locutus = new Locutus(database);
		Debug::info() << "Checking files..." << endl;
		database->start();
		locutus->run();
		database->stop();
		Debug::info() << "Finished checking files" << endl;
		delete locutus;
		locutus = NULL;

		/* break unless we're running as a daemon */
		if (!daemon)
			break;
	}

	/* disconnect from database */
	delete database;

	Debug::info() << "Locutus exiting" << endl;

	/* clear static classes */
	Levenshtein::clear();
	Debug::close();

	return 0;
}
