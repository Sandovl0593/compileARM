#include <iostream>

using namespace std;

class Token {
public:
    enum Type { LCOR=0, RCOR, COMMA, 
                ADD, SUB, FMUL, AND, ORR,  // oper
                ADDS, SUBS, FMULS,  // oper with act flags
                LDR, STR, LSL, LSR,        // reg / shift
                NUMERAL, DNUM, HEXNUM, REG,// values
                LABEL, TPOINTS, BRANCH,         // LABEL branching
                ERR, END
    };
    enum Mnemonic { UNCOND=0, EQ, GT, LT, GE, LE, NE, ERRMNE };

    static const char* token_names[30];
    static const char* mnemonic_names[8];
    Type type;
    Mnemonic mnemonic = UNCOND;
    string lexema;

    Token(Type);
    Token(Type, char c);
    Token::Token(Type type, Mnemonic mnemonic);
    Token(Type, const string source);
    Token(Type type, const string source, Mnemonic mnemonic);
};

const char* Token::token_names[30] = {
    "LCOR", "RCOR", "COMMA",
    "ADD", "SUB", "FMUL", "AND", "ORR", // oper
    "ADDS", "SUBS", "FMULS",            // oper with act flags
    "LDR", "STR", "LSL", "LSR",         // reg / shift
    "NUMERAL", "DNUM", "HEXNUM", "REG", // values
    "LABEL", "TPOINTS", "B",           // LABEL branching
    "ERR", "END"
};

const char* Token::mnemonic_names[8] = { "UNCOND", "EQ", "GT", "LT", "GE", "LE", "NE", "ERRMNE" };

Token::Token(Type type):type(type) { lexema = ""; }

Token::Token(Type type, char c):type(type) { lexema = c; }

Token::Token(Type type, Mnemonic mnemonic): type(type), mnemonic(mnemonic) {}

Token::Token(Type type, const string source): type(type), lexema(source) {}

Token::Token(Type type, const string source, Mnemonic mnemonic): type(type), lexema(source), mnemonic(mnemonic) {}

std::ostream& operator << ( std::ostream& outs, const Token & tok ) {
    string tokk = Token::token_names[tok.type];
    if (tok.mnemonic != Token::UNCOND) 
        tokk += Token::mnemonic_names[tok.mnemonic];

    if (tok.lexema.empty())
        return outs << tokk;
    else
        return outs << tokk << "(" << tok.lexema << ")";
}

std::ostream& operator << ( std::ostream& outs, const Token* tok ) {
    return outs << *tok;
}