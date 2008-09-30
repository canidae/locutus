#ifndef LEVENSHTEIN_H
#define LEVENSHTEIN_H
#define MATRIX_SIZE 64

#include <string>

class Levenshtein {
	public:
		/* constructors/destructor */
		Levenshtein();
		~Levenshtein();

		/* methods */
		double similarity(const std::string &source, const std::string &target);

	private:
		/* variables */
		int **matrix;
		int matrix_size;

		/* methods */
		void createMatrix(int size);
		void deleteMatrix();
		void resizeMatrix(int size);
};
#endif
