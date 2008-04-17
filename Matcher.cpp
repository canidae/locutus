#include "Matcher.h"

/* constructors */
Matcher::Matcher() {
	matrix_size = 64;
	matrix = new int*[matrix_size];
	for (int a = 0; a < matrix_size; ++a) {
		matrix[a] = new int[matrix_size];
		matrix[a][0] = a;
		matrix[0][a] = a;
	}
}

/* destructors */
Matcher::~Matcher() {
	for (int a = 0; a < matrix_size; ++a)
		delete [] matrix[a];
	delete [] matrix;
}

/* methods */

/* private methods */
void Matcher::resize(int size) {
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

double Matcher::similarity(const string source, const string target) {
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
