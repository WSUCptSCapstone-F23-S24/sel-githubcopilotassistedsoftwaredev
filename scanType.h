#ifndef _SCANTYPE_H_
#define _SCANTYPE_H_
// 
//  SCANNER TOKENDATA
// 
struct TokenData {
    int tokenclass;   // token class
    int linenum;      // line number where token found
    char *tokenstr;   // literal string for token for use
    int idValue;      // location in array of values of variable
    double numValue;  // value of number if number
};
#endif