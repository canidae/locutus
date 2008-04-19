#include "Metadata.h"

/* constructors */
Metadata::Metadata(string filename, int duration) {
	this->filename = filename;
	this->duration = duration;
	createMatrix(MATRIX_SIZE);
}

/* destructors */
Metadata::~Metadata() {
	deleteMatrix();
}

/* methods */
double Metadata::compareMetadata(Metadata target) {
	/* compare this metadata with target */
	double score = 0.0;
	list<string> source = createMetadataList();
	double match[5][source.size()];
	for (int a = 0; a < 5; ++a) {
		for (list<string>::size_type b = 0; b < source.size(); ++b)
			match[a][b] = 0.0;
	}
	int pos;
	/* album */
	pos = 0;
	for (list<string>::iterator s = source.begin(); s != source.end(); ) {
		match[0][pos] = similarity(target.getValue(ALBUM), *s);
		++pos;
		++s;
	}
	/* artist */
	pos = 0;
	for (list<string>::iterator s = source.begin(); s != source.end(); ) {
		match[1][pos] = similarity(target.getValue(ALBUM), *s);
		++pos;
		++s;
	}
	/* title */
	pos = 0;
	for (list<string>::iterator s = source.begin(); s != source.end(); ) {
		match[2][pos] = similarity(target.getValue(ALBUM), *s);
		++pos;
		++s;
	}
	/* tracknumber */
	pos = 0;
	for (list<string>::iterator s = source.begin(); s != source.end(); ) {
		//match[3][pos] = similarity(target.getValue(ALBUM), *s);
		++pos;
		++s;
	}
	/* duration */
	pos = 0;
	for (list<string>::iterator s = source.begin(); s != source.end(); ) {
		//match[4][pos] = similarity(target.getValue(ALBUM), *s);
		++pos;
		++s;
	}
	/* TODO */
	return score;
}

list<string> Metadata::createMetadataList() {
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

bool Metadata::equalMBID(Metadata target) {
	if (getValue(MUSICBRAINZ_ALBUMARTISTID) != target.getValue(MUSICBRAINZ_ALBUMARTISTID))
		return false;
	if (getValue(MUSICBRAINZ_ALBUMID) != target.getValue(MUSICBRAINZ_ALBUMID))
		return false;
	if (getValue(MUSICBRAINZ_ARTISTID) != target.getValue(MUSICBRAINZ_ARTISTID))
		return false;
	if (getValue(MUSICBRAINZ_TRACKID) != target.getValue(MUSICBRAINZ_TRACKID))
		return false;
	return true;
}

bool Metadata::equalMetadata(Metadata target) {
	if (getValue(ALBUM) != target.getValue(ALBUM))
		return false;
	if (getValue(ALBUMARTIST) != target.getValue(ALBUMARTIST))
		return false;
	if (getValue(ALBUMARTISTSORT) != target.getValue(ALBUMARTISTSORT))
		return false;
	if (getValue(ARTIST) != target.getValue(ARTIST))
		return false;
	if (getValue(ARTISTSORT) != target.getValue(ARTISTSORT))
		return false;
	if (getValue(TITLE) != target.getValue(TITLE))
		return false;
	if (getValue(TRACKNUMBER) != target.getValue(TRACKNUMBER))
		return false;
	return true;
}

string Metadata::getValue(const string key) {
	for (list<Entry>::iterator e = entries.begin(); e != entries.end(); ) {
		if (e->key == key)
			return e->value;
		++e;
	}
	return NULL;
}

void Metadata::setValue(const string key, const string value) {
	bool found = false;
	for (list<Entry>::iterator e = entries.begin(); e != entries.end(); ) {
		if (e->key != key) {
			++e;
			continue;
		}
		if (found) {
			entries.erase(e);
		} else {
			e->value = value;
			found = true;
		}
		++e;
	}
	if (!found) {
		Entry entry;
		entry.key = key;
		entry.value = value;
		entries.push_back(entry);
	}
}

/* private methods */
void Metadata::createMatrix(const int size) {
	matrix_size = size;
	matrix = new int*[matrix_size];
	for (int a = 0; a < matrix_size; ++a) {
		matrix[a] = new int[matrix_size];
		matrix[a][0] = a;
		matrix[0][a] = a;
	}
}

void Metadata::deleteMatrix() {
	for (int a = 0; a < matrix_size; ++a)
		delete [] matrix[a];
	delete [] matrix;
}

void Metadata::resizeMatrix(const int size) {
	/* resize the matrix */
	deleteMatrix();
	createMatrix(size);
}

double Metadata::similarity(const string source, const string target) {
	/* Levenshtein distance */
	const int sl = source.length();
	const int tl = target.length();
	if (sl == 0 || tl == 0)
		return 0.0;
	const int size = max(sl, tl);
	if (size + 1 > matrix_size)
		resizeMatrix(size + 1);

	for (int a = 1; a <= sl; ++a) {
		const char s = source[a - 1];
		for (int b = 1; b <= tl; ++b) {
			const char t = target[b - 1];
			int cost = (s == t ? 0 : 1);

			const int above = matrix[a - 1][b];
			const int left = matrix[a][b - 1];
			const int diag = matrix[a - 1][b - 1];
			int cell = min(above + 1, min(left + 1, diag + cost));
			if (a > 2 && b > 2) {
				int trans = matrix[a - 2][b - 2] + 1;
				if (source[a - 2] != t)
					++trans;
				if (s != target[b - 2])
					++trans;
				if (cell > trans)
					cell = trans;
			}
			matrix[a][b] = cell;
		}
	}

	return 1.0 - (double) matrix[sl][tl] / (double) size;                                                                                           
}
