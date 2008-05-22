#ifndef FILETRACK_H
/* defines */
#define FILETRACK_H

/* includes */

/* namespaces */
using namespace std;

/* Filetrack */
class Filetrack : Track {
	public:
		/* variables */
		int bitrate;
		int channels;
		int samplerate;
		string filename;

		/* constructors */
		Filetrack();

		/* destructors */
		~Filetrack();

		/* methods */

	private:
		/* variables */

		/* methods */
};
#endif
