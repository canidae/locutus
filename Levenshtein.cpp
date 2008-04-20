#include "Levenshtein.h"

/* constructors */
Levenshtein::Levenshtein() {
	pthread_mutex_init(&mutex, NULL);
	createMatrix(MATRIX_SIZE);
}

/* destructors */
Levenshtein::~Levenshtein() {
	pthread_mutex_destroy(&mutex);
	deleteMatrix();
}

/* methods */
double Levenshtein::similarity(const string source, const string target) {
	const int sl = source.length();
	const int tl = target.length();
	if (sl == 0 || tl == 0)
		return 0.0;
	pthread_mutex_lock(&mutex);
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
	double value = 1.0 - (double) matrix[sl][tl] / (double) size;
	pthread_mutex_unlock(&mutex);
	return value;
}

/* private methods */
void Levenshtein::createMatrix(const int size) {
	matrix_size = size;
	matrix = new int*[matrix_size];
	for (int a = 0; a < matrix_size; ++a) {
		matrix[a] = new int[matrix_size];
		matrix[a][0] = a;
		matrix[0][a] = a;
	}
}

void Levenshtein::deleteMatrix() {
	for (int a = 0; a < matrix_size; ++a)
		delete [] matrix[a];
	delete [] matrix;
}

void Levenshtein::resizeMatrix(const int size) {
	deleteMatrix();
	createMatrix(size);
}
