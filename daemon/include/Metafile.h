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

#ifndef METAFILE_H
#define METAFILE_H

#include <list>
#include <string>

/* fields */
#define ALBUM "ALBUM"
#define ALBUMARTIST "ALBUMARTIST"
#define ALBUMARTISTSORT "ALBUMARTISTSORT"
#define ARTIST "ARTIST"
#define ARTISTSORT "ARTISTSORT"
#define MUSICBRAINZ_ALBUMARTISTID "MUSICBRAINZ_ALBUMARTISTID"
#define MUSICBRAINZ_ALBUMID "MUSICBRAINZ_ALBUMID"
#define MUSICBRAINZ_ARTISTID "MUSICBRAINZ_ARTISTID"
#define MUSICBRAINZ_TRACKID "MUSICBRAINZ_TRACKID"
#define TITLE "TITLE"
#define TRACKNUMBER "TRACKNUMBER"
#define DATE "DATE"
#define GENRE "GENRE"
/* id3 crap */
#define ID3_TXXX_ALBUMARTISTSORT "ALBUMARTISTSORT"
#define ID3_TXXX_MUSICBRAINZ_ALBUMARTISTID "MusicBrainz Album Artist Id"
#define ID3_TXXX_MUSICBRAINZ_ALBUMID "MusicBrainz Album Id"
#define ID3_TXXX_MUSICBRAINZ_ARTISTID "MusicBrainz Artist Id"
#define ID3_UFID_MUSICBRAINZ_TRACKID "http://musicbrainz.org"
/* ape crap */
#define APEALBUM "Album"
#define APEALBUMARTIST "Album Artist"
#define APEALBUMARTISTSORT "ALBUMARTISTSORT"
#define APEARTIST "Artist"
#define APEARTISTSORT "ARTISTSORT"
#define APEMUSICBRAINZ_ALBUMARTISTID "MUSICBRAINZ_ALBUMARTISTID"
#define APEMUSICBRAINZ_ALBUMID "MUSICBRAINZ_ALBUMID"
#define APEMUSICBRAINZ_ARTISTID "MUSICBRAINZ_ARTISTID"
#define APEMUSICBRAINZ_TRACKID "MUSICBRAINZ_TRACKID"
#define APETITLE "Title"
#define APETRACKNUMBER "Track"
#define APEDATE "Year"
#define APEGENRE "Genre"

namespace TagLib {
	namespace APE {
		class Tag;
	}
	namespace Ogg {
		class XiphComment;
	}
	namespace ID3v1 {
		class Tag;
	}
	namespace ID3v2 {
		class Tag;
	}
	class AudioProperties;
}
class Track;

class Metafile {
public:
	bool duplicate;
	bool matched;
	bool meta_lookup;
	bool pinned;
	int bitrate;
	int channels;
	int duration;
	int samplerate;
	std::string album;
	std::string albumartist;
	std::string albumartistsort;
	std::string artist;
	std::string artistsort;
	std::string filename;
	std::string genre;
	std::string musicbrainz_albumartistid;
	std::string musicbrainz_albumid;
	std::string musicbrainz_artistid;
	std::string musicbrainz_trackid;
	std::string released;
	std::string title;
	std::string tracknumber;

	Metafile(const std::string &filename);

	void clearValues();
	std::string getBasenameWithoutExtension() const;
	std::string getGroup() const;
	const std::list<std::string> &getValues(double combine_threshold);
	bool readFromFile();
	bool saveMetadata();
	bool setMetadata(const Track &track);

private:
	std::list<std::string> values;

	void readAudioProperties(const TagLib::AudioProperties *ap);
	void readCrapTags(const TagLib::APE::Tag *ape, const TagLib::ID3v2::Tag *id3v2, const TagLib::ID3v1::Tag *id3v1);
	void readXiphComment(const TagLib::Ogg::XiphComment *tag);
	void saveAPETag(TagLib::APE::Tag *tag);
	void saveID3v2Tag(TagLib::ID3v2::Tag *tag);
	void saveXiphComment(TagLib::Ogg::XiphComment *tag);
};
#endif
