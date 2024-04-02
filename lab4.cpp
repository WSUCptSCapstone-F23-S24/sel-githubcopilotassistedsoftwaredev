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
    if (argc == 3) // then it's a Server
    {
        UdpMulticast server = UdpMulticast(argv[1], (int) argv[2]); // idk what im doin here
    }
    else // it's a Client
    {

    }

    return 0;
}

/*  Methods:
        UdpMulticast( char group[], int port )
        ~UdpMulticast( )
        int getClientSocket( ) 
        int getServerSocket( )
        bool multicast( char buf[] )
        recv( char buf[], int size )
*/