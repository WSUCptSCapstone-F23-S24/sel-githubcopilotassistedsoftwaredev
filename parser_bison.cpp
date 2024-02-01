// contains bison code

// main function
#include <string.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include "scanType.h"
#include "parser_flex.cpp"


int findEndOfToken(std::string line, int index, char c);

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
    std::string token = "";
    while (std::getline(*input, line)) {
        for (int i = 0; i<line.size(); i++) {
            token = "";
            char c = line[i];
            // possible string
            if (c == '"') {
                int end = findEndOfToken(line, i+1, '"');
                if (end != -1) {
                    // found end of string
                    token = line.substr(i, end-i+1);
                    i = end;
                }
            }
            //possible character
            else if (c == '\'') {
                int end = findEndOfToken(line, i+1, '\'');
                if (end != -1) {
                    // found end of string
                    token = line.substr(i, end-i+1);
                    i = end;
                }
            }
            // possible number
            else if (isdigit(c)){
                //id value
                int j = i;
                // iterate until next whitespace or non alphabetical character
                while (j < line.size() && isdigit(line[j])) {
                    j++;
                }
                token = line.substr(i, j-i);
                i = j-1;
            }
            // possible id/variable
            else if (isalnum(c)) {
                //id value
                int j = i;
                // iterate until next whitespace or non alphabetical character
                while (j < line.size() && isalnum(line[j])) {
                    j++;
                }
                token = line.substr(i, j-i);
                i = j-1;
            }
            // get ++ and --
            else if (c == '+' || c == '-') {
                if (i+1 < line.size() && line[i+1] == c) {
                    token = line.substr(i, 2);
                    i++;
                }
            }

            // single character case
            if (token == "") {
                token = std::string(1, c);
            }
            // ignore comments
            if (token == "/" && i+1 < line.size() && line[i+1] == '/') {
                break;
            }
            //if character is whitespace, continue
            if (std::all_of(token.begin(), token.end(), ::isspace)) {
                continue;
            }
            // std::cout << token << std::endl;
            TokenData result = FlexScanner().scan(token, line_number);
            result.print();
        }
        ++line_number;
    }

}

// findEndOfToken function takes a string, an index, and a character and returns the index of the next occurence of the character in the string
// the next occurrance must not have a backslash before it
// if the character is not found, the function returns -1
int findEndOfToken(std::string line, int index, char c) {
    // check if character is in string
    int found = line.find(c, index);
    if (found == std::string::npos) {
        // character not found
        return -1;
    }
    // check if character is escaped
    if (found > 0 && line[found-1] == '\\' && line[found-2] != '\\') {
        // character is escaped
        return findEndOfToken(line, found+1, c);
    }
    // character is not escaped
    return found;
}
