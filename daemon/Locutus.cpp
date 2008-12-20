#include "Audioscrobbler.h"
#include "Config.h"
#include "Database.h"
#include "Debug.h"
#include "FileNamer.h"
#include "Levenshtein.h"
#include "Locutus.h"
#include "Matcher.h"
#include "Metafile.h"
#include "PostgreSQL.h"
//#include "PUIDGenerator.h"
#include "MusicBrainz.h"

using namespace std;

/* constructors/destructor */
Locutus::Locutus(Database *database) : database(database) {
	audioscrobbler = new Audioscrobbler(database);
	filenamer = new FileNamer(database);
	//puidgen = new PUIDGenerator();
	musicbrainz = new MusicBrainz(database);
	matcher = new Matcher(database, musicbrainz);

	dry_run = database->loadSettingBool(DRY_RUN_KEY, DRY_RUN_VALUE, DRY_RUN_DESCRIPTION);
	lookup_genre = database->loadSettingBool(LOOKUP_GENRE_KEY, LOOKUP_GENRE_VALUE, LOOKUP_GENRE_DESCRIPTION);
	input_dir = database->loadSettingString(MUSIC_INPUT_KEY, MUSIC_INPUT_VALUE, MUSIC_INPUT_DESCRIPTION);
	if (input_dir.size() <= 0 || input_dir[input_dir.size() - 1] != '/')
		input_dir.push_back('/');
	output_dir = database->loadSettingString(MUSIC_OUTPUT_KEY, MUSIC_OUTPUT_VALUE, MUSIC_OUTPUT_DESCRIPTION);
	if (output_dir.size() <= 0 || output_dir[output_dir.size() - 1] != '/')
		output_dir.push_back('/');
}

Locutus::~Locutus() {
	clearFiles();
	delete audioscrobbler;
	//delete puidgen;
	delete matcher;
	delete musicbrainz;
	delete filenamer;
}

/* static methods */
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

/* methods */
long Locutus::run() {
	/* parse sorted directory */
	Debug::info() << "Scanning output directory" << endl;
	scanFiles(output_dir);
	/* parse unsorted directory */
	Debug::info() << "Scanning input directory" << endl;
	scanFiles(input_dir);
	/* match files */
	int group_counter = 0;
	for (map<string, vector<Metafile *> >::iterator gf = grouped_files.begin(); gf != grouped_files.end(); ++gf) {
		/* update progress */
		database->updateProgress((double) group_counter++ / (double) grouped_files.size());
		/* match files in group */
		matcher->match(gf->second);
		/* save files with new metadata */
		for (vector<Metafile *>::iterator f = gf->second.begin(); f != gf->second.end(); ++f) {
			if (!(*f)->metadata_updated) {
				/* file not updated, leave it be */
				continue;
			} else if (dry_run) {
				/* dry run, don't save, only update database.
				 * however, set "matched" to true as we would've
				 * saved this file if it wasn't for dry_run */
				(*f)->matched = true;
				database->saveMetafile(**f);
			} else {
				/* this file (may) be updated, save it */
				saveFile(*f);
			}
		}
	}
	/* submit new puids? */
	// TODO?
	/* return */
	return 10000;
}

/* private methods */
void Locutus::clearFiles() {
	for (map<string, vector<Metafile *> >::iterator group = grouped_files.begin(); group != grouped_files.end(); ++group) {
		for (vector<Metafile *>::iterator file = group->second.begin(); file != group->second.end(); ++file)
			delete (*file);
	}
	grouped_files.clear();
}

