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

#include <apetag.h>
#include <fileref.h>
#include <flacfile.h>
#include <id3v1tag.h>
#include <id3v2tag.h>
#include <mpcfile.h>
#include <mpegfile.h>
#include <oggflacfile.h>
#include <speexfile.h>
#include <sstream>
#include <textidentificationframe.h>
#include <tfile.h>
#include <trueaudiofile.h>
#include <tstring.h>
#include <uniquefileidentifierframe.h>
#include <vorbisfile.h>
#include <wavpackfile.h>
#include "Album.h"
#include "Debug.h"
#include "Levenshtein.h"
#include "Locutus.h"
#include "Metafile.h"
#include "Track.h"

using namespace std;
using namespace TagLib;

/* constructors/destructor */
Metafile::Metafile(const string &filename) : duplicate(false), force_save(false), matched(false), meta_lookup(true), metadata_updated(false), pinned(false), bitrate(0), channels(0), duration(0), samplerate(0), album(""), albumartist(""), albumartistsort(""), artist(""), artistsort(""), filename(filename), genre(""), musicbrainz_albumartistid(""), musicbrainz_albumid(""), musicbrainz_artistid(""), musicbrainz_trackid(""), puid(""), released(""), title(""), tracknumber(""), values() {
}

Metafile::~Metafile() {
}

/* methods */
void Metafile::clearValues() {
	values.clear();
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
	/* get the group this file belongs to. format of the group is:
	 * <extension> - <samplerate> - <channels> - [<album mbid>|<album>|<directory>] */
	ostringstream group;
	string::size_type pos = filename.find_last_of('.');
	if (pos != string::npos && pos < filename.size() - 1)
		group << filename.substr(pos + 1);
	group << " - " << samplerate << " - " << channels << " - ";
	if (musicbrainz_albumid.size() > 0) {
		group << musicbrainz_albumid;
	} else if (album.size() > 0) {
		group << album;
	} else {
		string::size_type pos = filename.find_last_of('/');
		if (pos != string::npos && pos > 0)
			group << filename.substr(0, pos);
	}
	/* lowercase groupname */
	string groupname = group.str();
	for (string::size_type a = 0; a < groupname.size(); ++a) {
		if (groupname[a] >= 'A' && groupname[a] <= 'Z')
			groupname[a] += 32;
	}
	return groupname;
}

const list<string> &Metafile::getValues(double combine_threshold) {
	/* gather all values in a list, suitable for matching with a track */
	if (values.size() > 0)
		return values;
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
	/* add last directory name (if any) */
	string token;
	string::size_type pos = filename.find_last_of('/');
	if (pos != string::npos && pos > 0) {
		string::size_type pos2 = filename.find_last_of('/', pos - 1);
		if (pos2 != string::npos) {
			++pos2;
			token = filename.substr(pos2, pos - pos2);
			Locutus::trim(&token);
			if (token.size() > 0)
				values.push_back(token);
		}
	}
	/* tokenize basename and add that too */
	string basename = getBaseNameWithoutExtension();
	/* replace "_" with " " */
	pos = 0;
	while ((pos = basename.find('_', pos)) != string::npos)
		basename.replace(pos, 1, " ");
	/* split on "-" & "." */
	pos = 0;
	while (basename.size() > 0 && (pos = basename.find_first_of("-.", 0)) != string::npos) {
		if (pos > 0) {
			token = basename.substr(0, pos);
			Locutus::trim(&token);
			if (token.size() > 0) {
				bool match = false;
				for (list<string>::iterator v = values.begin(); v != values.end(); ++v) {
					if (Levenshtein::similarity(*v, token) >= combine_threshold) {
						match = true;
						break;
					}
				}
				if (!match)
					values.push_back(token);
			}
		}
		basename.erase(0, pos + 1);
	}
	Locutus::trim(&basename);
	if (basename.size() > 0) {
		bool match = false;
		for (list<string>::iterator v = values.begin(); v != values.end(); ++v) {
			if (Levenshtein::similarity(*v, basename) >= combine_threshold) {
				match = true;
				break;
			}
		}
		if (!match)
			values.push_back(basename);
	}
	return values;
}

