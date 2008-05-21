#include "FileMetadata.h"

/* constructors */
FileMetadata::FileMetadata(Locutus *locutus, string filename) {
	this->locutus = locutus;
	this->filename = filename;
	puid_lookup = false;
	ostringstream query;
	query << "SELECT * FROM v_file_lookup WHERE filename = '" << locutus->database->escapeString(filename) << "'";
	if (locutus->database->query(query.str()) && locutus->database->getRows() > 0) {
		duration = locutus->database->getInt(0, 1);
		channels = locutus->database->getInt(0, 2);
		bitrate = locutus->database->getInt(0, 3);
		samplerate = locutus->database->getInt(0, 4);
		setValue(MUSICIP_PUID, locutus->database->getString(0, 5));
		setValue(ALBUM, locutus->database->getString(0, 6));
		setValue(ALBUMARTIST, locutus->database->getString(0, 7));
		setValue(ALBUMARTISTSORT, locutus->database->getString(0, 8));
		setValue(ARTIST, locutus->database->getString(0, 9));
		setValue(ARTISTSORT, locutus->database->getString(0, 10));
		setValue(MUSICBRAINZ_ALBUMARTISTID, locutus->database->getString(0, 11));
		setValue(MUSICBRAINZ_ALBUMID, locutus->database->getString(0, 12));
		setValue(MUSICBRAINZ_ARTISTID, locutus->database->getString(0, 13));
		setValue(MUSICBRAINZ_TRACKID, locutus->database->getString(0, 14));
		setValue(TITLE, locutus->database->getString(0, 15));
		setValue(TRACKNUMBER, locutus->database->getString(0, 16));
		setValue(YEAR, locutus->database->getString(0, 17));
		locutus->database->clear();
		return;
	}
	locutus->database->clear();
	bitrate = 0;
	channels = 0;
	samplerate = 0;
	type = 0;
	string::size_type pos = filename.find_last_of('.');
	if (pos != string::npos) {
		string ext = filename.substr(pos);
		for (string::size_type a = 0; a < ext.size(); ++a) {
			if (ext[a] >= 97 && ext[a] <= 122)
				ext[a] -= 32;
		}
		if (ext == ".OGG") {
			type = FILETYPE_OGG_VORBIS;
			Ogg::Vorbis::File *file = new Ogg::Vorbis::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".MP3") {
			type = FILETYPE_MPEG;
			MPEG::File *file = new MPEG::File(filename.c_str(), true, AudioProperties::Accurate);
			readCrapTags(file->APETag(), (ID3v2::Tag *) file->ID3v2Tag(), (ID3v1::Tag *) file->ID3v1Tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".FLAC") {
			type = FILETYPE_FLAC;
			FLAC::File *file = new FLAC::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->xiphComment());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".MPC") {
			type = FILETYPE_MPC;
			MPC::File *file = new MPC::File(filename.c_str(), true, AudioProperties::Accurate);
			readCrapTags(file->APETag(), NULL, (ID3v1::Tag *) file->ID3v1Tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".OGA") {
			type = FILETYPE_OGG_FLAC;
			Ogg::FLAC::File *file = new Ogg::FLAC::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == ".WV") {
			type = FILETYPE_WAVPACK;
			//WavPack::File *file = new WavPack::File(filename.c_str(), true, AudioProperties::Accurate);
			//readCrapTags(file->APETag(), NULL, (ID3v1::Tag *) file->ID3v1Tag());
			//readAudioProperties(file->audioProperties());
			//delete file;
		} else if (ext == ".SPX") {
			type = FILETYPE_OGG_SPEEX;
			//Ogg::Speex::File *file = new Ogg::Speex::File(filename.c_str(), true, AudioProperties::Accurate);
			//readXiphComment(file->tag());
			//readAudioProperties(file->audioProperties());
			//delete file;
		} else if (ext == ".TTA") {
			type = FILETYPE_TRUEAUDIO;
			//TrueAudio::File *file = new TrueAudio::File(filename.c_str(), true, AudioProperties::Accurate);
			//readCrapTags(file->APETag(), (ID3v2::Tag *) file->ID3v2Tag(), (ID3v1::Tag *) file->ID3v1Tag());
			//readAudioProperties(file->audioProperties());
			//delete file;
		}
	}
	/* insert in database */
	string puid = getValue(MUSICIP_PUID);
	if (puid != "") {
		query.str("");
		query << "INSERT INTO puid(puid) VALUES ('" << locutus->database->escapeString(puid) << "')";
		locutus->database->query(query.str());
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
		query << "(SELECT puid_id FROM puid WHERE puid = '" << locutus->database->escapeString(puid) << "'), '";
	else
		query << "'";
	query << locutus->database->escapeString(getValue(ALBUM)) << "', '";
	query << locutus->database->escapeString(getValue(ALBUMARTIST)) << "', '";
	query << locutus->database->escapeString(getValue(ALBUMARTISTSORT)) << "', '";
	query << locutus->database->escapeString(getValue(ARTIST)) << "', '";
	query << locutus->database->escapeString(getValue(ARTISTSORT)) << "', '";
	query << locutus->database->escapeString(getValue(MUSICBRAINZ_ALBUMARTISTID)) << "', '";
	query << locutus->database->escapeString(getValue(MUSICBRAINZ_ALBUMID)) << "', '";
	query << locutus->database->escapeString(getValue(MUSICBRAINZ_ARTISTID)) << "', '";
	query << locutus->database->escapeString(getValue(MUSICBRAINZ_TRACKID)) << "', '";
	query << locutus->database->escapeString(getValue(TITLE)) << "', '";
	query << locutus->database->escapeString(getValue(TRACKNUMBER)) << "', '";
	query << locutus->database->escapeString(getValue(YEAR)) << "')";
	locutus->database->query(query.str());
	locutus->database->clear();
}

/* destructors */
FileMetadata::~FileMetadata() {
}

/* methods */
double FileMetadata::compareWithMetadata(Metadata target) {
	/* compare this metadata with target */
	double score = 0.0;
	list<string> source = createMetadataList();
	double match[4][source.size()];
	int pos = 0;
	for (list<string>::iterator s = source.begin(); s != source.end(); ++s) {
		match[0][pos] = locutus->levenshtein->similarity(target.getValue(ALBUM), *s);
		match[1][pos] = locutus->levenshtein->similarity(target.getValue(ARTIST), *s);
		match[2][pos] = locutus->levenshtein->similarity(target.getValue(TITLE), *s);
		match[3][pos] = (target.getValue(TRACKNUMBER) == *s) ? 1.0 : 0.0;
		++pos;
	}
	/* find the combination that gives the best score
	 * don't like this code, it's messy */
	double best = 0.0;
	int p[4];
	int c1 = 0;
	for (list<string>::iterator s1 = source.begin(); s1 != source.end(); ++s1) {
		int c2 = 0;
		for (list<string>::iterator s2 = source.begin(); s2 != source.end(); ++s2) {
			if (c1 == c2) {
				++c2;
				continue;
			}
			int c3 = 0;
			for (list<string>::iterator s3 = source.begin(); s3 != source.end(); ++s3) {
				if (c1 == c3 || c2 == c3) {
					++c3;
					continue;
				}
				int c4 = 0;
				for (list<string>::iterator s4 = source.begin(); s4 != source.end(); ++s4) {
					if (c1 == c4 || c2 == c4 || c3 == c4) {
						++c4;
						continue;
					}
					double value = match[0][c1] + match[1][c2] + match[2][c3] + match[3][c4];
					if (value > best) {
						best = value;
						p[0] = c1;
						p[1] = c2;
						p[2] = c3;
						p[3] = c4;
					}
					++c4;
				}
				++c3;
			}
			++c2;
		}
		++c1;
	}
	if (best > 0.0) {
		score += match[0][p[0]] * locutus->fmconst->album_weight;
		score += match[1][p[1]] * locutus->fmconst->artist_weight;
		score += match[2][p[2]] * locutus->fmconst->title_weight;
		score += match[3][p[3]] * locutus->fmconst->tracknumber_weight;
	}
	int durationdiff = abs(target.duration - duration);
	if (durationdiff < locutus->fmconst->duration_limit) {
		score += (1.0 - durationdiff / locutus->fmconst->duration_limit) * locutus->fmconst->duration_weight;
	}
	score /= locutus->fmconst->album_weight + locutus->fmconst->artist_weight + locutus->fmconst->title_weight + locutus->fmconst->tracknumber_weight + locutus->fmconst->duration_weight;
	return score;
}

list<string> FileMetadata::createMetadataList() {
	/* create a list of the values we wish to compare with */
	list<string> data;
	/* metadata */
	data.push_back(getValue(ALBUM));
	data.push_back(getValue(ALBUMARTIST));
	data.push_back(getValue(ARTIST));
	data.push_back(getValue(TITLE)); // might have to be tokenized (" - ", etc)
	data.push_back(getValue(TRACKNUMBER));
	/* filename */
	return data;
}

string FileMetadata::getBaseNameWithoutExtension() {
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

string FileMetadata::getGroup() {
	/* returns either album, last directory name or ""
	 * used for grouping tracks that possibly are from the same album */
	string back = getValue(ALBUM);
	if (back.size() > 0)
		return back;
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

/* private methods */
void FileMetadata::readAudioProperties(AudioProperties *ap) {
	if (ap == NULL)
		return;
	bitrate = ap->bitrate();
	channels = ap->channels();
	duration = ap->length() * 1000; // returned in seconds, we want ms
	samplerate = ap->sampleRate();
}

void FileMetadata::readCrapTags(APE::Tag *ape, ID3v2::Tag *id3v2, ID3v1::Tag *id3v1) {
	/* first fetch id3v1 */
	if (id3v1 != NULL) {
		if (!id3v1->album().isEmpty())
			setValue(ALBUM, id3v1->album().to8Bit(true));
		if (!id3v1->artist().isEmpty())
			setValue(ARTIST, id3v1->artist().to8Bit(true));
		if (!id3v1->title().isEmpty())
			setValue(TITLE, id3v1->title().to8Bit(true));
		int tracknum = id3v1->track();
		if (tracknum > 0) {
			char track[32];
			sprintf(track, "%d", tracknum);
			setValue(TRACKNUMBER, string(track));
		}
	}
	/* overwrite with id3v2 */
	if (id3v2 != NULL) {
		if (!id3v2->album().isEmpty())
			setValue(ALBUM, id3v2->album().to8Bit(true));
		if (!id3v2->artist().isEmpty())
			setValue(ARTIST, id3v2->artist().to8Bit(true));
		if (!id3v2->title().isEmpty())
			setValue(TITLE, id3v2->title().to8Bit(true));
		int tracknum = id3v2->track();
		if (tracknum > 0) {
			char track[32];
			sprintf(track, "%d", tracknum);
			setValue(TRACKNUMBER, string(track));
		}
		const ID3v2::FrameListMap map = id3v2->frameListMap();
		ID3v2::FrameList frames = map["TXXX"];
		for (TagLib::uint a = 0; a < frames.size(); ++a) {
			ID3v2::UserTextIdentificationFrame *txxx = (ID3v2::UserTextIdentificationFrame *) frames[a];
			if (txxx->description().to8Bit(true) == ID3_TXXX_ALBUMARTISTSORT)
				setValue(ALBUMARTISTSORT, txxx->fieldList()[0].to8Bit(true));
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICBRAINZ_ALBUMARTISTID)
				setValue(MUSICBRAINZ_ALBUMARTISTID, txxx->fieldList()[0].to8Bit(true));
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICBRAINZ_ALBUMID)
				setValue(MUSICBRAINZ_ALBUMID, txxx->fieldList()[0].to8Bit(true));
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICBRAINZ_ARTISTID)
				setValue(MUSICBRAINZ_ARTISTID, txxx->fieldList()[0].to8Bit(true));
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICIP_PUID)
				setValue(MUSICIP_PUID, txxx->fieldList()[0].to8Bit(true));
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
				string mbti(ufid->identifier().data());
				/* FIXME
				 * resize shouldn't be necessary. need taglib 1.5(?) */
				mbti.resize(36);
				setValue(MUSICBRAINZ_TRACKID, mbti);
			}
		}
		frames = map["TSOP"];
		if (!frames.isEmpty())
			setValue(ARTISTSORT, frames.front()->toString().to8Bit(true));
	}
	/* overwrite with ape */
	if (ape != NULL) {
		const APE::ItemListMap map = ape->itemListMap();
		if (!map[ALBUM].isEmpty())
			setValue(ALBUM, map[ALBUM].toString().to8Bit(true));
		if (!map[ALBUMARTIST].isEmpty())
			setValue(ALBUMARTIST, map[ALBUMARTIST].toString().to8Bit(true));
		if (!map[ALBUMARTISTSORT].isEmpty())
			setValue(ALBUMARTISTSORT, map[ALBUMARTISTSORT].toString().to8Bit(true));
		if (!map[ARTIST].isEmpty())
			setValue(ARTIST, map[ARTIST].toString().to8Bit(true));
		if (!map[ARTISTSORT].isEmpty())
			setValue(ARTISTSORT, map[ARTISTSORT].toString().to8Bit(true));
		if (!map[MUSICBRAINZ_ALBUMARTISTID].isEmpty())
			setValue(MUSICBRAINZ_ALBUMARTISTID, map[MUSICBRAINZ_ALBUMARTISTID].toString().to8Bit(true));
		if (!map[MUSICBRAINZ_ALBUMID].isEmpty())
			setValue(MUSICBRAINZ_ALBUMID, map[MUSICBRAINZ_ALBUMID].toString().to8Bit(true));
		if (!map[MUSICBRAINZ_ARTISTID].isEmpty())
			setValue(MUSICBRAINZ_ARTISTID, map[MUSICBRAINZ_ARTISTID].toString().to8Bit(true));
		if (!map[MUSICBRAINZ_TRACKID].isEmpty())
			setValue(MUSICBRAINZ_TRACKID, map[MUSICBRAINZ_TRACKID].toString().to8Bit(true));
		if (!map[TITLE].isEmpty())
			setValue(TITLE, map[TITLE].toString().to8Bit(true));
		if (!map[TRACKNUMBER].isEmpty())
			setValue(TRACKNUMBER, map[TRACKNUMBER].toString().to8Bit(true));
	}
}

