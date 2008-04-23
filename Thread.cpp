#include "Thread.h"

/* constructors */
Thread::Thread() {
	active = false;
}

/* destructors */
Thread::~Thread() {
}

/* wrapper */
void *run_thread(void *ptr) {
	Thread *mythread = reinterpret_cast<Thread *>(ptr);
	mythread->run();
	return NULL;
}

/* methods */
void Thread::run() {
}

void Thread::start() {
	if (active)
		return;
	active = true;
	pthread_create(&thread, NULL, run_thread, reinterpret_cast<void *>(this));
}

void Thread::stop() {
	if (!active)
		return;
	active = false;
	pthread_join(thread, NULL);
}
