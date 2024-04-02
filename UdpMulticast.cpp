#include "UdpMulticast.h"

UdpMulticast::UdpMulticast(char group[], int port) : port(port), clientSd(NULL_SD), serverSd(NULL_SD) {
   strncpy(this->group, group, BUFSIZE);
}

UdpMulticast::~UdpMulticast() {
   if (clientSd != NULL_SD) {
      close(clientSd);
   }
   if (serverSd != NULL_SD) {
      close(serverSd);
   }
}

int UdpMulticast::getClientSocket() {
   // create what looks like an ordinary UDP socket
   if ((clientSd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
      perror("socket");
      return NULL_SD;
   }
   return clientSd;
}

bool UdpMulticast::multicast(char buf[]) {
   // set up destination address
   struct sockaddr_in addr;
   bzero(&addr, sizeof(addr));
   addr.sin_family = AF_INET;
   addr.sin_addr.s_addr = inet_addr(group);
   addr.sin_port = htons(port);

   // broadcast a message
   if (sendto(clientSd, buf, strlen(buf), 0, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
      perror("sendto");
      return false;
   }
   return true;
}

int UdpMulticast::getServerSocket() {
   // create what looks like an ordinary UDP socket
   if ((serverSd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
      perror("socket");
      exit( NULL_SD );
   }
   // set up destination address
   struct sockaddr_in addr;
   bzero(&addr, sizeof(addr));
   addr.sin_family = AF_INET;
   addr.sin_addr.s_addr = htonl(INADDR_ANY);
   addr.sin_port=htons(port);

   // bind to receive address
   if (bind(serverSd,(struct sockaddr*)&addr, sizeof(addr)) < 0) {
      perror("bind");
      return NULL_SD;
   }

   // use setsockopt() to request that the kernel join a multicast group
   struct ip_mreq mreq;
   mreq.imr_multiaddr.s_addr = inet_addr(group);
   mreq.imr_interface.s_addr = htonl(INADDR_ANY);
   if (setsockopt(serverSd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) < 0) {
      perror("setsockopt");
      return NULL_SD;
   }
   return serverSd;
}

bool UdpMulticast::recv(char buf[], int size) {
   bzero(buf, size);
   struct sockaddr src_addr;
   socklen_t src_addrlen = sizeof(src_addr);
   bzero((char*)&src_addr, src_addrlen);
   if (recvfrom(serverSd, buf, size, 0, &src_addr, &src_addrlen) < 0) {
      perror("recvfrom");
      return false;
   }
   return true;
}