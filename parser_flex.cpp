// contains flex code
#include "scanType.h"

// include libraries without circular dependencies
#include <string.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>




// class with a function to read input token and print it
class FlexScanner {
public:
TokenData scan(std::string token, int lineNumber) {
    TokenData result = TokenData();

    // Ignore whitespace
    if (token.empty() || std::all_of(token.begin(), token.end(), ::isspace)) {
        return result;
    }

    // Handle strings
    if (token.size() > 1 && token[0] == '"' && token[token.size() - 1] == '"') {
        result.tokenstr = strdup(token.c_str());
        result.svalue = strdup(token.substr(1, token.size() - 2).c_str());
        result.linenum = lineNumber;
        return result;
    }

    // Handle comments
    if (token[0] == '#') {
        return result;
    }

    // Handle booleans
    if (token == "true") {
        result.tokenstr = strdup("BOOLCONST");
        result.nvalue = 1;
        result.linenum = lineNumber;
        return result;
    } else if (token == "false") {
        result.tokenstr = strdup("BOOLCONST");
        result.nvalue = 0;
        result.linenum = lineNumber;
        return result;
    }

    // Handle numbers
    if (std::all_of(token.begin(), token.end(), ::isdigit)) {
        result.tokenstr = strdup(token.c_str());
        result.nvalue = std::stoi(token);
        result.linenum = lineNumber;
        return result;
    }

    // Handle character constants
    if (token[0] == '\'' && token[token.size() - 1] == '\'') {
        if (token.size() == 2) {
            std::cerr << "Error: Character constant '" << token << "' has no characters at line " << lineNumber << std::endl;
            return result;
        }
        if (token.size() > 3) {
            std::cerr << "Warning: Character constant '" << token << "' is more than one character at line " << lineNumber << std::endl;
            token = "'" + token.substr(1, 1) + "'";
        }
        result.tokenstr = strdup(token.c_str());
        result.nvalue = static_cast<int>(token[1]); // Cast character constant to integer
        result.linenum = lineNumber;
        return result;
    }

    // Handle identifiers
    if (std::all_of(token.begin(), token.end(), ::isalnum) || token == "_") {
        result.tokenstr = strdup(token.c_str());
        result.linenum = lineNumber;
        return result;
    }

    // Handle special characters
    std::string specialChars = "%*()+=-{}[]:;<>,/";
    if (token.size() == 1 && specialChars.find(token[0]) != std::string::npos) {
        result.tokenstr = strdup(token.c_str());
        result.linenum = lineNumber;
        return result;
    }

    // Handle illegal characters
    std::cerr << "ERROR(" << lineNumber << "): Invalid or misplaced input character: '" << token << "'. Character Ignored." << std::endl;
    return result;
}
};






