// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
// 
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
// 
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef DATABASE_H
#define DATABASE_H

#include <string>
#include <vector>

#define CACHE_LIFETIME_KEY "cache_lifetime"
#define CACHE_LIFETIME_VALUE 3
#define CACHE_LIFETIME_DESCRIPTION "When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."
#define RUN_INTERVAL_KEY "run_interval"
#define RUN_INTERVAL_VALUE 30
#define RUN_INTERVAL_DESCRIPTION "Interval between Locutus runs. The value is given in days."

class Album;
class Artist;
class Comparison;
class Metafile;
class Metatrack;
class Track;

class Database {
public:
	virtual ~Database() {}

	virtual bool init() = 0;
	virtual bool loadAlbum(Album *album) = 0;
	virtual const std::vector<Metafile *> &loadGroup(const std::string &group) = 0;
	virtual bool loadMetafile(Metafile *metafile) = 0;
	virtual const std::vector<Metafile *> &loadMetafiles(const std::string &filename_pattern) = 0;
	virtual bool loadSettingBool(const std::string &key, bool default_value, const std::string &description) = 0;
	virtual double loadSettingDouble(const std::string &key, double default_value, const std::string &description) = 0;
	virtual int loadSettingInt(const std::string &key, int default_value, const std::string &description) = 0;
	virtual const std::string &loadSettingString(const std::string &key, const std::string &default_value, const std::string &description) = 0;
	virtual bool removeComparisons(const Metafile &metafile) = 0;
	virtual bool removeGoneFiles() = 0;
	virtual bool saveAlbum(const Album &album) = 0;
	virtual bool saveArtist(const Artist &artist) = 0;
	virtual bool saveComparison(const Comparison &comparison) = 0;
	virtual bool saveMetafile(const Metafile &metafile, const std::string &old_filename = "") = 0;
	virtual bool saveTrack(const Track &track) = 0;
	virtual bool shouldRun() = 0;
	virtual bool start() = 0;
	virtual bool stop() = 0;
	virtual bool updateProgress(double progress) = 0;
};
#endif
