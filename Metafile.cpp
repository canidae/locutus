#include "Metafile.h"

/* constructors */
Metafile::Metafile(Locutus *locutus) {
	this->locutus = locutus;
	bitrate = 0;
	channels = 0;
	duration = 0;
	samplerate = 0;
	album = "";
	albumartist = "";
	albumartistsort = "";
	artist = "";
	artistsort = "";
	musicbrainz_albumartistid = "";
	musicbrainz_albumid = "";
	musicbrainz_artistid = "";
	musicbrainz_trackid = "";
	puid = "";
	title = "";
	tracknumber = "";
	released = "";
}

/* destructors */
Metafile::~Metafile() {
}

/* methods */
double Metafile::compareWithMetatrack(Metatrack *metatrack) {
	/* TODO */
	return 0.0;
}

string Metafile::getBaseNameWithoutExtension() {
	/* return basename without extension, duh */
	string::size_type pos = filename.find_last_of('/');
	if (pos != string::npos && pos > 0) {
		++pos;
		string::size_type pos2 = filename.find_last_of('.');
		if (pos2 != string::npos)
			return filename.substr(pos, pos2 - pos);
		else
			return filename.substr(pos);
	}
	return "";
}

string Metafile::getGroup() {
	/* returns either album, last directory name or ""
	 * used for grouping tracks that possibly are from the same album */
	if (album.size() > 0)
		return album;
	string::size_type pos = filename.find_last_of('/');
	if (pos != string::npos && pos > 0) {
		string::size_type pos2 = filename.find_last_of('/', pos - 1);
		if (pos2 != string::npos) {
			++pos2;
			return filename.substr(pos2, pos - pos2);
		}
	}
	return "";
}

bool Metafile::loadFromCache(string filename) {
	if (filename.size() <= 0) {
		locutus->debug(DEBUG_NOTICE, "Length of filename is 0 or less? Can't load that from cache");
		return false;
	}
	string e_filename = locutus->database->escapeString(filename);
	ostringstream query;
	query << "SELECT * FROM v_file_lookup WHERE filename = '" << e_filename << "'";
	if (!locutus->database->query(query.str()) || locutus->database->getRows() <= 0) {
		string msg = "Didn't find file in database: ";
		msg.append(filename);
		locutus->debug(DEBUG_NOTICE, msg);
		return false;
	}
	duration = locutus->database->getInt(0, 1);
	channels = locutus->database->getInt(0, 2);
	bitrate = locutus->database->getInt(0, 3);
	samplerate = locutus->database->getInt(0, 4);
	puid = locutus->database->getString(0, 5);
	album = locutus->database->getString(0, 6);
	albumartist = locutus->database->getString(0, 7);
	albumartistsort = locutus->database->getString(0, 8);
	artist = locutus->database->getString(0, 9);
	artistsort = locutus->database->getString(0, 10);
	musicbrainz_albumartistid = locutus->database->getString(0, 11);
	musicbrainz_albumid = locutus->database->getString(0, 12);
	musicbrainz_artistid = locutus->database->getString(0, 13);
	musicbrainz_trackid = locutus->database->getString(0, 14);
	title = locutus->database->getString(0, 15);
	tracknumber = locutus->database->getString(0, 16);
	released = locutus->database->getString(0, 17);
	return true;
}

