#include <fcntl.h> // open
#include <unistd.h> // read
#include <sys/types.h> // read
#include <sys/uio.h> // read
#include <stdio.h> // fopen, fread
#include <sys/time.h> // gettimeofday
#include <iostream> // cout, cerr, endl;

using namespace std;

struct timeval startTime;
struct timeval endTime; // maintain starting and finishing wall time.

void startTimer() 
{ 
    // memorize the starting time
    gettimeofday(&startTime, NULL);
}

void stopTimer(char *str) 
{ 
    // checking the finishing time and computes the elapsed time
    gettimeofday(&endTime, NULL);
    cout << str << "'s elapsed time\t= "
        << ((endTime.tv_sec - startTime.tv_sec) * 1000000 + (endTime.tv_usec - startTime.tv_usec))
        << endl;
}

int main( int argc, char *argv[] ) 
{
    // validate arguments
    if (argc != 3) 
    {
        cerr << "usage: lab3 filename bytes" << endl;
        return -1;
    }

    int bytes = atoi( argv[2] );
    if (bytes < 1) 
    {
        cerr << "usage: lab3 filename bytes" << endl;
        cerr << "where bytes > 0" << endl;
        return -1;
    }

    char *filename = argv[1];
    char *buf = new char[bytes];

    // unix i/o
    int fd = open(filename, O_RDONLY);
    if (fd == -1) 
    {
        cerr << filename << " not found" << endl;
        return -1;
    }

    startTimer();

    while(read(fd, buf, bytes) > 0);

    stopTimer("Unix read");
    close(fd);
    // standard i/o
    // write the same program as unix i/o but use fopen(), fgetc(), fread(), and fclose( )
    FILE *fp = fopen(filename, "r");
    if (fp == NULL) 
    {
        cerr << filename << " not found" << endl;
        return -1;
    }

    startTimer();
    // use fgetc() if bytes == 1
    if (bytes == 1) 
    {
        while (fgetc(fp) != EOF);
    }
    else 
    {
        while (fread(buf, 1, bytes, fp) > 0);
    }
    stopTimer("Standard I/O");
    fclose(fp); 

    
    return 0;
}