bool Metafile::readFromFile() {
	string::size_type pos = filename.find_last_of('.');
	string ext = "";
	if (pos != string::npos)
		ext = filename.substr(pos + 1);
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
		readCrapTags(NULL, (ID3v2::Tag *) file->ID3v2Tag(), (ID3v1::Tag *) file->ID3v1Tag());
		readAudioProperties(file->audioProperties());
		delete file;
	} else {
		Debug::notice() << "Unsupported file format (well, extension): " << filename << endl;
		return false;
	}
	/* trim strings */
	Locutus::trim(&album);
	Locutus::trim(&albumartist);
	Locutus::trim(&albumartistsort);
	Locutus::trim(&artist);
	Locutus::trim(&artistsort);
	Locutus::trim(&filename);
	Locutus::trim(&musicbrainz_albumartistid);
	Locutus::trim(&musicbrainz_albumid);
	Locutus::trim(&musicbrainz_artistid);
	Locutus::trim(&musicbrainz_trackid);
	Locutus::trim(&puid);
	Locutus::trim(&released);
	Locutus::trim(&title);
	Locutus::trim(&tracknumber);
	/* musicbrainz ids and puid should be 36 characters wide */
	if (musicbrainz_albumartistid.size() != 36)
		musicbrainz_albumartistid = "";
	if (musicbrainz_albumid.size() != 36)
		musicbrainz_albumid = "";
	if (musicbrainz_artistid.size() != 36)
		musicbrainz_artistid = "";
	if (musicbrainz_trackid.size() != 36)
		musicbrainz_trackid = "";
	if (puid.size() != 36)
		puid = "";
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
		saveID3v2Tag(file->ID3v2Tag(true));
		ok = file->save(MPEG::File::ID3v2);
		delete file;
	} else if (ext == "FLAC") {
		FLAC::File *file = new FLAC::File(filename.c_str(), false);
		saveXiphComment(file->xiphComment(true));
		ok = file->save();
		delete file;
	} else if (ext == "MPC") {
		MPC::File *file = new MPC::File(filename.c_str(), false);
		saveAPETag(file->APETag(true));
		ok = file->save();
		delete file;
	} else if (ext == "OGA") {
		Ogg::FLAC::File *file = new Ogg::FLAC::File(filename.c_str(), true, AudioProperties::Accurate);
		saveXiphComment(file->tag());
		ok = file->save();
		delete file;
	} else if (ext == "WV") {
		WavPack::File *file = new WavPack::File(filename.c_str(), false);
		saveAPETag(file->APETag(true));
		ok = file->save();
		delete file;
	} else if (ext == "SPX") {
		Ogg::Speex::File *file = new Ogg::Speex::File(filename.c_str(), false);
		saveXiphComment(file->tag());
		ok = file->save();
		delete file;
	} else if (ext == "TTA") {
		TrueAudio::File *file = new TrueAudio::File(filename.c_str(), false);
		saveID3v2Tag(file->ID3v2Tag(true));
		ok = file->save();
		delete file;
	} else {
		Debug::warning() << "Unable to save file '" << filename << "': Unknown filetype" << endl;
	}
	if (ok)
		metadata_updated = false;
	return ok;
}