void FileMetadata::readXiphComment(Ogg::XiphComment *tag) {
	const Ogg::FieldListMap map = tag->fieldListMap();
	if (!map[ALBUM].isEmpty())
		setValue(ALBUM, map[ALBUM].front().to8Bit(true));
	if (!map[ALBUMARTIST].isEmpty())
		setValue(ALBUMARTIST, map[ALBUMARTIST].front().to8Bit(true));
	if (!map[ALBUMARTISTSORT].isEmpty())
		setValue(ALBUMARTISTSORT, map[ALBUMARTISTSORT].front().to8Bit(true));
	if (!map[ARTIST].isEmpty())
		setValue(ARTIST, map[ARTIST].front().to8Bit(true));
	if (!map[ARTISTSORT].isEmpty())
		setValue(ARTISTSORT, map[ARTISTSORT].front().to8Bit(true));
	if (!map[MUSICBRAINZ_ALBUMARTISTID].isEmpty())
		setValue(MUSICBRAINZ_ALBUMARTISTID, map[MUSICBRAINZ_ALBUMARTISTID].front().to8Bit(true));
	if (!map[MUSICBRAINZ_ALBUMID].isEmpty())
		setValue(MUSICBRAINZ_ALBUMID, map[MUSICBRAINZ_ALBUMID].front().to8Bit(true));
	if (!map[MUSICBRAINZ_ARTISTID].isEmpty())
		setValue(MUSICBRAINZ_ARTISTID, map[MUSICBRAINZ_ARTISTID].front().to8Bit(true));
	if (!map[MUSICBRAINZ_TRACKID].isEmpty())
		setValue(MUSICBRAINZ_TRACKID, map[MUSICBRAINZ_TRACKID].front().to8Bit(true));
	if (!map[TITLE].isEmpty())
		setValue(TITLE, map[TITLE].front().to8Bit(true));
	if (!map[TRACKNUMBER].isEmpty())
		setValue(TRACKNUMBER, map[TRACKNUMBER].front().to8Bit(true));
}
