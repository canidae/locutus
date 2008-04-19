#ifndef METADATA_H
/* defines */
#define METADATA_H
/* stuff that should be dynamical (eg. stored in database)
 * FIXME TODO XXX */
#define LIST_SIMILARITY_THRESHOLD 0.85
#define ALBUM_WEIGHT 42
#define ARTIST_WEIGHT 42
#define TITLE_WEIGHT 42
#define TRACKNUMBER_WEIGHT 42
#define DURATION_WEIGHT 42
#define DURATION_LIMIT 10
/* start size matrix */
#define MATRIX_SIZE 64
/* keys */
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

/* includes */
#include <list>
#include <string>

/* namespaces */
using namespace std;

/* key/value for metadata */
struct Entry {
	string key;
	string value;
};

/* Metadata */
class Metadata {
	public:
		/* variables */
		string filename;
		int duration;

		/* constructors */
		Metadata(string filename, int duration);

		/* destructors */
		~Metadata();

		/* methods */
		double compareMetadata(Metadata target);
		list<string> createMetadataList();
		bool equalMBID(Metadata target);
		bool equalMetadata(Metadata target);
		string getValue(const string key);
		void setValue(const string key, const string value);

	private:
		/* variables */
		list<Entry> entries;
		int **matrix;
		int matrix_size;

		/* methods */
		void createMatrix(const int size);
		void deleteMatrix();
		void resizeMatrix(const int size);
		double similarity(const string source, const string target);
};
#endif
