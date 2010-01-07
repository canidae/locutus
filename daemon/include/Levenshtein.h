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

#ifndef LEVENSHTEIN_H
#define LEVENSHTEIN_H

#include <string>

#define MATRIX_SIZE 64

class Levenshtein {
public:
	static void clear();
	static void initialize();
	static double similarity(const std::string& source, const std::string& target);

private:
	static bool initialized;
	static int** matrix;
	static int matrix_size;

	static void createMatrix(int size);
	static void deleteMatrix();
	static void resizeMatrix(int size);
};
#endif
