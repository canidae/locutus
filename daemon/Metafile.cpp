#include "Album.h"
#include "Debug.h"
#include "Metafile.h"
#include "Track.h"

using namespace std;
using namespace TagLib;

/* constructors/destructor */
Metafile::Metafile(const string &filename) : meta_lookup(false), metadata_changed(false), bitrate(0), channels(0), duration(0), samplerate(0), album(""), albumartist(""), albumartistsort(""), artist(""), artistsort(""), filename(filename), musicbrainz_albumartistid(""), musicbrainz_albumid(""), musicbrainz_artistid(""), musicbrainz_trackid(""), puid(""), released(""), title(""), tracknumber("") {
}

Metafile::~Metafile() {
}

/* methods */
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
	/* returns either artist-album, album, last directory name or ""
	 * used for grouping tracks that possibly are from the same album */
	if (album.size() > 0) {
		if (artist.size() > 0) {
			string group = artist;
			group.push_back('-');
			group.append(album);
			return group;
		}
		return album;
	}
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

bool Metafile::readFromFile() {
	string::size_type pos = filename.find_last_of('.');
	if (pos != string::npos) {
		string ext = filename.substr(pos + 1);
		for (string::size_type a = 0; a < ext.size(); ++a) {
			if (ext[a] >= 'a' && ext[a] <= 'z')
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
			Debug::notice(msg);
			return false;
		}
	}
	/* trim strings */
	trim(&album);
	trim(&albumartist);
	trim(&albumartistsort);
	trim(&artist);
	trim(&artistsort);
	trim(&filename);
	trim(&musicbrainz_albumartistid);
	trim(&musicbrainz_albumid);
	trim(&musicbrainz_artistid);
	trim(&musicbrainz_trackid);
	trim(&puid);
	trim(&released);
	trim(&title);
	trim(&tracknumber);
	return true;
}

bool Metafile::saveMetadata() {
	string::size_type pos = filename.find_last_of('.');
	string ext = "";
	if (pos != string::npos) {
		ext = filename.substr(pos + 1);
		for (string::size_type a = 0; a < ext.size(); ++a) {
			if (ext[a] >= 'a' && ext[a] <= 'z')
				ext[a] -= 32;
		}
	}
	bool ok = false;
	if (ext == "OGG") {
		Ogg::Vorbis::File *file = new Ogg::Vorbis::File(filename.c_str(), false);
		saveXiphComment(file->tag());
		ok = file->save();
		delete file;
	} else if (ext == "MP3") {
		MPEG::File *file = new MPEG::File(filename.c_str(), false);
		saveID3v2Tag(file->ID3v2Tag());
		ok = file->save();
		delete file;
	} else if (ext == "FLAC") {
		FLAC::File *file = new FLAC::File(filename.c_str(), false);
		saveXiphComment(file->xiphComment());
		ok = file->save();
		delete file;
	} else if (ext == "MPC") {
		MPC::File *file = new MPC::File(filename.c_str(), false);
		saveAPETag(file->APETag());
		ok = file->save();
		delete file;
	} else if (ext == "OGA") {
		Ogg::FLAC::File *file = new Ogg::FLAC::File(filename.c_str(), true, AudioProperties::Accurate);
		saveXiphComment(file->tag());
		ok = file->save();
		delete file;
	/*
	} else if (ext == "WV") {
		WavPack::File *file = new WavPack::File(filename.c_str(), false);
		saveAPETag(file->APETag());
		ok = file->save();
		delete file;
	} else if (ext == "SPX") {
		Ogg::Speex::File *file = new Ogg::Speex::File(filename.c_str(), false);
		saveXiphComment(file->tag());
		ok = file->save();
		delete file;
	} else if (ext == "TTA") {
		TrueAudio::File *file = new TrueAudio::File(filename.c_str(), false);
		saveAPETag(file->APETag());
		ok = file->save();
		delete file;
	*/
	} else {
		ostringstream tmp;
		tmp << "Unable to save file '" << filename << "': Unknown filetype";
		Debug::warning(tmp.str());
	}
	if (ok)
		metadata_changed = false;
	return ok;
}

