#ifndef FILEMETADATA_H
/* defines */
#define FILEMETADATA_H
/* file types */
#define FILETYPE_OGG_VORBIS 1
#define FILETYPE_OGG_FLAC 2
#define FILETYPE_OGG_SPEEX 3
#define FILETYPE_FLAC 4
#define FILETYPE_MPEG 5
#define FILETYPE_MPC 6
#define FILETYPE_WAVPACK 7
#define FILETYPE_TRUEAUDIO 8

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
#include <tfile.h>
#include <tstring.h>
#include <vorbisfile.h>
#include "Locutus.h"
#include "Metadata.h"

/* namespaces */
using namespace std;
using namespace TagLib;

/* FileMetadata */
class FileMetadata : public Metadata {
	public:
		/* variables */
		string filename;

		/* constructors */
		FileMetadata(Locutus *locutus, string filename, int duration);

		/* destructors */
		~FileMetadata();

		/* methods */
		double compareWithMetadata(Metadata target);

	private:
		/* variables */
		Locutus *locutus;
		int type;

		/* methods */
		list<string> createMetadataList();
		void readCrapTags(APE::Tag *ape, ID3v2::Tag *id3v2, ID3v1::Tag *id3v1);
		void readXiphComment(Ogg::XiphComment *tag);
};
#endif