bool Metafile::readFromFile(string filename) {
	string::size_type pos = filename.find_last_of('.');
	if (pos != string::npos) {
		string ext = filename.substr(pos);
		for (string::size_type a = 0; a < ext.size(); ++a) {
			if (ext[a] >= 97 && ext[a] <= 122)
				ext[a] -= 32;
		}
		if (ext == ".OGG") {
			filetype = FILETYPE_OGG_VORBIS;
			Ogg::Vorbis::File *file = new Ogg::Vorbis::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".MP3") {
			filetype = FILETYPE_MPEG;
			MPEG::File *file = new MPEG::File(filename.c_str(), true, AudioProperties::Accurate);
			readCrapTags(file->APETag(), (ID3v2::Tag *) file->ID3v2Tag(), (ID3v1::Tag *) file->ID3v1Tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".FLAC") {
			filetype = FILETYPE_FLAC;
			FLAC::File *file = new FLAC::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->xiphComment());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".MPC") {
			filetype = FILETYPE_MPC;
			MPC::File *file = new MPC::File(filename.c_str(), true, AudioProperties::Accurate);
			readCrapTags(file->APETag(), NULL, (ID3v1::Tag *) file->ID3v1Tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".OGA") {
			filetype = FILETYPE_OGG_FLAC;
			Ogg::FLAC::File *file = new Ogg::FLAC::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".WV") {
			filetype = FILETYPE_WAVPACK;
			//WavPack::File *file = new WavPack::File(filename.c_str(), true, AudioProperties::Accurate);
			//readCrapTags(file->APETag(), NULL, (ID3v1::Tag *) file->ID3v1Tag());
			//readAudioProperties(file->audioProperties());
			//delete file;
		} else if (ext == ".SPX") {
			filetype = FILETYPE_OGG_SPEEX;
			//Ogg::Speex::File *file = new Ogg::Speex::File(filename.c_str(), true, AudioProperties::Accurate);
			//readXiphComment(file->tag());
			//readAudioProperties(file->audioProperties());
			//delete file;
		} else if (ext == ".TTA") {
			filetype = FILETYPE_TRUEAUDIO;
			//TrueAudio::File *file = new TrueAudio::File(filename.c_str(), true, AudioProperties::Accurate);
			//readCrapTags(file->APETag(), (ID3v2::Tag *) file->ID3v2Tag(), (ID3v1::Tag *) file->ID3v1Tag());
			//readAudioProperties(file->audioProperties());
			//delete file;
		} else {
			string msg = "Unsupported file format (well, extension): ";
			msg.append(filename);
			locutus->debug(DEBUG_NOTICE, msg);
			return false;
		}
	}
	return true;
}

bool Metafile::saveToCache() {
	ostringstream query;
	string e_puid = locutus->database->escapeString(puid);
	if (puid != "") {
		query << "INSERT INTO puid(puid) SELECT '" << e_puid << "' WHERE NOT EXISTS (SELECT true FROM puid WHERE puid = '" << e_puid << "')";
		if (!locutus->database->query(query.str()))
			locutus->debug(DEBUG_NOTICE, "Unable to store PUID in database. See error above");
	}
	query.str("");
	query << "INSERT INTO file(filename, duration, channels, bitrate, samplerate, ";
	if (puid != "")
		query << "puid_id, ";
	query << "album, albumartist, albumartistsort, artist, artistsort, musicbrainz_albumartistid, musicbrainz_albumid, musicbrainz_artistid, musicbrainz_trackid, title, tracknumber, year) VALUES ('";
	query << locutus->database->escapeString(filename) << "', ";
	query << duration << ", ";
	query << channels << ", ";
	query << bitrate << ", ";
	query << samplerate << ", ";
	if (puid != "")
		query << "(SELECT puid_id FROM puid WHERE puid = '" << e_puid << "'), '";
	else
		query << "'";
	query << locutus->database->escapeString(album) << "', '";
	query << locutus->database->escapeString(albumartist) << "', '";
	query << locutus->database->escapeString(albumartistsort) << "', '";
	query << locutus->database->escapeString(artist) << "', '";
	query << locutus->database->escapeString(artistsort) << "', '";
	query << locutus->database->escapeString(musicbrainz_albumartistid) << "', '";
	query << locutus->database->escapeString(musicbrainz_albumid) << "', '";
	query << locutus->database->escapeString(musicbrainz_artistid) << "', '";
	query << locutus->database->escapeString(musicbrainz_trackid) << "', '";
	query << locutus->database->escapeString(title) << "', '";
	query << locutus->database->escapeString(tracknumber) << "', '";
	query << locutus->database->escapeString(released) << "')";
	if (!locutus->database->query(query.str())) {
		locutus->debug(DEBUG_NOTICE, "Unable to store file in database. See error above");
		return false;
	}
	return true;
}

/* private methods */
void Metafile::readAudioProperties(AudioProperties *ap) {
	if (ap == NULL)
		return;
	bitrate = ap->bitrate();
	channels = ap->channels();
	duration = ap->length() * 1000; // sadly returned in seconds, we want ms
	samplerate = ap->sampleRate();
}

void Metafile::readCrapTags(APE::Tag *ape, ID3v2::Tag *id3v2, ID3v1::Tag *id3v1) {
	/* first fetch id3v1 */
	if (id3v1 != NULL) {
		if (!id3v1->album().isEmpty())
			album = id3v1->album().to8Bit(true);
		if (!id3v1->artist().isEmpty())
			artist = id3v1->artist().to8Bit(true);
		if (!id3v1->title().isEmpty())
			title = id3v1->title().to8Bit(true);
		int tracknum = id3v1->track();
		if (tracknum > 0) {
			ostringstream str;
			str << tracknum;
			tracknumber = str.str();
		}
	}
	/* overwrite with id3v2 */
	if (id3v2 != NULL) {
		if (!id3v2->album().isEmpty())
			album = id3v2->album().to8Bit(true);
		if (!id3v2->artist().isEmpty())
			artist = id3v2->artist().to8Bit(true);
		if (!id3v2->title().isEmpty())
			title = id3v2->title().to8Bit(true);
		int tracknum = id3v2->track();
		if (tracknum > 0) {
			ostringstream str;
			str << tracknum;
			tracknumber = str.str();
		}
		const ID3v2::FrameListMap map = id3v2->frameListMap();
		ID3v2::FrameList frames = map["TXXX"];
		for (TagLib::uint a = 0; a < frames.size(); ++a) {
			ID3v2::UserTextIdentificationFrame *txxx = (ID3v2::UserTextIdentificationFrame *) frames[a];
			if (txxx->description().to8Bit(true) == ID3_TXXX_ALBUMARTISTSORT)
				albumartistsort = txxx->fieldList()[0].to8Bit(true);
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICBRAINZ_ALBUMARTISTID)
				musicbrainz_albumartistid = txxx->fieldList()[0].to8Bit(true);
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICBRAINZ_ALBUMID)
				musicbrainz_albumid = txxx->fieldList()[0].to8Bit(true);
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICBRAINZ_ARTISTID)
				musicbrainz_artistid = txxx->fieldList()[0].to8Bit(true);
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICIP_PUID)
				puid = txxx->fieldList()[0].to8Bit(true);
		}
		frames = map["UFID"];
		for (TagLib::uint a = 0; a < frames.size(); ++a) {
			ID3v2::UniqueFileIdentifierFrame *ufid = (ID3v2::UniqueFileIdentifierFrame *) frames[a];
			if (ufid->owner() == ID3_UFID_MUSICBRAINZ_TRACKID) {
				/* there's a bug here. sometimes it returns more than 36 chars,
				 * and it doesn't help specifying a range <mid(0, 36)> either.
				 * it seems like this is fixed in taglib 1.5 */
				/*
				   char *hmm = ufid->identifier().data();
				   cout << "1: " << hmm << endl;
				   cout << "2: ";
				   for (TagLib::uint a = 0; a < ufid->identifier().size(); ++a)
				   cout << hmm[a];
				   cout << endl;
				   string hmm2(ufid->identifier().data());
				   cout << "3: " << hmm2 << endl;
				   cout << "4: " << ufid->identifier().data() << endl;
				   */
				musicbrainz_trackid = ufid->identifier().data();
				/* FIXME
				 * resize shouldn't be necessary. need taglib 1.5(?) */
				musicbrainz_trackid.resize(36);
			}
		}
		frames = map["TSOP"];
		if (!frames.isEmpty())
			artistsort = frames.front()->toString().to8Bit(true);
	}
	/* overwrite with ape */
	if (ape != NULL) {
		const APE::ItemListMap map = ape->itemListMap();
		if (!map[ALBUM].isEmpty())
			album = map[ALBUM].toString().to8Bit(true);
		if (!map[ALBUMARTIST].isEmpty())
			albumartist = map[ALBUMARTIST].toString().to8Bit(true);
		if (!map[ALBUMARTISTSORT].isEmpty())
			albumartistsort = map[ALBUMARTISTSORT].toString().to8Bit(true);
		if (!map[ARTIST].isEmpty())
			artist = map[ARTIST].toString().to8Bit(true);
		if (!map[ARTISTSORT].isEmpty())
			artistsort = map[ARTISTSORT].toString().to8Bit(true);
		if (!map[MUSICBRAINZ_ALBUMARTISTID].isEmpty())
			musicbrainz_albumartistid = map[MUSICBRAINZ_ALBUMARTISTID].toString().to8Bit(true);
		if (!map[MUSICBRAINZ_ALBUMID].isEmpty())
			musicbrainz_albumid = map[MUSICBRAINZ_ALBUMID].toString().to8Bit(true);
		if (!map[MUSICBRAINZ_ARTISTID].isEmpty())
			musicbrainz_artistid = map[MUSICBRAINZ_ARTISTID].toString().to8Bit(true);
		if (!map[MUSICBRAINZ_TRACKID].isEmpty())
			musicbrainz_trackid = map[MUSICBRAINZ_TRACKID].toString().to8Bit(true);
		if (!map[TITLE].isEmpty())
			title = map[TITLE].toString().to8Bit(true);
		if (!map[TRACKNUMBER].isEmpty())
			tracknumber = map[TRACKNUMBER].toString().to8Bit(true);
		if (!map[DATE].isEmpty())
			released = map[DATE].toString().to8Bit(true);
		if (!map[MUSICIP_PUID].isEmpty())
			puid = map[MUSICIP_PUID].toString().to8Bit(true);
	}
}

