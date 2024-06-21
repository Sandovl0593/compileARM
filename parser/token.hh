#include <iostream>
#include <unordered_map>

using namespace std;

class Token {
public:
    enum Type { LCOR=0, RCOR, COMMA, SEMICOLON,  // delimiters
                ADD, SUB, FMUL, AND, ORR,  // oper
                ADDS, SUBS, FMULS,  // oper with act flags
                LDR, STR, LSL, LSR,        // reg / shift
                NUMERAL, DNUM, HEXNUM, REG,// values
                LABEL, TPOINTS, BRANCH,         // LABEL branching
                ERR, END
    };
    enum Mnemonic { UNCOND=0, EQ, GT, LT, GE, LE, NE, ERRMNE };

    static const char* token_names[31];
    static const char* mnemonic_names[8];
    Type type;
    Mnemonic mnemonic = UNCOND;
    string lexema;

    Token(Type type);
    Token(Type type, char c);
    Token(Type type, Mnemonic mnemonic);
    Token(Type type, const string source);
    // Token(Type type, const string source, Mnemonic mnemonic);
};

const char* Token::token_names[31] = {
    "LCOR", "RCOR", "COMMA", "SEMICOLON", // delimiters
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

// Token::Token(Type type, const string source, Mnemonic mnemonic): type(type), lexema(source), mnemonic(mnemonic) {}

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


// --------- codes for ARM instructions ---------
unordered_map<string, string> commands = {
  {"ADD" ,"0100"},
  {"SUB" ,"0010"},
  {"ORR" ,"1100"},
  {"AND" ,"0000"},
  {"FMUL","1111"},
  {"LSL" ,"1101"},
  {"LSR" ,"1101"},
  // {"ASR" ,"1101"},
  // {"ROR" ,"1101"}
};

unordered_map<string, string> conditions = {
  {"EQ", "0000"},
  {"NE", "0001"},
  {"CS", "0010"},
  {"CC", "0011"},
  {"MI", "0100"},
  {"PL", "0101"},
  {"VS", "0110"},
  {"VC", "0111"},
  {"HI", "1000"},
  {"LS", "1001"},
  {"GE", "1010"},
  {"LT", "1011"},
  {"GT", "1100"},
  {"LE", "1101"},
  {"UNCOND", "1110"}
};

unordered_map<string, string> shift = {
  {"LSL", "00"},
  {"LSR", "01"},
  // {"ASR", "10"},
  // {"ROR", "11"}
};

unordered_map<Token::Type, string> tokToStr = {
  {Token::ADD, "ADD"},
  {Token::SUB, "SUB"},
  {Token::FMUL, "FMUL"},
  {Token::AND, "AND"},
  {Token::ORR, "ORR"},
  {Token::LSL, "LSL"},
  {Token::LSR, "LSR"},
  {Token::ADDS, "ADDS"},
  {Token::SUBS, "SUBS"},
  {Token::FMULS, "FMULS"},
  {Token::LDR, "LDR"},
  {Token::STR, "STR"},
  {Token::BRANCH, "B"}
};

unordered_map<Token::Mnemonic, string> CToStr = {
  {Token::EQ, "EQ"},
  {Token::GT, "GT"},
  {Token::LT, "LT"},
  {Token::GE, "GE"},
  {Token::LE, "LE"},
  {Token::NE, "NE"},
};