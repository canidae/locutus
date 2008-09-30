#ifndef LEVENSHTEIN_H
#define LEVENSHTEIN_H
#define MATRIX_SIZE 64

#include <string>

class Levenshtein {
	public:
		static void clear();
		static void initialize();
		static double similarity(const std::string &source, const std::string &target);

	private:
		static bool initialized;
		static int **matrix;
		static int matrix_size;

		static void createMatrix(int size);
		static void deleteMatrix();
		static void resizeMatrix(int size);
};
#endif
