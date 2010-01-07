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

#include "Levenshtein.h"

using namespace std;

bool Levenshtein::initialized = false;
int** Levenshtein::matrix = NULL;
int Levenshtein::matrix_size = 0;

void Levenshtein::clear() {
	if (!initialized)
		return;
	initialized = false;
	deleteMatrix();
}

void Levenshtein::initialize() {
	if (initialized)
		return;
	initialized = true;
	createMatrix(MATRIX_SIZE);
}

double Levenshtein::similarity(const string& source, const string& target) {
	if (!initialized)
		initialize();
	int sl = source.length();
	int tl = target.length();
	if (sl == 0 || tl == 0)
		return 0.0;
	int size = max(sl, tl);
	if (size + 1 > matrix_size)
		resizeMatrix(size + 1);

	for (int a = 1; a <= sl; ++a) {
		char s = source[a - 1];
		/* make A-Z lowercase */
		if (s >= 'A' && s <= 'Z')
			s += 32;
		for (int b = 1; b <= tl; ++b) {
			char t = target[b - 1];
			/* make A-Z lowercase */
			if (t >= 'A' && t <= 'Z')
				t += 32;
			int cost = (s == t ? 0 : 1);

			int above = matrix[a - 1][b];
			int left = matrix[a][b - 1];
			int diag = matrix[a - 1][b - 1];
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

void Levenshtein::createMatrix(int size) {
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

void Levenshtein::resizeMatrix(int size) {
	deleteMatrix();
	createMatrix(size);
}
