#ifndef METADATA_H
/* defines */
#define METADATA_H
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

		/* constructors */
		Metadata();

		/* destructors */
		~Metadata();

		/* methods */
		string getValue(string key);
		void setValue(string key, string value);

	private:
		/* variables */
		list<Entry> entries;
		int **matrix;
		int matrix_size;

		/* methods */
		void resize(int size);
		double similarity(string source, string target);
};
#endif
