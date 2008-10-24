#ifndef METAFILE_H
#define METAFILE_H
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
#define MUSICIP_PUID "MUSICIP_PUID"
#define TITLE "TITLE"
#define TRACKNUMBER "TRACKNUMBER"
#define DATE "DATE"
#define GENRE "GENRE"
/* id3 crap */
#define ID3_TXXX_ALBUMARTISTSORT "ALBUMARTISTSORT"
#define ID3_TXXX_MUSICBRAINZ_ALBUMARTISTID "MusicBrainz Album Artist Id"
#define ID3_TXXX_MUSICBRAINZ_ALBUMID "MusicBrainz Album Id"
#define ID3_TXXX_MUSICBRAINZ_ARTISTID "MusicBrainz Artist Id"
#define ID3_TXXX_MUSICIP_PUID "MusicIP PUID"
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
#define APEMUSICIP_PUID "MUSICIP_PUID"
#define APETITLE "Title"
#define APETRACKNUMBER "Track"
#define APEDATE "Year"
#define APEGENRE "Genre"

#include <apetag.h>
#include <fileref.h>
#include <flacfile.h>
#include <id3v1tag.h>
#include <id3v2tag.h>
#include <list>
#include <mpcfile.h>
#include <mpegfile.h>
#include <oggflacfile.h>
#include <sstream>
#include <string>
#include <textidentificationframe.h>
#include <tfile.h>
#include <tstring.h>
#include <uniquefileidentifierframe.h>
#include <vorbisfile.h>

class Track;

class Metafile {
	public:
		bool meta_lookup;
		bool metadata_changed;
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
		std::string puid;
		std::string released;
		std::string title;
		std::string tracknumber;

		Metafile(const std::string &filename);
		~Metafile();

		void clearValues();
		std::string getBaseNameWithoutExtension() const;
		std::string getGroup() const;
		const std::list<std::string> &getValues(double combine_threshold);
		bool readFromFile();
		bool saveMetadata();
		bool setMetadata(const Track *track);

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
