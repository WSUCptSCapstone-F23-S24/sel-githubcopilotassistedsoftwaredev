#ifndef _UDPMULTICAST_H_
#define _UDPMULTICAST_H_

#include <iostream>                    // cerr
#include <sys/types.h>                 // socket
#include <sys/socket.h>                // socket
#include <netinet/in.h>                // inet_addr
#include <arpa/inet.h>                 // inet_addr
#include <strings.h>                   // bzero, strncpy

#include <cstring>                     // strncpy, strlen
#include <cstdio>                      // perror
#include <cstdlib>                     // exit
#include <unistd.h>                    // close

using namespace std;

#define NULL_SD -1
#define BUFSIZE 1024

class UdpMulticast {
   public:
      UdpMulticast(char group[], int port);
      ~UdpMulticast();
      int getClientSocket();
      bool multicast(char buf[]);
      int getServerSocket();
      bool recv(char buf[], int size);
   private:
      int clientSd;
      int serverSd;
      int port;
      char group[BUFSIZE];
};

#endif