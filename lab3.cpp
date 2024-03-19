#include <fcntl.h> // open
#include <unistd.h> // read
#include <sys/types.h> // read
#include <sys/uio.h> // read
#include <stdio.h> // fopen, fread
#include <sys/time.h> // gettimeofday
#include <iostream> // cout, cerr, endl;

using namespace std;

struct timeval start, finish; // maintain starting and finishing wall time.

void startTimer( ) 
{ // memorize the starting time
   gettimeofday( &start, NULL );
}

void stopTimer( char *str ) 
{ // checking the finishing time and computes the elapsed time 
   gettimeofday( &finish, NULL );
   cout << str << "'s elapsed time\t= "
   << ( ( finish.tv_sec - start.tv_sec ) * 1000000 + (finish.tv_usec - start.tv_usec ) ) 
   << endl;
}

int main( int argc, char *argv[] ) 
{
   // validate arguments
   if ( argc != 3 ) {
      cerr << "usage: lab3 filename bytes" << endl;
      return -1;
   }
   int bytes = atoi( argv[2] );
   if ( bytes < 1 ) 
   {
      cerr << "usage: lab3 filename bytes" << endl;
      cerr << "where bytes > 0" << endl;
      return -1;
   }
   char *filename = argv[1];
   char *buf = new char[bytes];

   // unix i/o
   int fd = open( filename, O_RDONLY );
   if ( fd == -1 )
   {
      cerr << filename << " not found" << endl;
      return -1;
   }
   startTimer( );
   while( read( fd, buf, bytes ) > 0 );
   stopTimer( "Unix read" );
   close( fd );
   
   // standard i/o
   // write the same program as unix i/o but use fopen(), fgetc(), fread(), and fclose( ) // use fgetc() if bytes == 1
   FILE* fp = fopen(filename, "r");
   if (!fp)
   {
      cerr << filename << " not found" << endl;
      return -1;
   }
   startTimer( );
   while(feof(fp) == 0)
   {
      fread(buf, bytes, 1, fp);
   }
   stopTimer( "Standard fread" );
   fclose(fp);




   return 0;
}