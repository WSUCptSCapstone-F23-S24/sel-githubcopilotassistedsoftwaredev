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

    // open a socket
    UdpMulticast socket = UdpMulticast( group, port );

    // if message is not null, send the message using multicast function
    if ( message != NULL )
    {
        //behave as client
        socket.getClientSocket();
        socket.multicast( message );
    }
    else
    {
        // behave as server
        int serverSocket = socket.getServerSocket();
        char recvBuffer[SIZE];
        while ( true )
        {
            if ( socket.recv( recvBuffer, SIZE ) )
            {
                cout << recvBuffer << endl;
            }
        }
        
    }
    
    return 0;
}
