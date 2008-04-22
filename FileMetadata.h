#ifndef FILEMETADATA_H
/* defines */
#define FILEMETADATA_H
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

/* includes */
#include <list>
#include <string>
#include "Locutus.h"
#include "Metadata.h"

/* namespaces */
using namespace std;

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
		double album_weight;
		double artist_weight;
		double combine_threshold;
		double duration_weight;
		double duration_limit;
		double title_weight;
		double tracknumber_weight;

		/* methods */
		list<string> createMetadataList();
		void loadSettings();
		double loadSettingsHelper(int setting_class_id, string key, double default_value, string description);
};
#endif