bool Metafile::setMetadata(const Track &track) {
	album = track.album->title;
	albumartist = track.album->artist->name;
	albumartistsort = track.album->artist->sortname;
	artist = track.artist->name;
	artistsort = track.artist->sortname;
	musicbrainz_albumartistid = track.album->artist->mbid;
	musicbrainz_albumid = track.album->mbid;
	musicbrainz_artistid = track.artist->mbid;
	musicbrainz_trackid = track.mbid;
	title = track.title;
	ostringstream tracknum;
	tracknum << track.tracknumber;
	tracknumber = tracknum.str();
	released = track.album->released;
	//puid = track.puid;
	metadata_updated = true;
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
			if (txxx->fieldList().size() < 2)
				continue;
			if (txxx->description().to8Bit(true) == ID3_TXXX_ALBUMARTISTSORT)
				albumartistsort = txxx->fieldList()[1].to8Bit(true);
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICBRAINZ_ALBUMARTISTID)
				musicbrainz_albumartistid = txxx->fieldList()[1].to8Bit(true);
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICBRAINZ_ALBUMID)
				musicbrainz_albumid = txxx->fieldList()[1].to8Bit(true);
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICBRAINZ_ARTISTID)
				musicbrainz_artistid = txxx->fieldList()[1].to8Bit(true);
			else if (txxx->description().to8Bit(true) == ID3_TXXX_MUSICIP_PUID)
				puid = txxx->fieldList()[1].to8Bit(true);
		}
		frames = map["UFID"];
		for (TagLib::uint a = 0; a < frames.size(); ++a) {
			ID3v2::UniqueFileIdentifierFrame *ufid = (ID3v2::UniqueFileIdentifierFrame *) frames[a];
			if (ufid->owner() == ID3_UFID_MUSICBRAINZ_TRACKID)
				musicbrainz_trackid = string(ufid->identifier().data(), ufid->identifier().size());
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
		frames = map["TCON"];
		if (!frames.isEmpty())
			genre = frames.front()->toString().to8Bit(true);
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
		if (!map[APEGENRE].isEmpty())
			genre = map[APEGENRE].toString().to8Bit(true);
		if (!map[APEMUSICIP_PUID].isEmpty())
			puid = map[APEMUSICIP_PUID].toString().to8Bit(true);
	}
}

void Metafile::readXiphComment(const Ogg::XiphComment *tag) {
	if (tag == NULL)
		return;
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
	if (!map[GENRE].isEmpty())
		genre = map[GENRE].front().to8Bit(true);
	if (!map[MUSICIP_PUID].isEmpty())
		puid = map[MUSICIP_PUID].front().to8Bit(true);
}

void Metafile::saveAPETag(APE::Tag *tag) {
	if (tag == NULL)
		return;
	tag->addValue(APEALBUM, String(album, String::UTF8), true);
	tag->addValue(APEALBUMARTIST, String(albumartist, String::UTF8), true);
	tag->addValue(APEALBUMARTISTSORT, String(albumartistsort, String::UTF8), true);
	tag->addValue(APEARTIST, String(artist, String::UTF8), true);
	tag->addValue(APEARTISTSORT, String(artistsort, String::UTF8), true);
	tag->addValue(APEMUSICBRAINZ_ALBUMARTISTID, String(musicbrainz_albumartistid, String::UTF8), true);
	tag->addValue(APEMUSICBRAINZ_ALBUMID, String(musicbrainz_albumid, String::UTF8), true);
	tag->addValue(APEMUSICBRAINZ_ARTISTID, String(musicbrainz_artistid, String::UTF8), true);
	tag->addValue(APEMUSICBRAINZ_TRACKID, String(musicbrainz_trackid, String::UTF8), true);
	tag->addValue(APETITLE, String(title, String::UTF8), true);
	tag->addValue(APETRACKNUMBER, String(tracknumber, String::UTF8), true);
	tag->addValue(APEDATE, String(released, String::UTF8), true);
	tag->addValue(APEGENRE, String(genre, String::UTF8), true);
	//tag->addValue(APEMUSICIP_PUID, String(puid, String::UTF8), true);
}

