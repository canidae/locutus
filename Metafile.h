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
/* file types */
#define FILETYPE_OGG_VORBIS 1
#define FILETYPE_OGG_FLAC 2
#define FILETYPE_OGG_SPEEX 3
#define FILETYPE_FLAC 4
#define FILETYPE_MPEG 5
#define FILETYPE_MPC 6
#define FILETYPE_WAVPACK 7
#define FILETYPE_TRUEAUDIO 8
/* id3 crap */
#define ID3_TXXX_ALBUMARTISTSORT "ALBUMARTISTSORT"
#define ID3_TXXX_MUSICBRAINZ_ALBUMARTISTID "MusicBrainz Album Artist Id"
#define ID3_TXXX_MUSICBRAINZ_ALBUMID "MusicBrainz Album Id"
#define ID3_TXXX_MUSICBRAINZ_ARTISTID "MusicBrainz Artist Id"
#define ID3_TXXX_MUSICIP_PUID "MusicIP PUID"
#define ID3_UFID_MUSICBRAINZ_TRACKID "http://musicbrainz.org"

/* forward declare */
class Metafile;

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
		double compareWithMetatrack(Metatrack *metatrack);
		double compareWithTrack(Track *track);
		string getBaseNameWithoutExtension();
		string getGroup();
		bool loadFromCache(string filename);
		bool readFromFile(string filename);
		bool saveToCache();

	private:
		/* variables */
		Locutus *locutus;
		Metatrack *track_compare;
		int filetype;

		/* methods */
		void readAudioProperties(AudioProperties *ap);
		void readCrapTags(APE::Tag *ape, ID3v2::Tag *id3v2, ID3v1::Tag *id3v1);
		void readXiphComment(Ogg::XiphComment *tag);
};
#endif
