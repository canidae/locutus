#include "Metafile.h"

/* constructors */
Metafile::Metafile(Locutus *locutus) {
	this->locutus = locutus;
	meta_lookup = false;
	mbid_lookup = false;
	puid_lookup = false;
	save = false;
	bitrate = 0;
	channels = 0;
	duration = 0;
	samplerate = 0;
	album = "";
	albumartist = "";
	albumartistsort = "";
	artist = "";
	artistsort = "";
	filename = "";
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
Match Metafile::compareWithMetatrack(const Metatrack &metatrack) const {
	Match m;
	m.puid_match = false;
	m.mbid_match = false;
	m.meta_score = 0.0;
	list<string> values;
	if (album != "")
		values.push_back(album);
	if (albumartist != "")
		values.push_back(albumartist);
	if (artist != "")
		values.push_back(artist);
	if (title != "")
		values.push_back(title);
	if (tracknumber != "")
		values.push_back(tracknumber);
	string group = getGroup();
	if (group != "" && group != album)
		values.push_back(group);
	string basename = getBaseNameWithoutExtension();
	/* TODO: basename */
	if (values.size() <= 0)
		return m;
	/* find highest score */
	double scores[4][values.size()];
	int pos = 0;
	for (list<string>::iterator v = values.begin(); v != values.end(); ++v) {
		scores[0][pos] = locutus->levenshtein->similarity(*v, metatrack.album_title);
		scores[1][pos] = locutus->levenshtein->similarity(*v, metatrack.artist_name);
		scores[2][pos] = locutus->levenshtein->similarity(*v, metatrack.track_title);
		scores[3][pos] = (atoi(v->c_str()) == metatrack.tracknumber) ? 1.0 : 0.0;
		++pos;
	}
	bool used_row[4];
	for (int a = 0; a < 4; ++a)
		used_row[a] = false;
	bool used_col[4];
	for (list<string>::size_type a = 0; a < values.size(); ++a)
		used_col[a] = false;
	for (int a = 0; a < 4; ++a) {
		int best_row = -1;
		list<string>::size_type best_col = -1;
		double best_score = -1.0;
		for (int r = 0; r < 4; ++r) {
			if (used_row[r])
				continue;
			for (list<string>::size_type c = 0; c < values.size(); ++c) {
				if (used_col[c])
					continue;
				if (scores[r][c] > best_score) {
					best_row = r;
					best_col = c;
					best_score = scores[r][c];
				}
			}
		}
		if (best_row >= 0) {
			scores[best_row][0] = best_score;
			used_row[best_row] = true;
			used_col[best_col] = true;
		} else {
			break;
		}
	}
	m.puid_match = (puid != "" && puid == metatrack.puid);
	m.mbid_match = (musicbrainz_trackid != "" && musicbrainz_trackid == metatrack.track_mbid);
	m.meta_score = scores[0][0] * locutus->album_weight;
	m.meta_score += scores[1][0] * locutus->artist_weight;
	m.meta_score += scores[2][0] * locutus->title_weight;
	m.meta_score += scores[3][0] * locutus->tracknumber_weight;
	int durationdiff = abs(metatrack.duration - duration);
	if (durationdiff < locutus->duration_limit)
		m.meta_score += (1.0 - durationdiff / locutus->duration_limit) * locutus->duration_weight;
	m.meta_score /= locutus->album_weight + locutus->artist_weight + locutus->title_weight + locutus->tracknumber_weight + locutus->duration_weight;
	return m;
}

string Metafile::getBaseNameWithoutExtension() const {
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

string Metafile::getGroup() const {
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

bool Metafile::loadFromCache(const string &filename) {
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
	this->filename = filename;
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

bool Metafile::readFromFile(const string &filename) {
	string::size_type pos = filename.find_last_of('.');
	if (pos != string::npos) {
		string ext = filename.substr(pos + 1);
		for (string::size_type a = 0; a < ext.size(); ++a) {
			if (ext[a] >= 97 && ext[a] <= 122)
				ext[a] -= 32;
		}
		if (ext == "OGG") {
			Ogg::Vorbis::File *file = new Ogg::Vorbis::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == "MP3") {
			MPEG::File *file = new MPEG::File(filename.c_str(), true, AudioProperties::Accurate);
			readCrapTags(file->APETag(), (ID3v2::Tag *) file->ID3v2Tag(), (ID3v1::Tag *) file->ID3v1Tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == "FLAC") {
			FLAC::File *file = new FLAC::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->xiphComment());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == "MPC") {
			MPC::File *file = new MPC::File(filename.c_str(), true, AudioProperties::Accurate);
			readCrapTags(file->APETag(), NULL, (ID3v1::Tag *) file->ID3v1Tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == "OGA") {
			Ogg::FLAC::File *file = new Ogg::FLAC::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->tag());
			readAudioProperties(file->audioProperties());
			delete file;
		/*
		} else if (ext == "WV") {
			WavPack::File *file = new WavPack::File(filename.c_str(), true, AudioProperties::Accurate);
			readCrapTags(file->APETag(), NULL, (ID3v1::Tag *) file->ID3v1Tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == "SPX") {
			Ogg::Speex::File *file = new Ogg::Speex::File(filename.c_str(), true, AudioProperties::Accurate);
			readXiphComment(file->tag());
			readAudioProperties(file->audioProperties());
			delete file;
		} else if (ext == "TTA") {
			TrueAudio::File *file = new TrueAudio::File(filename.c_str(), true, AudioProperties::Accurate);
			readCrapTags(file->APETag(), (ID3v2::Tag *) file->ID3v2Tag(), (ID3v1::Tag *) file->ID3v1Tag());
			readAudioProperties(file->audioProperties());
			delete file;
		*/
		} else {
			string msg = "Unsupported file format (well, extension): ";
			msg.append(filename);
			locutus->debug(DEBUG_NOTICE, msg);
			return false;
		}
	}
	this->filename = filename;
	return true;
}

bool Metafile::saveMetadata(const Track *track) {
	string::size_type pos = filename.find_last_of('.');
	string ext = "";
	if (pos != string::npos) {
		ext = filename.substr(pos + 1);
		for (string::size_type a = 0; a < ext.size(); ++a) {
			if (ext[a] >= 97 && ext[a] <= 122)
				ext[a] -= 32;
		}
	}
	if (ext == "OGG") {
		Ogg::Vorbis::File *file = new Ogg::Vorbis::File(filename.c_str(), false);
		saveXiphComment(file->tag(), track);
		file->save();
		delete file;
		return true;
	} else if (ext == "MP3") {
		MPEG::File *file = new MPEG::File(filename.c_str(), false);
		saveID3v2Tag(file->ID3v2Tag(), track);
		file->save();
		delete file;
		return true;
	} else if (ext == "FLAC") {
		FLAC::File *file = new FLAC::File(filename.c_str(), false);
		saveXiphComment(file->xiphComment(), track);
		file->save();
		delete file;
		return true;
	} else if (ext == "MPC") {
		MPC::File *file = new MPC::File(filename.c_str(), false);
		saveAPETag(file->APETag(), track);
		file->save();
		delete file;
		return true;
	} else if (ext == "OGA") {
		Ogg::FLAC::File *file = new Ogg::FLAC::File(filename.c_str(), true, AudioProperties::Accurate);
		readXiphComment(file->tag());
		readAudioProperties(file->audioProperties());
		delete file;
	/*
	} else if (ext == "WV") {
		WavPack::File *file = new WavPack::File(filename.c_str(), false);
		saveAPETag(file->APETag(), track);
		file->save();
		delete file;
		return true;
	} else if (ext == "SPX") {
		Ogg::Speex::File *file = new Ogg::Speex::File(filename.c_str(), false);
		saveXiphComment(file->tag(), track);
		file->save();
		delete file;
		return true;
	} else if (ext == "TTA") {
		TrueAudio::File *file = new TrueAudio::File(filename.c_str(), false);
		saveAPETag(file->APETag(), track);
		file->save();
		delete file;
		return true;
	*/
	} else {
		ostringstream tmp;
		tmp << "Unable to save file '" << filename << "': Unknown filetype";
		locutus->debug(DEBUG_WARNING, tmp.str());
	}
	return false;
}

bool Metafile::saveToCache() const {
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
	query << "album, albumartist, albumartistsort, artist, artistsort, musicbrainz_albumartistid, musicbrainz_albumid, musicbrainz_artistid, musicbrainz_trackid, title, tracknumber, released) VALUES ('";
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
void Metafile::readAudioProperties(const AudioProperties *ap) {
	if (ap == NULL)
		return;
	bitrate = ap->bitrate();
	channels = ap->channels();
	duration = ap->length() * 1000; // sadly returned in seconds, we want ms
	samplerate = ap->sampleRate();
}

void Metafile::readCrapTags(const APE::Tag *ape, const ID3v2::Tag *id3v2, const ID3v1::Tag *id3v1) {
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
		frames = map["TPE2"];
		if (!frames.isEmpty())
			albumartist = frames.front()->toString().to8Bit(true);
		frames = map["TSOP"];
		if (!frames.isEmpty())
			artistsort = frames.front()->toString().to8Bit(true);
		frames = map["TDRC"];
		if (!frames.isEmpty())
			released = frames.front()->toString().to8Bit(true);
	}
	/* overwrite with ape */
	if (ape != NULL) {
		const APE::ItemListMap map = ape->itemListMap();
		if (!map[APEALBUM].isEmpty())
			album = map[APEALBUM].toString().to8Bit(true);
		if (!map[APEALBUMARTIST].isEmpty())
			albumartist = map[APEALBUMARTIST].toString().to8Bit(true);
		if (!map[APEALBUMARTISTSORT].isEmpty())
			albumartistsort = map[APEALBUMARTISTSORT].toString().to8Bit(true);
		if (!map[APEARTIST].isEmpty())
			artist = map[APEARTIST].toString().to8Bit(true);
		if (!map[APEARTISTSORT].isEmpty())
			artistsort = map[APEARTISTSORT].toString().to8Bit(true);
		if (!map[APEMUSICBRAINZ_ALBUMARTISTID].isEmpty())
			musicbrainz_albumartistid = map[APEMUSICBRAINZ_ALBUMARTISTID].toString().to8Bit(true);
		if (!map[APEMUSICBRAINZ_ALBUMID].isEmpty())
			musicbrainz_albumid = map[APEMUSICBRAINZ_ALBUMID].toString().to8Bit(true);
		if (!map[APEMUSICBRAINZ_ARTISTID].isEmpty())
			musicbrainz_artistid = map[APEMUSICBRAINZ_ARTISTID].toString().to8Bit(true);
		if (!map[APEMUSICBRAINZ_TRACKID].isEmpty())
			musicbrainz_trackid = map[APEMUSICBRAINZ_TRACKID].toString().to8Bit(true);
		if (!map[APETITLE].isEmpty())
			title = map[APETITLE].toString().to8Bit(true);
		if (!map[APETRACKNUMBER].isEmpty())
			tracknumber = map[APETRACKNUMBER].toString().to8Bit(true);
		if (!map[APEDATE].isEmpty())
			released = map[APEDATE].toString().to8Bit(true);
		if (!map[APEMUSICIP_PUID].isEmpty())
			puid = map[APEMUSICIP_PUID].toString().to8Bit(true);
	}
}

void Metafile::readXiphComment(const Ogg::XiphComment *tag) {
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

void Metafile::saveAPETag(APE::Tag *tag, const Track *track) {
	tag->addValue(APEALBUM, track->album->title, true);
	tag->addValue(APEALBUMARTIST, track->album->artist->name, true);
	tag->addValue(APEALBUMARTISTSORT, track->album->artist->sortname, true);
	tag->addValue(APEARTIST, track->artist->name, true);
	tag->addValue(APEARTISTSORT, track->artist->sortname, true);
	tag->addValue(APEMUSICBRAINZ_ALBUMARTISTID, track->album->artist->mbid, true);
	tag->addValue(APEMUSICBRAINZ_ALBUMID, track->album->mbid, true);
	tag->addValue(APEMUSICBRAINZ_ARTISTID, track->artist->mbid, true);
	tag->addValue(APEMUSICBRAINZ_TRACKID, track->mbid, true);
	tag->addValue(APETITLE, track->title, true);
	ostringstream tracknum;
	tracknum << track->tracknumber;
	tag->addValue(APETRACKNUMBER, tracknum.str(), true);
	tag->addValue(APEDATE, track->album->released, true);
	//tag->addValue(APEMUSICIP_PUID, track->puid, true);
}

void Metafile::saveID3v2Tag(ID3v2::Tag *tag, const Track *track) {
	/* first clear the frames we're gonna use */
	tag->removeFrames(ByteVector("TDRC"));
	tag->removeFrames(ByteVector("TPE2"));
	tag->removeFrames(ByteVector("TSOP"));
	tag->removeFrames(ByteVector("TXXX"));
	tag->removeFrames(ByteVector("UFID"));
	/* album */
	tag->setAlbum(track->album->title);
	/* albumartist */
	ID3v2::TextIdentificationFrame *tpe2 = new ID3v2::TextIdentificationFrame(ByteVector("TPE2"), TagLib::String::UTF8);
	tpe2->setText(track->album->artist->name);
	tag->addFrame(tpe2);
	/* albumartistsort */
	ID3v2::UserTextIdentificationFrame *txxxaas = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxaas->setDescription("ALBUMARTISTSORT");
	txxxaas->setText(track->album->artist->sortname);
	tag->addFrame(txxxaas);
	/* artist */
	tag->setArtist(track->artist->name);
	/* artistsort */
	ID3v2::TextIdentificationFrame *tsop = new ID3v2::TextIdentificationFrame(ByteVector("TSOP"), TagLib::String::UTF8);
	tsop->setText(track->artist->sortname);
	tag->addFrame(tsop);
	/* musicbrainz_albumartistid */
	ID3v2::UserTextIdentificationFrame *txxxaai = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxaai->setDescription("MusicBrainz Album Artist Id");
	txxxaai->setText(track->album->artist->mbid);
	tag->addFrame(txxxaai);
	/* musicbrainz_albumid */
	ID3v2::UserTextIdentificationFrame *txxxali = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxali->setDescription("MusicBrainz Album Id");
	txxxali->setText(track->album->mbid);
	tag->addFrame(txxxali);
	/* musicbrainz_artistid */
	ID3v2::UserTextIdentificationFrame *txxxari = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxari->setDescription("MusicBrainz Artist Id");
	txxxari->setText(track->artist->mbid);
	tag->addFrame(txxxari);
	/* musicbrainz_trackid */
	tag->addFrame(new ID3v2::UniqueFileIdentifierFrame(ID3_UFID_MUSICBRAINZ_TRACKID, ByteVector(track->mbid.c_str())));
	/* title */
	tag->setTitle(track->title);
	/* tracknumber */
	tag->setTrack(track->tracknumber);
	/* date */
	ID3v2::TextIdentificationFrame *tdrc = new ID3v2::TextIdentificationFrame(ByteVector("TDRC"), TagLib::String::UTF8);
	tdrc->setText(track->album->released);
	tag->addFrame(tdrc);
	/* puid */
	/*
	ID3v2::UserTextIdentificationFrame *txxxpuid = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxpuid->setText(track->puid);
	tag->addFrame(txxxpuid);
	*/
}

void Metafile::saveXiphComment(Ogg::XiphComment *tag, const Track *track) {
	tag->addField(ALBUM, track->album->title, true);
	tag->addField(ALBUMARTIST, track->album->artist->name, true);
	tag->addField(ALBUMARTISTSORT, track->album->artist->sortname, true);
	tag->addField(ARTIST, track->artist->name, true);
	tag->addField(ARTISTSORT, track->artist->sortname, true);
	tag->addField(MUSICBRAINZ_ALBUMARTISTID, track->album->artist->mbid, true);
	tag->addField(MUSICBRAINZ_ALBUMID, track->album->mbid, true);
	tag->addField(MUSICBRAINZ_ARTISTID, track->artist->mbid, true);
	tag->addField(MUSICBRAINZ_TRACKID, track->mbid, true);
	tag->addField(TITLE, track->title, true);
	ostringstream tracknum;
	tracknum << track->tracknumber;
	tag->addField(TRACKNUMBER, tracknum.str(), true);
	tag->addField(DATE, track->album->released, true);
	//tag->addField(MUSICIP_PUID, track->puid, true);
}
