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
#include "Metafile.h"

class Album;
class Artist;
class Comparison;
class Metatrack;
class Track;

class Database {
	public:
		Database();
		virtual ~Database();

		virtual bool clean();
		virtual bool init();
		virtual bool loadAlbum(Album *album);
		virtual std::vector<Metafile> loadGroup(const std::string &group);
		virtual bool loadMetafile(Metafile *metafile);
		virtual std::vector<Metafile> loadMetafiles(const std::string &filename_pattern);
		virtual bool loadSettingBool(const std::string &key, bool default_value, const std::string &description);
		virtual double loadSettingDouble(const std::string &key, double default_value, const std::string &description);
		virtual int loadSettingInt(const std::string &key, int default_value, const std::string &description);
		virtual std::string loadSettingString(const std::string &key, const std::string &default_value, const std::string &description);
		virtual bool removeComparisons(const Metafile &metafile);
		virtual bool saveAlbum(const Album &album);
		virtual bool saveArtist(const Artist &artist);
		virtual bool saveComparison(const Comparison &comparison);
		virtual bool saveMetafile(const Metafile &metafile, const std::string &old_filename = "");
		virtual bool saveTrack(const Track &track);
		virtual bool start();
		virtual bool stop();
		virtual bool updateProgress(double progress);
};
#endif
