#ifndef FILEMETADATACONSTANTS_H
/* defines */
#define FILEMETADATACONSTANTS_H
/* setting class */
#define FILEMETADATA_CLASS "FileMetadata"
#define FILEMETADATA_CLASS_DESCRIPTION "TODO"
/* default values */
#define ALBUM_WEIGHT_KEY "album_weight"
#define ALBUM_WEIGHT_VALUE 100.0
#define ALBUM_WEIGHT_DESCRIPTION ""
#define ARTIST_WEIGHT_KEY "artist_weight"
#define ARTIST_WEIGHT_VALUE 100.0
#define ARTIST_WEIGHT_DESCRIPTION ""
#define COMBINE_THRESHOLD_KEY "combine_threshold"
#define COMBINE_THRESHOLD_VALUE 0.80
#define COMBINE_THRESHOLD_DESCRIPTION ""
#define DURATION_LIMIT_KEY "duration_limit"
#define DURATION_LIMIT_VALUE 15.0
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

/* forward declare */
class FileMetadataConstants;

/* includes */
#include "Locutus.h"

/* namespaces */
using namespace std;

/* FileMetadataConstants */
class FileMetadataConstants {
	public:
		/* variables */
		double album_weight;
		double artist_weight;
		double combine_threshold;
		double duration_weight;
		double duration_limit;
		double title_weight;
		double tracknumber_weight;

		/* constructors */
		FileMetadataConstants(Locutus *locutus);

		/* destructors */
		~FileMetadataConstants();

		/* methods */
		void loadSettings();

	private:
		/* variables */
		Locutus *locutus;
		int setting_class_id;
};
#endif