void Metafile::saveID3v2Tag(ID3v2::Tag *tag) {
	if (tag == NULL)
		return;
	/* first clear the frames we're gonna use */
	tag->removeFrames(ByteVector("TCON"));
	tag->removeFrames(ByteVector("TDRC"));
	tag->removeFrames(ByteVector("TPE2"));
	tag->removeFrames(ByteVector("TSOP"));
	tag->removeFrames(ByteVector("TXXX"));
	tag->removeFrames(ByteVector("UFID"));
	/* album */
	tag->setAlbum(String(album, String::UTF8));
	/* albumartist */
	ID3v2::TextIdentificationFrame *tpe2 = new ID3v2::TextIdentificationFrame(ByteVector("TPE2"), String::UTF8);
	tpe2->setText(String(albumartist, String::UTF8));
	tag->addFrame(tpe2);
	/* albumartistsort */
	ID3v2::UserTextIdentificationFrame *txxxaas = new ID3v2::UserTextIdentificationFrame(String::UTF8);
	txxxaas->setDescription(ID3_TXXX_ALBUMARTISTSORT);
	txxxaas->setText(String(albumartistsort, String::UTF8));
	tag->addFrame(txxxaas);
	/* artist */
	tag->setArtist(String(artist, String::UTF8));
	/* artistsort */
	ID3v2::TextIdentificationFrame *tsop = new ID3v2::TextIdentificationFrame(ByteVector("TSOP"), String::UTF8);
	tsop->setText(String(artistsort, String::UTF8));
	tag->addFrame(tsop);
	/* musicbrainz_albumartistid */
	ID3v2::UserTextIdentificationFrame *txxxaai = new ID3v2::UserTextIdentificationFrame(String::UTF8);
	txxxaai->setDescription(ID3_TXXX_MUSICBRAINZ_ALBUMARTISTID);
	txxxaai->setText(String(musicbrainz_albumartistid, String::UTF8));
	tag->addFrame(txxxaai);
	/* musicbrainz_albumid */
	ID3v2::UserTextIdentificationFrame *txxxali = new ID3v2::UserTextIdentificationFrame(String::UTF8);
	txxxali->setDescription(ID3_TXXX_MUSICBRAINZ_ALBUMID);
	txxxali->setText(String(musicbrainz_albumid, String::UTF8));
	tag->addFrame(txxxali);
	/* musicbrainz_artistid */
	ID3v2::UserTextIdentificationFrame *txxxari = new ID3v2::UserTextIdentificationFrame(String::UTF8);
	txxxari->setDescription(ID3_TXXX_MUSICBRAINZ_ARTISTID);
	txxxari->setText(String(musicbrainz_artistid, String::UTF8));
	tag->addFrame(txxxari);
	/* musicbrainz_trackid */
	tag->addFrame(new ID3v2::UniqueFileIdentifierFrame(ID3_UFID_MUSICBRAINZ_TRACKID, ByteVector(musicbrainz_trackid.c_str())));
	/* title */
	tag->setTitle(String(title, String::UTF8));
	/* tracknumber */
	tag->setTrack(atoi(tracknumber.c_str()));
	/* date */
	ID3v2::TextIdentificationFrame *tdrc = new ID3v2::TextIdentificationFrame(ByteVector("TDRC"), String::UTF8);
	tdrc->setText(String(released, String::UTF8));
	tag->addFrame(tdrc);
	/* genre */
	ID3v2::TextIdentificationFrame *tcon = new ID3v2::TextIdentificationFrame(ByteVector("TCON"), String::UTF8);
	tcon->setText(String(genre, String::UTF8));
	tag->addFrame(tcon);
	/* puid */
	/*
	ID3v2::UserTextIdentificationFrame *txxxpuid = new ID3v2::UserTextIdentificationFrame(String::UTF8);
	txxxpuid->setText(String(puid, String::UTF8));
	tag->addFrame(txxxpuid);
	*/
}

void Metafile::saveXiphComment(Ogg::XiphComment *tag) {
	if (tag == NULL)
		return;
	tag->addField(ALBUM, String(album, String::UTF8), true);
	tag->addField(ALBUMARTIST, String(albumartist, String::UTF8), true);
	tag->addField(ALBUMARTISTSORT, String(albumartistsort, String::UTF8), true);
	tag->addField(ARTIST, String(artist, String::UTF8), true);
	tag->addField(ARTISTSORT, String(artistsort, String::UTF8), true);
	tag->addField(MUSICBRAINZ_ALBUMARTISTID, String(musicbrainz_albumartistid, String::UTF8), true);
	tag->addField(MUSICBRAINZ_ALBUMID, String(musicbrainz_albumid, String::UTF8), true);
	tag->addField(MUSICBRAINZ_ARTISTID, String(musicbrainz_artistid, String::UTF8), true);
	tag->addField(MUSICBRAINZ_TRACKID, String(musicbrainz_trackid, String::UTF8), true);
	tag->addField(TITLE, String(title, String::UTF8), true);
	tag->addField(TRACKNUMBER, String(tracknumber, String::UTF8), true);
	tag->addField(DATE, String(released, String::UTF8), true);
	tag->addField(GENRE, String(genre, String::UTF8), true);
	//tag->addField(MUSICIP_PUID, String(track->puid, String::UTF8), true);
}
