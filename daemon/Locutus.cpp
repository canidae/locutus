#include "Audioscrobbler.h"
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

	force_genre_lookup = database->loadSettingBool(FORCE_GENRE_LOOKUP_KEY, FORCE_GENRE_LOOKUP_VALUE, FORCE_GENRE_LOOKUP_DESCRIPTION);
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
	/* remove file entries where file doesn't exist */
	removeGoneFiles();
	/* parse sorted directory */
	Debug::info("Scanning output directory");
	scanFiles(output_dir);
	/* parse unsorted directory */
	Debug::info("Scanning input directory");
	scanFiles(input_dir);
	/* match files */
	for (map<string, vector<Metafile *> >::iterator gf = grouped_files.begin(); gf != grouped_files.end(); ++gf) {
		matcher->match(gf->first, gf->second);
		/* save files with new metadata */
		for (vector<Metafile *>::iterator f = gf->second.begin(); f != gf->second.end(); ++f) {
			if (!(*f)->metadata_changed)
				continue;
			saveFile(*f);
		}
	}
	/* submit new puids? */
	// TODO
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
		dirname.insert(0, "Unable to create directory: ");
		Debug::warning(dirname);
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
	Debug::info(directory);
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
	Debug::info(filename);
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

void Locutus::removeGoneFiles() {
	vector<Metafile> files = database->loadMetafiles("");
	struct stat file_info;
	for (vector<Metafile>::iterator f = files.begin(); f != files.end(); ) {
		if (stat(f->filename.c_str(), &file_info) == 0) {
			++f;
			continue;
		}
		// unable to get info about this file, remove it from files
		files.erase(f++);
	}
	database->removeMetafiles(files);
}

void Locutus::saveFile(Metafile *file) {
	cout << "Would save: " << file->filename << endl;
	/* genre */
	if (force_genre_lookup || file->genre == "") {
		vector<string> tags = audioscrobbler->getTags(file);
		if (tags.size() > 0)
			file->genre = tags[0];
		cout << "       Tag: " << file->genre << endl;
	}
	/* create new filename */
	string old_filename = file->filename;
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
		if (file->musicbrainz_trackid != f->musicbrainz_trackid)
			continue;
		unsigned long cur_quality = f->bitrate * f->channels * f->samplerate;
		if (f->pinned || file_quality <= cur_quality || !file->pinned) {
			/* an existing file is better.
			 * don't move the new file, but update the metadata */
			filename = old_filename;
			break;
		}
		/* new file is better */
		/* find a name for the existing file in the input directory */
		string tmp_filename = input_dir;
		tmp_filename.append("duplicates/");
		string tmp_gen_filename = filenamer->getFilename(&*f);
		string::size_type pos = tmp_gen_filename.find_last_of('.');
		string tmp_extension = (pos == string::npos) ? "" : tmp_gen_filename.substr(pos);
		tmp_filename.append(tmp_gen_filename.substr(0, pos));

		ostringstream tmp;
		tmp << tmp_filename << tmp_extension;
		bool cant_move = false;
		struct stat data;
		if (stat(tmp.str().c_str(), &data) == 0) {
			/* file already exist, add " (<copy>)" before extension
			 * until we find an available filename or <copy> reach 100 */
			cant_move = true;
			for (int copy = 1; copy < 100; ++copy) {
				tmp.str("");
				tmp << tmp_filename << " (" << copy << ")" << tmp_extension;
				if (stat(tmp.str().c_str(), &data) == 0)
					continue;
				/* found available filename */
				cant_move = false;
				break;
			}
		}
		if (cant_move) {
			/* couldn't find a new filename for the existing file.
			 * we'll set filename to old_filename so we won't move
			 * the new file, despite it begin better */
			filename = old_filename;
			ostringstream tmp2;
			tmp2 << "Unable to find a new filename for duplicate file " << f->filename;
			Debug::notice(tmp2.str());
			break;
		}
		/* move the existing file */
		if (!moveFile(&*f, tmp.str())) {
			/* hmm, couldn't move the existing file.
			 * then we can't move new file either */
			filename = old_filename;
			ostringstream tmp2;
			tmp2 << "Unable to move duplicate file " << f->filename << " to " << tmp.str();
			Debug::notice(tmp2.str());
			break;
		}
		/* find and update the file in grouped_files */
		bool stop = false;
		for (map<string, vector<Metafile *> >::iterator gf = grouped_files.begin(); gf != grouped_files.end() && !stop; ++gf) {
			for (vector<Metafile *>::iterator f2 = gf->second.begin(); f2 != gf->second.end(); ++f2) {
				if ((*f2)->filename != f->filename)
					continue;
				(*f2)->filename = tmp.str();
				stop = true;
				break;
			}
		}
		/* update database for the existing file */
		string tmp_old_filename = f->filename;
		f->filename = tmp.str();
		database->saveMetafile(*f, tmp_old_filename);
	}
	cout << "  Matching: " << file->artist << " - " << file->album << " - " << file->tracknumber << " - " << file->title << endl;
	/* save metadata */
	/*
	if (!file->saveMetadata())
		continue;
	*/
	/* move file */
	/*
	if (filename != old_filename) {
		if (!moveFile(file, filename)) {
			file->filename = old_filename;
			ostringstream tmp;
			tmp << "Unable to move file " << old_filename << " to " << filename;
			Debug::warning(tmp.str());
		}
	}
	*/
	/* update database */
	/*
	database->saveMetafile(*file, old_filename); // metadata may have changed even if path haven't
	*/
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

	/* connect to database */
	Database *database = new PostgreSQL("host=sql.samfundet.no user=locutus password=locutus dbname=locutus");

	//while (true) {
		Locutus *locutus = new Locutus(database);
		Debug::info("Checking files...");
		long sleeptime = locutus->run();
		Debug::info("Finished checking files");
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
