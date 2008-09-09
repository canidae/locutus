#ifndef METAFILE_H
/* defines */
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

/* forward declare */
class Metafile;

/* structs */
struct Match {
	bool mbid_match;
	bool puid_match;
	double meta_score;
};

/* includes */
#include <apetag.h>
#include <fileref.h>
#include <flacfile.h>
#include <id3v1tag.h>
#include <id3v2tag.h>
#include <list>
#include <mpcfile.h>
#include <mpegfile.h>
#include <oggflacfile.h>
#include <string>
#include <textidentificationframe.h>
#include <tfile.h>
#include <tstring.h>
#include <uniquefileidentifierframe.h>
#include <vorbisfile.h>
#include "Locutus.h"
#include "Metatrack.h"
#include "Track.h"

/* namespaces */
using namespace std;
using namespace TagLib;

/* Metafile */
class Metafile {
	public:
		/* variables */
		string filename;
		bool puid_lookup;
		bool mbid_lookup;
		bool meta_lookup;
		bool save;
		int bitrate;
		int channels;
		int duration;
		int samplerate;
		string album;
		string albumartist;
		string albumartistsort;
		string artist;
		string artistsort;
		string musicbrainz_albumartistid;
		string musicbrainz_albumid;
		string musicbrainz_artistid;
		string musicbrainz_trackid;
		string puid;
		string title;
		string tracknumber;
		string released;

		/* constructors */
		Metafile(Locutus *locutus);

		/* destructors */
		~Metafile();

		/* methods */
		Match compareWithMetatrack(const Metatrack &metatrack) const;
		string getBaseNameWithoutExtension() const;
		string getGroup() const;
		bool loadFromCache(const string &filename);
		bool readFromFile(const string &filename);
		bool saveMetadata(const Track *track);
		bool saveToCache() const;

	private:
		/* variables */
		Locutus *locutus;

		/* methods */
		void readAudioProperties(const AudioProperties *ap);
		void readCrapTags(const APE::Tag *ape, const ID3v2::Tag *id3v2, const ID3v1::Tag *id3v1);
		void readXiphComment(const Ogg::XiphComment *tag);
		void saveAPETag(APE::Tag *tag, const Track *track);
		void saveID3v2Tag(ID3v2::Tag *tag, const Track *track);
		void saveXiphComment(Ogg::XiphComment *tag, const Track *track);
};
#endif
