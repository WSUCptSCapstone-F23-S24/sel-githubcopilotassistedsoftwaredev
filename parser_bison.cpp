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
    int line_number = 1;
    std::string line;
    std::string token;
    while (std::getline(*input, line)) {
        for (int i = 0; i<line.size(); i++) {
            char c = line[i];
            // possible string
            if (c == '"') {
                // look for end of string (next ")
                int end = line.find('"', i+1);
                if (end != std::string::npos) {
                    // found end of string
                    token = line.substr(i, end-i+1);
                    TokenData result = FlexScanner().scan(token, line_number);

                    if (result.tokenstr != nullptr) {
                        std::cout << " Line " << result.linenum << " Token: " << result.tokenstr  << std::endl;
                    }

                    i = end;
                    continue;
                }
            }

            // single character case
            std::string token(1, c);
            TokenData result = FlexScanner().scan(token, line_number);
            if (result.tokenstr != nullptr) {
                std::cout << " Line " << result.linenum << " Token: " << result.tokenstr  << std::endl;
            }
            


            
        }
        ++line_number;
    }

}





