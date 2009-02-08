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

#include "Database.h"

using namespace std;

/* constructors/destructor */
Database::Database() {
}

Database::~Database() {
}

/* methods */
bool Database::clean() {
	return false;
}

bool Database::init() {
	return false;
}

bool Database::loadAlbum(Album *album) {
	return false;
}

vector<Metafile> Database::loadGroup(const string &group) {
	vector<Metafile> files;
	files.clear();
	return files;
}

bool Database::loadMetafile(Metafile *metafile) {
	return false;
}

vector<Metafile> Database::loadMetafiles(const string &filename_pattern) {
	vector<Metafile> files;
	files.clear();
	return files;
}

bool Database::loadSettingBool(const string &key, bool default_value, const string &description) {
	return default_value;
}

double Database::loadSettingDouble(const string &key, double default_value, const string &description) {
	return default_value;
}

int Database::loadSettingInt(const string &key, int default_value, const string &description) {
	return default_value;
}

string Database::loadSettingString(const string &key, const string &default_value, const string &description) {
	return default_value;
}

bool Database::removeComparisons(const Metafile &metafile) {
	return false;
}

bool Database::saveAlbum(const Album &album) {
	return false;
}

bool Database::saveArtist(const Artist &artist) {
	return false;
}

bool Database::saveComparison(const Comparison &comparison) {
	return false;
}

bool Database::saveMetafile(const Metafile &metafile, const string &old_filename) {
	return false;
}

bool Database::saveTrack(const Track &track) {
	return false;
}

bool Database::start() {
	return false;
}

bool Database::stop() {
	return false;
}

bool Database::updateProgress(double progress) {
	return false;
}
