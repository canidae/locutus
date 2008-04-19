#include "Metadata.h"

/* constructors */
Metadata::Metadata() {
	matrix_size = 64;
	matrix = new int*[matrix_size];
	for (int a = 0; a < matrix_size; ++a) {
		matrix[a] = new int[matrix_size];
		matrix[a][0] = a;
		matrix[0][a] = a;
	}
}

/* destructors */
Metadata::~Metadata() {
	for (int a = 0; a < matrix_size; ++a)
		delete [] matrix[a];
	delete [] matrix;
}

/* methods */
string Metadata::getValue(string key) {
	for (list<Entry>::iterator e = entries.begin(); e != entries.end(); ) {
		if (e->key == key)
			return e->value;
		++e;
	}
	return NULL;
}

void Metadata::setValue(string key, string value) {
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
void Metadata::resize(int size) {
	/* resize the matrix */
	for (int a = 0; a < matrix_size; ++a)
		delete [] matrix[a];
	delete [] matrix;
	matrix_size = size;
	matrix = new int*[matrix_size];
	for (int a = 0; a < matrix_size; ++a) {
		matrix[a] = new int[matrix_size];
		matrix[a][0] = a;
		matrix[0][a] = a;
	}
}

double Metadata::similarity(const string source, const string target) {
	/* Levenshtein distance */
	const int sl = source.length();
	const int tl = target.length();
	if (sl == 0 || tl == 0)
		return 0.0;
	const int size = max(sl, tl);
	if (size + 1 > matrix_size)
		resize(size + 1);

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
