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
        cout << "server" << endl;
        cout << "constructor" << endl;
        UdpMulticast server = UdpMulticast(argv[1], stoi(argv[2])); // idk what im doin here
        cout << "socket" << endl;
        int server_socket = server.getServerSocket();
        cout << "recv" << endl;
        if (server.recv(message, SIZE))
            cout << message << endl;
        else
            cout << "message not received" << endl;
    }
    else // it's a Client
    {
        cout << "client" << endl;
        cout << "constructor" << endl;
        UdpMulticast client = UdpMulticast(argv[1], stoi(argv[2])); // idk what im doin here
        cout << "socket" << endl;
        int client_socket = client.getClientSocket();
        cout << "multicast" << endl;
        if (client.multicast(argv[3]))
            cout << "message sent successfully" << endl;
        else
            cout << "message failed" << endl;
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