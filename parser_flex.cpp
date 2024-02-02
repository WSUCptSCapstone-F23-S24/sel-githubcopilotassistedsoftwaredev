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
        result.tokenclass = ERRORTYPE;
        std::string specialChars = "%*()+=-{}[]:;<>,/?";
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
        
        // handle ++ --
        if (rawToken == "++" ) {
            result.tokenstr = strdup(escapedToken.c_str());
            result.linenum = lineNumber;
            result.tokenclass = INC;
            return result;
        }
        else if (rawToken == "--" ) {
            result.tokenstr = strdup(escapedToken.c_str());
            result.linenum = lineNumber;
            result.tokenclass = DEC;
            return result;
        }
        // Handle strings
        else if (escapedToken.size() > 1 && escapedToken[0] == '"' && escapedToken[escapedToken.size() - 1] == '"') {
            result.tokenclass = STRINGCONST;
            result.tokenstr = strdup(rawToken.c_str());
            // make temp string to process escape characters
            std::string temp = rawToken.substr(1, rawToken.size() - 2);
            // \\n -> \n \\t -> \t \\0 -> \0
            for (int i = 0; i < temp.size(); i++) {
                if (temp[i] == '\\') {
                    if (i + 1 < temp.size()) {
                        if (temp[i + 1] == 'n') {
                            temp[i] = '\n';
                            temp.erase(i + 1, 1);
                        } else if (temp[i + 1] == 't') {
                            temp[i] = '\t';
                            temp.erase(i + 1, 1);
                        } else if (temp[i + 1] == '0') {
                            temp[i] = '\0';
                            temp.erase(i + 1, 1);
                        }
                    }
                }
            }
            result.svalue = strdup(temp.c_str());
            result.linenum = lineNumber;
            result.nvalue = escapedToken.size() - 2;
            return result;
        }

        // Handle numbers
        else if (std::all_of(rawToken.begin(), rawToken.end(), ::isdigit)) {
            result.tokenclass = NUMCONST;
            result.tokenstr = strdup(rawToken.c_str());
            result.nvalue = std::stoi(rawToken);
            result.linenum = lineNumber;
            return result;
        }

        // Handle booleans
        else if (rawToken == "true") {
            result.tokenstr = strdup(rawToken.c_str());
            result.tokenclass = BOOLCONST;
            result.nvalue = 1;
            result.linenum = lineNumber;
            return result;
        } else if (rawToken == "false") {
            result.tokenstr = strdup(rawToken.c_str());
            result.tokenclass = BOOLCONST;
            result.nvalue = 0;
            result.linenum = lineNumber;
            return result;
        }
        
        // Handle IDs/variables
        else if (rawToken.size() > 0 && std::all_of(rawToken.begin(), rawToken.end(), ::isalnum)) {
            result.tokenclass = ID;
            result.tokenstr = strdup(rawToken.c_str());
            result.svalue = strdup(rawToken.c_str());
            result.linenum = lineNumber;
            return result;
        }

        // Handle character constants
        else if (rawToken[0] == '\'' && rawToken[rawToken.size() - 1] == '\'') {
            if (rawToken.size() == 2) {
                std::cout << "Error: Character constant '" << rawToken << "' has no characters at line " << lineNumber << std::endl;
                return result;
            }
            if (escapedToken.size() > 3) {
                //character is 18 characters long and not a single character: ''meerkats are great''.  The first char will be used.
                std::cout << "WARNING(" << lineNumber << "): character is " << rawToken.size() - 2 << " characters long and not a single character: '" << rawToken << "'.  The first char will be used." << std::endl;
            }
            result.tokenstr = strdup(rawToken.c_str());
            if (rawToken == "'\\n'") {
                result.cvalue = '\n';
            } else if (rawToken == "'\\t'") {
                result.cvalue = '\t';
            } else if (rawToken == "'\\0'") {
                result.cvalue = '\0';
            } else {
                result.cvalue = rawToken[1];
            }
            result.linenum = lineNumber;
            result.tokenclass = CHARCONST;
            return result;
        }

        // Handle identifiers
        else if (std::all_of(rawToken.begin(), rawToken.end(), ::isalnum) || rawToken == "_") {
            result.tokenstr = strdup(rawToken.c_str());
            result.linenum = lineNumber;
            return result;
        }
        // Handle special characters
        else if (rawToken.size() == 1 && specialChars.find(rawToken[0]) != std::string::npos) {
            result.tokenstr = strdup(rawToken.c_str());
            result.linenum = lineNumber;
            result.tokenclass = SPECIALCHAR;
            return result;
        }

        // Handle illegal characters
        std::cout << "ERROR(" << lineNumber << "): Invalid or misplaced input character: '" << rawToken << "'. Character Ignored." << std::endl;
        return result;
    }
};





