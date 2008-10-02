#ifndef METAFILE_H
#define METAFILE_H
/* settings */
#define ALBUM_WEIGHT_KEY "album_weight"
#define ALBUM_WEIGHT_VALUE 100.0
#define ALBUM_WEIGHT_DESCRIPTION ""
#define ARTIST_WEIGHT_KEY "artist_weight"
#define ARTIST_WEIGHT_VALUE 100.0
#define ARTIST_WEIGHT_DESCRIPTION ""
#define DURATION_LIMIT_KEY "duration_limit"
#define DURATION_LIMIT_VALUE 15000.0
#define DURATION_LIMIT_DESCRIPTION ""
#define DURATION_WEIGHT_KEY "duration_weight"
#define DURATION_WEIGHT_VALUE 100.0
#define DURATION_WEIGHT_DESCRIPTION ""
#define TITLE_WEIGHT_KEY "title_weight"
#define TITLE_WEIGHT_VALUE 100.0
#define TITLE_WEIGHT_DESCRIPTION ""
#define TRACKNUMBER_WEIGHT_KEY "tracknumber_weight"
#define TRACKNUMBER_WEIGHT_VALUE 100.0
#define TRACKNUMBER_WEIGHT_DESCRIPTION ""
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
/* undefined file_id */
#define UNDEFINED_FILE_ID -1

#include <apetag.h>
#include <fileref.h>
#include <flacfile.h>
#include <id3v1tag.h>
#include <id3v2tag.h>
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

class Database;
class Metatrack;
class Track;

struct Match {
	bool mbid_match;
	bool puid_match;
	double meta_score;
};

class Metafile {
	public:
		std::string filename;
		bool puid_lookup;
		bool mbid_lookup;
		bool meta_lookup;
		bool metadata_changed;
		int id;
		int bitrate;
		int channels;
		int duration;
		int samplerate;
		std::string album;
		std::string albumartist;
		std::string albumartistsort;
		std::string artist;
		std::string artistsort;
		std::string musicbrainz_albumartistid;
		std::string musicbrainz_albumid;
		std::string musicbrainz_artistid;
		std::string musicbrainz_trackid;
		std::string puid;
		std::string title;
		std::string tracknumber;
		std::string released;

		explicit Metafile(Database *database);
		~Metafile();

		Match compareWithMetatrack(const Metatrack &metatrack) const;
		std::string getBaseNameWithoutExtension() const;
		std::string getGroup() const;
		bool readFromFile(const std::string &filename);
		bool save();
		bool setMetadata(const Track *track);

	private:
		Database *database;
		double album_weight;
		double artist_weight;
		double duration_weight;
		double duration_limit;
		double title_weight;
		double tracknumber_weight;

		void readAudioProperties(const TagLib::AudioProperties *ap);
		void readCrapTags(const TagLib::APE::Tag *ape, const TagLib::ID3v2::Tag *id3v2, const TagLib::ID3v1::Tag *id3v1);
		void readXiphComment(const TagLib::Ogg::XiphComment *tag);
		void saveAPETag(TagLib::APE::Tag *tag);
		void saveID3v2Tag(TagLib::ID3v2::Tag *tag);
		void saveXiphComment(TagLib::Ogg::XiphComment *tag);
};
#endif