string Locutus::findDuplicateFilename(Metafile *file) {
	/* find a name for a duplicate */
	string tmp_filename = input_dir;
	tmp_filename.append("duplicates/");
	string tmp_gen_filename = filenamer->getFilename(file);
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
	while ((entity = readdir(dir)) != NULL) {
		string entityname = entity->d_name;
		if (entityname == "." || entityname == "..")
			continue;
		string ford = directory;
		if (ford[ford.size() - 1] != '/')
			ford.append("/");
		ford.append(entityname);
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
	mf->meta_lookup = true;
	grouped_files[mf->getGroup()].push_back(mf);
	return true;
}

void Locutus::saveFile(Metafile *file) {
	/* genre */
	if (lookup_genre) {
		vector<string> tags = audioscrobbler->getTags(file);
		if (tags.size() > 0)
			file->genre = tags[0];
		else
			file->genre = ""; // clear genre if we didn't find a tag
	}
	/* unset force_save and set file as "matched" */
	file->force_save = false;
	file->matched = true;
	/* create new filename */
	string filename = output_dir;
	filename.append(filenamer->getFilename(file));
	/* check if file (possibly with different extension) already exist */
	string filename_without_extension = filename.substr(0, filename.find_last_of('.'));
	vector<Metafile> files = database->loadMetafiles(filename_without_extension);
	unsigned long file_quality = file->bitrate * file->channels * file->samplerate;
	for (vector<Metafile>::iterator f = files.begin(); f != files.end(); ++f) {
		/* it is possible that loadMetafiles() return other tracks which happen
		 * to match current filename (we're searching for 'blabla%' which would
		 * match 'blablabla'), so we need to check that musicbrainz_trackid match */
		if (file->filename == f->filename)
			continue; // it's the exact same file
		if (file->musicbrainz_trackid != f->musicbrainz_trackid)
			continue; // FIXME: what if we got 2 "identical" albums? different track-id, same filename
		unsigned long old_quality = f->bitrate * f->channels * f->samplerate;
		if ((old_quality >= file_quality && !file->pinned) || f->pinned) {
			/* an existing file is better and new file isn't pinned, or old file is pinned.
			 * move the new file to duplicates and update its metadata */
			filename = findDuplicateFilename(file);
			/* also mark it as a duplicate */
			file->duplicate = true;
			break;
		}
		/* new file is better */
		/* find a new name for the existing file */
		string new_filename = findDuplicateFilename(&*f);
		if (new_filename == f->filename) {
			/* couldn't find a new filename for the existing file.
			 * we'll set filename to file->filename so we won't move
			 * the new file, despite it begin better */
			filename = file->filename;
			Debug::notice() << "Unable to find a new filename for duplicate file " << f->filename << endl;
			break;
		}
		/* move the existing file */
		string tmp_old_filename = f->filename;
		if (!moveFile(&*f, new_filename)) {
			/* hmm, couldn't move the existing file.
			 * then we can't move new file either */
			filename = file->filename;
			Debug::notice() << "Unable to move duplicate file " << f->filename << " to " << new_filename << endl;
			break;
		}
		/* mark existing file as a duplicate */
		f->duplicate = true;
		/* unset force_save */
		f->force_save = false;
		/* update database for the existing file */
		database->saveMetafile(*f, tmp_old_filename);
		/* find and update the file in grouped_files */
		bool stop = false;
		for (map<string, vector<Metafile *> >::iterator gf = grouped_files.begin(); gf != grouped_files.end() && !stop; ++gf) {
			for (vector<Metafile *>::iterator f2 = gf->second.begin(); f2 != gf->second.end(); ++f2) {
				if ((*f2)->filename != f->filename)
					continue;
				(*f2)->filename = new_filename;
				stop = true;
				break;
			}
		}
	}
	cout << " Old: " << file->filename << endl;
	cout << " New: " << filename << endl;
	cout << "Meta: " << file->albumartistsort << " - " << file->album << " - " << file->tracknumber << " - " << file->artistsort << " - " << file->title << " (" << file->genre << ")" << endl;
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
	while (dir_queue.size() > 0 || file_queue.size() > 0) {
		/* first files */
		if (parseFile())
			continue;
		/* then directories */
		if (parseDirectory())
			continue;
	}
}

/* main */
int main() {
	/* initialize static classes */
	Debug::open("locutus.log");
	Levenshtein::initialize();

	/* get configuration */
	Config config;
	string db_host = config.getSettingValue("database_host");
	string db_user = config.getSettingValue("database_user");
	string db_pass = config.getSettingValue("database_pass");
	string db_name = config.getSettingValue("database_name");

	/* connect to database */
	Database *database = new PostgreSQL(db_host, db_user, db_pass, db_name);

	//while (true) {
		Locutus *locutus = new Locutus(database);
		database->start();
		database->init();
		Debug::info() << "Checking files..." << endl;
		long sleeptime = locutus->run();
		Debug::info() << "Finished checking files" << endl;
		database->clean();
		database->stop();
		delete locutus;

		usleep(sleeptime);
	//}

	/* disconnect from database */
	delete database;

	/* clear static classes */
	Levenshtein::clear();
	Debug::close();

	return 0;
}
