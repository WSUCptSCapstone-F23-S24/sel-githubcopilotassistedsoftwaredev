#include "UdpMulticast.h" // UdpMulticast
#include <iostream> // cerr
#define SIZE 1024 // buffer[SIZE]
using namespace std;
int main( int argc, char *argv[] ) {
    // validate arguments
    if ( argc < 3 ) 
    {
        cerr << "usage: lab4 group port [message]" << endl;
        return -1;
    }
    
    char *group = argv[1];
    int port = atoi( argv[2] );
    if ( port < 5001 ) 
    {
        cerr << "usage: lab4 group port [message]" << endl;
        return -1;
    }

    char *message = ( argc == 4 ) ? argv[3] : NULL;
    // if message is null, the program should behave as a server,
    // otherwise as a client.
    return 0;
}