bool Metafile::setMetadata(const Track *track) {
	album = track->album->title;
	albumartist = track->album->artist->name;
	albumartistsort = track->album->artist->sortname;
	artist = track->artist->name;
	artistsort = track->artist->sortname;
	musicbrainz_albumartistid = track->album->artist->mbid;
	musicbrainz_albumid = track->album->mbid;
	musicbrainz_artistid = track->artist->mbid;
	musicbrainz_trackid = track->mbid;
	title = track->title;
	ostringstream tracknum;
	if (track->tracknumber >= 0 && track->tracknumber <= 9)
		tracknum << '0';
	tracknum << track->tracknumber;
	tracknumber = tracknum.str();
	released = track->album->released;
	//puid = track->puid;
	metadata_changed = true;
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
			cout << txxx->description().to8Bit(true) << endl;
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

void Metafile::saveAPETag(APE::Tag *tag) {
	tag->addValue(APEALBUM, album, true);
	tag->addValue(APEALBUMARTIST, albumartist, true);
	tag->addValue(APEALBUMARTISTSORT, albumartistsort, true);
	tag->addValue(APEARTIST, artist, true);
	tag->addValue(APEARTISTSORT, artistsort, true);
	tag->addValue(APEMUSICBRAINZ_ALBUMARTISTID, musicbrainz_albumartistid, true);
	tag->addValue(APEMUSICBRAINZ_ALBUMID, musicbrainz_albumid, true);
	tag->addValue(APEMUSICBRAINZ_ARTISTID, musicbrainz_artistid, true);
	tag->addValue(APEMUSICBRAINZ_TRACKID, musicbrainz_trackid, true);
	tag->addValue(APETITLE, title, true);
	tag->addValue(APETRACKNUMBER, tracknumber, true);
	tag->addValue(APEDATE, released, true);
	//tag->addValue(APEMUSICIP_PUID, puid, true);
}

void Metafile::saveID3v2Tag(ID3v2::Tag *tag) {
	/* first clear the frames we're gonna use */
	tag->removeFrames(ByteVector("TDRC"));
	tag->removeFrames(ByteVector("TPE2"));
	tag->removeFrames(ByteVector("TSOP"));
	tag->removeFrames(ByteVector("TXXX"));
	tag->removeFrames(ByteVector("UFID"));
	/* album */
	tag->setAlbum(album);
	/* albumartist */
	ID3v2::TextIdentificationFrame *tpe2 = new ID3v2::TextIdentificationFrame(ByteVector("TPE2"), TagLib::String::UTF8);
	tpe2->setText(albumartist);
	tag->addFrame(tpe2);
	/* albumartistsort */
	ID3v2::UserTextIdentificationFrame *txxxaas = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxaas->setDescription("ALBUMARTISTSORT");
	txxxaas->setText(albumartistsort);
	tag->addFrame(txxxaas);
	/* artist */
	tag->setArtist(artist);
	/* artistsort */
	ID3v2::TextIdentificationFrame *tsop = new ID3v2::TextIdentificationFrame(ByteVector("TSOP"), TagLib::String::UTF8);
	tsop->setText(artistsort);
	tag->addFrame(tsop);
	/* musicbrainz_albumartistid */
	ID3v2::UserTextIdentificationFrame *txxxaai = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxaai->setDescription("MusicBrainz Album Artist Id");
	txxxaai->setText(musicbrainz_albumartistid);
	tag->addFrame(txxxaai);
	/* musicbrainz_albumid */
	ID3v2::UserTextIdentificationFrame *txxxali = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxali->setDescription("MusicBrainz Album Id");
	txxxali->setText(musicbrainz_albumid);
	tag->addFrame(txxxali);
	/* musicbrainz_artistid */
	ID3v2::UserTextIdentificationFrame *txxxari = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxari->setDescription("MusicBrainz Artist Id");
	txxxari->setText(musicbrainz_artistid);
	tag->addFrame(txxxari);
	/* musicbrainz_trackid */
	tag->addFrame(new ID3v2::UniqueFileIdentifierFrame(ID3_UFID_MUSICBRAINZ_TRACKID, ByteVector(musicbrainz_trackid.c_str())));
	/* title */
	tag->setTitle(title);
	/* tracknumber */
	tag->setTrack(atoi(tracknumber.c_str()));
	/* date */
	ID3v2::TextIdentificationFrame *tdrc = new ID3v2::TextIdentificationFrame(ByteVector("TDRC"), TagLib::String::UTF8);
	tdrc->setText(released);
	tag->addFrame(tdrc);
	/* puid */
	/*
	ID3v2::UserTextIdentificationFrame *txxxpuid = new ID3v2::UserTextIdentificationFrame(TagLib::String::UTF8);
	txxxpuid->setText(puid);
	tag->addFrame(txxxpuid);
	*/
}

void Metafile::saveXiphComment(Ogg::XiphComment *tag) {
	tag->addField(ALBUM, album, true);
	tag->addField(ALBUMARTIST, albumartist, true);
	tag->addField(ALBUMARTISTSORT, albumartistsort, true);
	tag->addField(ARTIST, artist, true);
	tag->addField(ARTISTSORT, artistsort, true);
	tag->addField(MUSICBRAINZ_ALBUMARTISTID, musicbrainz_albumartistid, true);
	tag->addField(MUSICBRAINZ_ALBUMID, musicbrainz_albumid, true);
	tag->addField(MUSICBRAINZ_ARTISTID, musicbrainz_artistid, true);
	tag->addField(MUSICBRAINZ_TRACKID, musicbrainz_trackid, true);
	tag->addField(TITLE, title, true);
	tag->addField(TRACKNUMBER, tracknumber, true);
	tag->addField(DATE, released, true);
	//tag->addField(MUSICIP_PUID, track->puid, true);
}

void Metafile::trim(string *text) {
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
