#ifndef FILEMETADATA_H
/* defines */
#define FILEMETADATA_H
/* stuff that should be dynamical (eg. stored in database)
 * FIXME TODO XXX */
#define LIST_SIMILARITY_THRESHOLD 0.85
#define ALBUM_WEIGHT 42
#define ARTIST_WEIGHT 42
#define TITLE_WEIGHT 42
#define TRACKNUMBER_WEIGHT 42
#define DURATION_WEIGHT 42
#define DURATION_LIMIT 10

/* includes */
#include <list>
#include <string>
#include "Levenshtein.h"
#include "Metadata.h"

/* namespaces */
using namespace std;

/* FileMetadata */
class FileMetadata : public Metadata {
	public:
		/* variables */
		string filename;

		/* constructors */
		FileMetadata(Levenshtein *levenshtein, string filename, int duration);

		/* destructors */
		~FileMetadata();

		/* methods */
		double compareWithMetadata(Metadata target);

	private:
		/* variables */
		Levenshtein *levenshtein;

		/* methods */
		list<string> createMetadataList();
};
#endif
