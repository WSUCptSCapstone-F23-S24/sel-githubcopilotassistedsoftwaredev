// contains flex code
#include "scanType.h"

// include libraries without circular dependencies
#include <string.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <sstream>



// class with a function to read input token and print it
class FlexScanner {
    public:
        // read input token by token and print it
        TokenData scan(std::string token) {
            TokenData result = TokenData();
            result.tokenstr = strdup(token.c_str());
            return result;
        }
};



