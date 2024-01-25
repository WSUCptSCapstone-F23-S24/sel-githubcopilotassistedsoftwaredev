// contains bison code

// main function
#include <string.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include "scanType.h"
#include "parser_flex.cpp"

int main(int argc, char **argv) {

    std::istream *input;
    std::ifstream file;
    // check if filename with .c- extension is given or if file data is piped into the program
    if (argc == 2) {
        // open file
        file.open(argv[1]);
        if (file.is_open()) {
            input = &file;
        } else {
            // print error message
            std::cout << "Unable to open file" << std::endl;
        }
    } else {
        // read from stdin
        input = &std::cin;
    }

    // read input token by token and print it
    std::string token;
    while (*input >> token) {
        TokenData result = FlexScanner().scan(token);
        std::cout << "Token: " << result.tokenstr << std::endl;
        std::getline(*input, token);
    }
}



