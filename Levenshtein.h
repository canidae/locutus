#ifndef LEVENSHTEIN_H
/* defines */
#define LEVENSHTEIN_H
/* start size matrix */
#define MATRIX_SIZE 64

/* includes */
#include <string>

/* namespaces */
using namespace std;

/* Levenshtein */
class Levenshtein {
	public:
		/* variables */

		/* constructors */
		Levenshtein();

		/* destructors */
		~Levenshtein();

		/* methods */
		double similarity(const string source, const string target);

	private:
		/* variables */
		int **matrix;
		int matrix_size;
		pthread_mutex_t mutex;

		/* methods */
		void createMatrix(const int size);
		void deleteMatrix();
		void resizeMatrix(const int size);
};
#endif
