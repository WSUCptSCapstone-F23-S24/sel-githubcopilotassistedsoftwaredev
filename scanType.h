#ifndef _SCANTYPE_H_
#define _SCANTYPE_H_

#define STRINGCONST 0
#define CHARCONST   1
#define ID          2

#include <iostream>

// 
//  SCANNER TOKENDATA
// 
struct TokenData {
    int  tokenclass;        // token class
    int  linenum;           // line where found
    char *tokenstr;         // what string was actually read
    char cvalue;            // any character value
    int  nvalue;            // any numeric value or Boolean value
    char *svalue;           // any string value e.g. an id

    void print()
    {
        // what is switch statement syntax?
        switch (tokenclass) {
            case STRINGCONST:
                std::cout << "Line " << linenum << " Token: STRINGCONST Value: \"" << svalue << "\" Len: " << nvalue << " Input: " << tokenstr << std::endl;
                break;
            case CHARCONST:
                std::cout << "Line " << linenum << " Token: CHARCONST Value: '" << cvalue << "' Input: " << tokenstr << std::endl;
                break;
            case ID:
                std::cout << "Line " << linenum << " Token: ID Value: " << svalue << " Input: " << tokenstr << std::endl;
                break;
            default:
                std::cout << "Line " << linenum << " Token: " << tokenstr << std::endl;
                break;
        }   
    }
};
#endif