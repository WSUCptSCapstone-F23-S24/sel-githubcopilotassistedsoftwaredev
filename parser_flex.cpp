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
TokenData scan(std::string rawToken, int lineNumber) {
    TokenData result = TokenData();
    result.nvalue = -1;

    std::string escapedToken = "";
    // escaped token should have all \ characters removed unless there are two in a row, then remove one of them
    for (int i = 0; i < rawToken.size(); i++) {
        if (rawToken[i] == '\\') {
            if (i + 1 < rawToken.size() && rawToken[i + 1] == '\\') {
                escapedToken += '\\';
                i++;
            }
        } else {
            escapedToken += rawToken[i];
        }
    }
    
    // Handle strings
    if (escapedToken.size() > 1 && escapedToken[0] == '"' && escapedToken[escapedToken.size() - 1] == '"') {
        result.tokenclass = STRINGCONST;
        result.tokenstr = strdup(rawToken.c_str());
        result.svalue = strdup(escapedToken.substr(1, escapedToken.size() - 2).c_str());
        result.linenum = lineNumber;
        result.nvalue = escapedToken.size() - 2;
        return result;
    }
    
    // Handle IDs/variables
    if (rawToken.size() > 1 && std::all_of(rawToken.begin(), rawToken.end(), ::isalnum)) {
        result.tokenclass = ID;
        result.tokenstr = strdup(rawToken.c_str());
        result.svalue = strdup(rawToken.c_str());
        result.linenum = lineNumber;
        return result;
    }

    // Handle comments
    if (rawToken[0] == '#') {
        return result;
    }

    // Handle booleans
    if (rawToken == "true") {
        result.tokenstr = strdup("BOOLCONST");
        result.nvalue = 1;
        result.linenum = lineNumber;
        return result;
    } else if (rawToken == "false") {
        result.tokenstr = strdup("BOOLCONST");
        result.nvalue = 0;
        result.linenum = lineNumber;
        return result;
    }

    // Handle numbers
    if (std::all_of(rawToken.begin(), rawToken.end(), ::isdigit)) {
        result.tokenstr = strdup(rawToken.c_str());
        result.nvalue = std::stoi(rawToken);
        result.linenum = lineNumber;
        return result;
    }

    // Handle character constants
    if (rawToken[0] == '\'' && rawToken[rawToken.size() - 1] == '\'') {
        if (rawToken.size() == 2) {
            std::cout << "Error: Character constant '" << rawToken << "' has no characters at line " << lineNumber << std::endl;
            return result;
        }
        if (escapedToken.size() > 3) {
            //character is 18 characters long and not a single character: ''meerkats are great''.  The first char will be used.
            std::cout << "WARNING(" << lineNumber << "): character is " << rawToken.size() - 2 << " characters long and not a single character: '" << rawToken << "'.  The first char will be used." << std::endl;
        }
        result.tokenstr = strdup(rawToken.c_str());
        result.cvalue = escapedToken[1];
        result.linenum = lineNumber;
        result.tokenclass = CHARCONST;
        return result;
    }

    // Handle identifiers
    if (std::all_of(rawToken.begin(), rawToken.end(), ::isalnum) || rawToken == "_") {
        result.tokenstr = strdup(rawToken.c_str());
        result.linenum = lineNumber;
        return result;
    }

    // Handle special characters
    std::string specialChars = "%*()+=-{}[]:;<>,/";
    if (rawToken.size() == 1 && specialChars.find(rawToken[0]) != std::string::npos) {
        result.tokenstr = strdup(rawToken.c_str());
        result.linenum = lineNumber;
        return result;
    }

    // Handle illegal characters
    // std::cerr << "ERROR(" << lineNumber << "): Invalid or misplaced input character: '" << rawToken << "'. Character Ignored." << std::endl;
    return result;
}
};






