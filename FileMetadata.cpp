#include "FileMetadata.h"

/* constructors */
FileMetadata::FileMetadata(Levenshtein *levenshtein, string filename, int duration) : Metadata(duration) {
	this->levenshtein = levenshtein;
	this->filename = filename;
}

/* destructors */
FileMetadata::~FileMetadata() {
}

/* methods */
double FileMetadata::compareWithMetadata(Metadata target) {
	/* compare this metadata with target */
	double score = 0.0;
	list<string> source = createMetadataList();
	double match[4][source.size()];
	int pos = 0;
	for (list<string>::iterator s = source.begin(); s != source.end(); ++s) {
		match[0][pos] = levenshtein->similarity(target.getValue(ALBUM), *s);
		match[1][pos] = levenshtein->similarity(target.getValue(ARTIST), *s);
		match[2][pos] = levenshtein->similarity(target.getValue(TITLE), *s);
		match[3][pos] = (target.getValue(TRACKNUMBER) == *s) ? 1.0 : 0.0;
		++pos;
	}
	/* find the combination that gives the best score
	 * don't like this code, it's messy */
	double best = 0.0;
	int p[4];
	int c1 = 0;
	for (list<string>::iterator s1 = source.begin(); s1 != source.end(); ++s1) {
		int c2 = 0;
		for (list<string>::iterator s2 = source.begin(); s2 != source.end(); ++s2) {
			if (c1 == c2) {
				++c2;
				continue;
			}
			int c3 = 0;
			for (list<string>::iterator s3 = source.begin(); s3 != source.end(); ++s3) {
				if (c1 == c3 || c2 == c3) {
					++c3;
					continue;
				}
				int c4 = 0;
				for (list<string>::iterator s4 = source.begin(); s4 != source.end(); ++s4) {
					if (c1 == c4 || c2 == c4 || c3 == c4) {
						++c4;
						continue;
					}
					double value = match[0][c1] + match[1][c2] + match[2][c3] + match[3][c4];
					if (value > best) {
						best = value;
						p[0] = c1;
						p[1] = c2;
						p[2] = c3;
						p[3] = c4;
					}
					++c4;
				}
				++c3;
			}
			++c2;
		}
		++c1;
	}
	if (best > 0.0) {
		score += match[0][p[0]] * ALBUM_WEIGHT;
		score += match[1][p[1]] * ARTIST_WEIGHT;
		score += match[2][p[2]] * TITLE_WEIGHT;
		score += match[3][p[3]] * TRACKNUMBER_WEIGHT;
	}
	int durationdiff = abs(target.duration - duration);
	if (durationdiff < DURATION_LIMIT) {
		score += (1.0 - durationdiff / DURATION_LIMIT) * DURATION_WEIGHT;
	}
	score /= ALBUM_WEIGHT + ARTIST_WEIGHT + TITLE_WEIGHT + TRACKNUMBER_WEIGHT + DURATION_WEIGHT;
	return score;
}

/* private methods */
list<string> FileMetadata::createMetadataList() {
	/* create a list of the values we wish to compare with */
	list<string> data;
	/* filename */
	/* metadata */
	data.push_back(getValue(ALBUM));
	data.push_back(getValue(ALBUMARTIST));
	data.push_back(getValue(ARTIST));
	data.push_back(getValue(TITLE)); // might have to be tokenized (" - ", etc)
	data.push_back(getValue(TRACKNUMBER));
	return data;
}
