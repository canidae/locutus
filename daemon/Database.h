#ifndef DATABASE_H
/* defines */
#define DATABASE_H

/* forward declare */
class Database;

/* includes */
#include <string>
#include "Album.h"
#include "Artist.h"
#include "Locutus.h"
#include "Metafile.h"
#include "Metatrack.h"
#include "Track.h"

/* namespaces */
using namespace std;

/* Database */
class Database {
	public:
		/* constructors */
		Database(Locutus *locutus);

		/* destructors */
		virtual ~Database();

		/* methods */
		virtual bool load(Album *album);
		virtual bool load(Metafile *metafile);
		virtual double loadSetting(const string &key, double default_value, const string &description);
		virtual int loadSetting(const string &key, int default_value, const string &description);
		virtual string loadSetting(const string &key, const string &default_value, const string &description);
		virtual bool save(const Album &album);
		virtual bool save(const Artist &artist);
		virtual bool save(const Metafile &metafile);
		virtual bool save(const Metatrack &metatrack);
		virtual bool save(const Track &track);

	protected:
		/* variables */
		Locutus *locutus;
};
#endif
