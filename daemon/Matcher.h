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

#ifndef MATCHER_H
#define MATCHER_H

#include <map>
#include <string>
#include <vector>

/* settings */
#define ALBUM_WEIGHT_KEY "album_weight"
#define ALBUM_WEIGHT_VALUE 100.0
#define ALBUM_WEIGHT_DESCRIPTION ""
#define ARTIST_WEIGHT_KEY "artist_weight"
#define ARTIST_WEIGHT_VALUE 100.0
#define ARTIST_WEIGHT_DESCRIPTION ""
#define COMBINE_THRESHOLD_KEY "combine_threshold"
#define COMBINE_THRESHOLD_VALUE 0.80
#define COMBINE_THRESHOLD_DESCRIPTION "Locutus fetch metadata both from tags in files and using the filename and path. Since filenames sometimes got the same information as the tags it's necessary to avoid using the same information twice as that may affect search results. Filenames may differ slightly from metadata and thus fuzzy matching is needed. This value must be between 0.0 and 1.0. At 1.0 the information in the filenames must be identical to the information found in the tags, and at 0.0 you essentially disable using information found in filenames for searching."
#define DURATION_LIMIT_KEY "duration_limit"
#define DURATION_LIMIT_VALUE 15000.0
#define DURATION_LIMIT_DESCRIPTION "If abs(file_duration - track_duration) is less than this value, higher score is achieved. Decreasing this value will decrease files matched and mismatches, increasing it will increase files matched and mismatched."
#define DURATION_MUST_MATCH_KEY "duration_must_match"
#define DURATION_MUST_MATCH_VALUE false
#define DURATION_MUST_MATCH_DESCRIPTION "When this value is set to true then track duration must be within duration_limit milliseconds or it'll be considered a different track regardless of how well metadata match. There are several tracks in MusicBrainz with either missing duration or \"wrong\" duration (sometimes artists release the same album where the tracks are lengthened/shortened). It's recommended that you leave this setting to \"false\", it increase the risk of more mismatched files, but the risk is fairly low."
#define DURATION_WEIGHT_KEY "duration_weight"
#define DURATION_WEIGHT_VALUE 100.0
#define DURATION_WEIGHT_DESCRIPTION ""
#define MAX_DIFF_BEST_SCORE_KEY "max_diff_best_score"
#define MAX_DIFF_BEST_SCORE_VALUE 0.05
#define MAX_DIFF_BEST_SCORE_DESCRIPTION "Locutus tries to group files to the same album, however that means it may match a file to a track that's not the best match. Consider this: File A compares to track 1 with score 0.99 on an album. File B compares to track 2 with score 0.80 on the same album, but it also compares to track 2 on another album with score 0.98 where file A does not compare to any tracks. In this case file B would be matched track 2 on first album if the value of this setting is greater than or equal to 0.18 (0.98 - 0.80, best score for file B minus score achieved on first album for file B), and if the value of the setting is less than 0.18 the files would be matched to the tracks on each their album. If you don't understand what this setting does, don't mess with it :)"
#define MBID_LOOKUP_KEY "mbid_lookup"
#define MBID_LOOKUP_VALUE true
#define MBID_LOOKUP_DESCRIPTION "If a file got MusicBrainz ID's then look up the track using that. This is generally a very good idea, this setting should only be turned off for testing purposes. If a MusicBrainz ID does not exist, Locutus will look up the track using metadata regardless of the value of this setting."
#define METADATA_MIN_SCORE_KEY "metadata_min_score"
#define METADATA_MIN_SCORE_VALUE 0.75
#define METADATA_MIN_SCORE_DESCRIPTION "When comparing a file with a track using metadata only, the score must exceed this value for the file to be matched. Value must be between 0.0 and 1.0. Increasing this value will decrease files matched and mismatches, decreasing it will logically do the opposite."
#define ALLOW_GROUP_DUPLICATES_KEY "allow_group_duplicates"
#define ALLOW_GROUP_DUPLICATES_VALUE false
#define ALLOW_GROUP_DUPLICATES_DESCRIPTION "If you have none or few duplicate files that will end up in the same group then this option should be disabled. With this option disabled, 'only_save_if_all_match' enabled and 'only_save_complete_albums' enabled you can significantly reduce 'metadata_min_score' without getting mismatched files and at the same time increase amount of matched files. Please see the tuning guide for more information."
#define ONLY_SAVE_COMPLETE_ALBUMS_KEY "only_save_complete_albums"
#define ONLY_SAVE_COMPLETE_ALBUMS_VALUE true
#define ONLY_SAVE_COMPLETE_ALBUMS_DESCRIPTION "When this setting is set to true, Locutus will only save albums where we got files matched to every single track on the album. If this setting is 'false' then Locutus will save matched files even if the album(s) they match isn't complete. It will also do a metadata lookup for every file which will significantly slow down the comparison. If your music archive only contains complete albums, it is a very good idea to leave this setting at true."
#define ONLY_SAVE_IF_ALL_MATCH_KEY "only_save_if_all_match"
#define ONLY_SAVE_IF_ALL_MATCH_VALUE true
#define ONLY_SAVE_IF_ALL_MATCH_DESCRIPTION "Locutus gather files in groups in this order: 'albumartist-album' if both tags are present, 'album' if tag is present or 'full_directory_path' if album tag is not present. If this setting is set to true Locutus will not save the files in such a group unless all files match something. This is generally a good idea for those who don't have a fragmented music archive."
#define PUID_LOOKUP_KEY "puid_lookup"
#define PUID_LOOKUP_VALUE true
#define PUID_LOOKUP_DESCRIPTION "If a file got a PUID then look up the track using that. This is generally a very good idea, this setting should only be turned off for testing purposes. If a PUID does not exist, Locutus will look up the track using metadata regardless of the value of this setting."
#define PUID_MIN_SCORE_KEY "puid_min_score"
#define PUID_MIN_SCORE_VALUE 0.60
#define PUID_MIN_SCORE_DESCRIPTION "When comparing a file to a track using PUID and metadata, the score must exceed this value for the file to be matched. Value must be between 0.0 and 1.0. Increasing this value will decrease files matched and mismatches, decreasing it will logically do the opposite."
#define TITLE_WEIGHT_KEY "title_weight"
#define TITLE_WEIGHT_VALUE 100.0
#define TITLE_WEIGHT_DESCRIPTION ""
#define TRACKNUMBER_WEIGHT_KEY "tracknumber_weight"
#define TRACKNUMBER_WEIGHT_VALUE 100.0
#define TRACKNUMBER_WEIGHT_DESCRIPTION ""

