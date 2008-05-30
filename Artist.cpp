#include "Artist.h"

/* constructors */
Artist::Artist(Locutus *locutus) {
	this->locutus = locutus;
	mbid = "";
	name = "";
	sortname = "";
}

/* destructors */
Artist::~Artist() {
}

/* methods */
bool Artist::saveToCache() {
	/* save artist to cache */
	if (mbid.size() != 36)
		return false;
	string e_mbid = locutus->database->escapeString(mbid);
	string e_name = locutus->database->escapeString(name);
	string e_sortname = locutus->database->escapeString(sortname);
	ostringstream query;
	query << "INSERT INTO artist(mbid, name, sortname, loaded) SELECT '" << e_mbid << "', '" << e_name << "', '" << e_sortname << "', true WHERE NOT EXISTS (SELECT true FROM artist WHERE mbid = '" << e_mbid << "')";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save artist in cache, query failed. See error above");
	query.str("");
	query << "UPDATE artist SET name = '" << e_name << "', sortname = '" << e_sortname << "', loaded = true WHERE mbid = '" << e_mbid << "'";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save artist in cache, query failed. See error above");
	return true;
}