void Metafile::readXiphComment(Ogg::XiphComment *tag) {
	const Ogg::FieldListMap map = tag->fieldListMap();
	if (!map[ALBUM].isEmpty())
		album = map[ALBUM].front().to8Bit(true);
	if (!map[ALBUMARTIST].isEmpty())
		albumartist = map[ALBUMARTIST].front().to8Bit(true);
	if (!map[ALBUMARTISTSORT].isEmpty())
		albumartistsort = map[ALBUMARTISTSORT].front().to8Bit(true);
	if (!map[ARTIST].isEmpty())
		artist = map[ARTIST].front().to8Bit(true);
	if (!map[ARTISTSORT].isEmpty())
		artistsort = map[ARTISTSORT].front().to8Bit(true);
	if (!map[MUSICBRAINZ_ALBUMARTISTID].isEmpty())
		musicbrainz_albumartistid = map[MUSICBRAINZ_ALBUMARTISTID].front().to8Bit(true);
	if (!map[MUSICBRAINZ_ALBUMID].isEmpty())
		musicbrainz_albumid = map[MUSICBRAINZ_ALBUMID].front().to8Bit(true);
	if (!map[MUSICBRAINZ_ARTISTID].isEmpty())
		musicbrainz_artistid = map[MUSICBRAINZ_ARTISTID].front().to8Bit(true);
	if (!map[MUSICBRAINZ_TRACKID].isEmpty())
		musicbrainz_trackid = map[MUSICBRAINZ_TRACKID].front().to8Bit(true);
	if (!map[TITLE].isEmpty())
		title = map[TITLE].front().to8Bit(true);
	if (!map[TRACKNUMBER].isEmpty())
		tracknumber = map[TRACKNUMBER].front().to8Bit(true);
	if (!map[DATE].isEmpty())
		released = map[DATE].front().to8Bit(true);
	if (!map[MUSICIP_PUID].isEmpty())
		puid = map[MUSICIP_PUID].front().to8Bit(true);
}
