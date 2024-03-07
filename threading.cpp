#include <iostream> // cout

using namespace std;

int nThreads; // #threads
int turn; // turn points which thread should run
pthread_mutex_t mutex; // a lock for this critical section
pthread_cond_t *cond; // array of condition variable[nThreads]

void *thread_func( void *arg ) {
    int id = ((int *)arg)[0]; // this thread's identifier
    delete (int *)arg;
    for ( int loop = 0; loop < 10; loop++ ) { // repeat 10 times
        // enter the critical section
        pthread_mutex_lock(&mutex);
        while ( turn != id ) {
        // wait until the (id - 1)th thread signals me.
        pthread_cond_wait(&cond[id], &mutex);
        }
        cout << "thread["<< id << "] got " << loop << "th turn" << endl;
        // signal the next thread
        turn = (turn + 1) % nThreads;
        pthread_cond_signal(&cond[turn]);
        // leave the critical section
        pthread_mutex_unlock(&mutex);
    }

    pthread_exit(NULL);
}

int main( int argc, char *argv[] ) {
    // validate arguments
    if ( argc != 2 ) 
    {
        cerr << "usage: lab2 #threads" << endl;
        return -1;
    }

    nThreads = atoi( argv[1] );

    if ( nThreads < 1 ) 
    {
        cerr << "usage: lab1 #threads" << endl;
        cerr << "where #threads >= 1" << endl;
        return -1;
    }

    pthread_t *tid = new pthread_t[nThreads]; // an array of thread identifiers
    cond = new pthread_cond_t[nThreads]; // an array of condition variables
    turn = 0; // turn points which thread should run

    for ( int i = 0; i < nThreads; i++ ) 
    { 
        // start a give number (nThreads) of threads.
        int *id = new int[1];
        id[0] = i;
        pthread_create( &tid[0], NULL, thread_func, (void *)id );
    }

    for ( int i = 0; i < nThreads; i++ ) 
    {
        // wait for all the child threads.
        pthread_join( tid[0], NULL );
    }
}
