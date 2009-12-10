// Copyright © 2008-2009 Vidar Wahlberg <canidae@exent.net>
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

#ifndef MATCHER_H
#define MATCHER_H

#include <map>
#include <string>
#include <vector>

/* settings */
#define ALBUM_WEIGHT_KEY "album_weight"
#define ALBUM_WEIGHT_VALUE 100.0
#define ALBUM_WEIGHT_DESCRIPTION "How much weight should be given on matching album title. This is an advanced setting and you probably should not change it."
#define ARTIST_WEIGHT_KEY "artist_weight"
#define ARTIST_WEIGHT_VALUE 100.0
#define ARTIST_WEIGHT_DESCRIPTION "How much weight should be given on matching artist name. This is an advanced setting and you probably should not change it."
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
#define DURATION_WEIGHT_DESCRIPTION "How much weight should be given on matching duration. This is an advanced setting and you probably should not change it."
#define MAX_DIFF_BEST_SCORE_KEY "max_diff_best_score"
#define MAX_DIFF_BEST_SCORE_VALUE 0.05
#define MAX_DIFF_BEST_SCORE_DESCRIPTION "Locutus tries to group files to the same album, however that means it may match a file to a track that's not the best match. Consider this: File A compares to track 1 with score 0.99 on an album. File B compares to track 2 with score 0.80 on the same album, but it also compares to track 2 on another album with score 0.98 where file A does not compare to any tracks. In this case file B would be matched track 2 on first album if the value of this setting is greater than or equal to 0.18 (0.98 - 0.80, best score for file B minus score achieved on first album for file B), and if the value of the setting is less than 0.18 the files would be matched to the tracks on each their album. If you don't understand what this setting does, don't mess with it :)"
#define LOOKUP_MBID_KEY "lookup_mbid"
#define LOOKUP_MBID_VALUE true
#define LOOKUP_MBID_DESCRIPTION "If a file got MusicBrainz ID's then look up the track using that. This is generally a very good idea, this setting should only be turned off for testing purposes. If a MusicBrainz ID does not exist, Locutus will look up the track using metadata regardless of the value of this setting."
#define MATCH_MIN_SCORE_KEY "match_min_score"
#define MATCH_MIN_SCORE_VALUE 0.75
#define MATCH_MIN_SCORE_DESCRIPTION "When comparing a file with a track using metadata only, the score must exceed this value for the file to be matched. Value must be between 0.0 and 1.0. Increasing this value will decrease files matched and mismatches, decreasing it will logically do the opposite."
#define COMPARE_RELATIVE_SCORE_KEY "compare_relative_score"
#define COMPARE_RELATIVE_SCORE_VALUE 0.8
#define COMPARE_RELATIVE_SCORE_DESCRIPTION "To reduce the amount of comparisons saved, Locutus only save comparisons where the score exceed \"match_min_score * compare_relative_score\". In other words, with this value set to 1.0 and match_min_score set to 0.75 then Locutus will only save comparisons where score exceed 0.75. If this value is set to 0.5 and match_min_score is set to 0.80 then a comparison score must exceed 0.5 * 0.80 = 0.4 in order to be saved. This setting also affect amount of albums loaded in a similar way, the file we look up must get a score on an album that exceeds \"match_min_score * compare_relative_score\" in order for that album to be loaded. This value must be between 0.0 and 1.0, where a lower value will increase amount of comparisons saved and a higher value will decrease that amount."
#define ALLOW_GROUP_DUPLICATES_KEY "allow_group_duplicates"
#define ALLOW_GROUP_DUPLICATES_VALUE false
#define ALLOW_GROUP_DUPLICATES_DESCRIPTION "If you have none or few duplicate files that will end up in the same group then this option should be disabled. With this option disabled, 'only_save_if_all_match' enabled and 'only_save_complete_albums' enabled you can significantly reduce 'match_min_score' without getting mismatched files and at the same time increase amount of matched files. Please see the tuning guide for more information."
#define ONLY_SAVE_COMPLETE_ALBUMS_KEY "only_save_complete_albums"
#define ONLY_SAVE_COMPLETE_ALBUMS_VALUE true
#define ONLY_SAVE_COMPLETE_ALBUMS_DESCRIPTION "When this setting is set to true, Locutus will only save albums where we got files matched to every single track on the album. If this setting is 'false' then Locutus will save matched files even if the album(s) they match isn't complete. It will also do a metadata lookup for every file which will significantly slow down the comparison. If your music archive only contains complete albums, it is a very good idea to leave this setting at true."
#define ONLY_SAVE_IF_ALL_MATCH_KEY "only_save_if_all_match"
#define ONLY_SAVE_IF_ALL_MATCH_VALUE true
#define ONLY_SAVE_IF_ALL_MATCH_DESCRIPTION "Locutus gather files in groups in this order: 'albumartist-album' if both tags are present, 'album' if tag is present or 'full_directory_path' if album tag is not present. If this setting is set to true Locutus will not save the files in such a group unless all files match something. This is generally a good idea for those who don't have a fragmented music archive."
#define TITLE_WEIGHT_KEY "title_weight"
#define TITLE_WEIGHT_VALUE 100.0
#define TITLE_WEIGHT_DESCRIPTION "How much weight should be given on matching track title. This is an advanced setting and you probably should not change it."
#define TRACKNUMBER_WEIGHT_KEY "tracknumber_weight"
#define TRACKNUMBER_WEIGHT_VALUE 100.0
#define TRACKNUMBER_WEIGHT_DESCRIPTION "How much weight should be given on matching tracknumber. This is an advanced setting and you probably should not change it."

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
	double album_weight;
	double artist_weight;
	double combine_threshold;
	double duration_limit;
	double duration_weight;
	double max_diff_best_score;
	double match_min_score;
	double compare_relative_score;
	double mismatch_threshold;
	double title_weight;
	double tracknumber_weight;
	std::map<std::string, AlbumComparison> *acs;
	std::map<std::string, double> best_file_comparison;

	void clearAlbumComparison();
	void compareFilesWithAlbum(AlbumComparison *ac, const std::vector<Metafile *> &files);
	Comparison *compareMetafileWithMetatrack(Metafile *metafile, const Metatrack &metatrack, Track *track = NULL);
	bool loadAlbum(const std::string &mbid, const std::vector<Metafile *> files);
	void lookupMBIDs(const std::vector<Metafile *> &files);
	void matchFilesToAlbums(const std::vector<Metafile *> &files);
	void searchMetadata(const std::vector<Metafile *> &files);
};
#endif