class Album;
class Database;
class Comparison;
class Metafile;
class Metatrack;
class MusicBrainz;
class Track;

struct AlbumComparison {
	Album *album;
	std::map<std::string, std::vector<Comparison *> > comparisons;
};

class Matcher {
public:
	Matcher(Database *database, MusicBrainz *musicbrainz);
	~Matcher();

	std::vector<std::string> getLoadedAlbums();
	void match(const std::vector<Metafile *> &files, const std::string &album = "");

private:
	Database *database;
	MusicBrainz *musicbrainz;
	bool duration_must_match;
	bool mbid_lookup;
	bool allow_group_duplicates;
	bool only_save_complete_albums;
	bool only_save_if_all_match;
	bool puid_lookup;
	double album_weight;
	double artist_weight;
	double combine_threshold;
	double duration_limit;
	double duration_weight;
	double max_diff_best_score;
	double metadata_min_score;
	double mismatch_threshold;
	double puid_min_score;
	double title_weight;
	double tracknumber_weight;
	std::map<std::string, AlbumComparison> acs;
	std::map<std::string, double> best_file_comparison;

	void clearAlbumComparison();
	void compareFilesWithAlbum(AlbumComparison *ac, const std::vector<Metafile *> &files);
	Comparison *compareMetafileWithMetatrack(Metafile *metafile, const Metatrack &metatrack, Track *track = NULL);
	bool loadAlbum(const std::string &mbid, const std::vector<Metafile *> files);
	void lookupMBIDs(const std::vector<Metafile *> &files);
	void lookupPUIDs(const std::vector<Metafile *> &files);
	void matchFilesToAlbums(const std::vector<Metafile *> &files);
	void searchMetadata(const std::vector<Metafile *> &files);
};
#endif
