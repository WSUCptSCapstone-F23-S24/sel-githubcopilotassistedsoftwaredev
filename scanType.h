#ifndef _SCANTYPE_H_
#define _SCANTYPE_H_

#define ERRORTYPE  -1
#define STRINGCONST 0
#define CHARCONST   1
#define ID          2
#define SPECIALCHAR 3
#define NUMCONST    4
#define BOOLCONST   5
#define INC         6
#define DEC         7

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
    switch (tokenclass) {
        case STRINGCONST:
            std::cout << "Line " << linenum << " Token: STRINGCONST Value: \"" << svalue << "\" Len: " << nvalue << " Input: " << tokenstr << std::endl;
            break;
        case CHARCONST:
            std::cout << "Line " << linenum << " Token: CHARCONST Value: '" << cvalue << "' Input: " << tokenstr << std::endl;
            break;
        case ID:
            std::cout << "Line " << linenum << " Token: ID Value: " << svalue << std::endl;
            break;
        case SPECIALCHAR:
            std::cout << "Line " << linenum << " Token: " << tokenstr << std::endl;
            break;
        case NUMCONST:
            std::cout << "Line " << linenum << " Token: NUMCONST Value: " << nvalue << " Input: " << tokenstr << std::endl;
            break;
        case BOOLCONST:
            std::cout << "Line " << linenum << " Token: BOOLCONST Value: " << nvalue << " Input: " << tokenstr << std::endl;
            break;
        case INC:
            std::cout << "Line " << linenum << " Token: INC" << std::endl;
            break;
        case DEC:
            std::cout << "Line " << linenum << " Token: DEC" << std::endl;
            break;
        default:
            break;
    }   
}
};
#endif
