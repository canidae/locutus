#ifndef MATCHER_H
/* defines */
#define MATCHER_H

/* includes */
#include <string>

/* namespace */
using namespace std;

/* Matcher */
class Matcher {
	public:
		/* variables */

		/* constructors */
		Matcher();

		/* destructors */
		~Matcher();

		/* methods */
		double similarity(string source, string target);

	private:
		/* variables */
		int **matrix;
		int matrix_size;

		/* methods */
		void resize(int size);
};
#endif
