#ifndef THREAD_H
/* defines */
#define THREAD_H

/* includes */
#include <pthread.h>

/* namespaces */
using namespace std;

/* Thread */
class Thread {
	public:
		/* constructors */
		Thread();

		/* destructors */
		~Thread();

		/* methods */
		virtual void run();
		void start();
		void stop();

	private:
		/* variables */
		bool active;
		pthread_t thread;
};
#endif
