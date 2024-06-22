#include <iostream>
#include <unordered_map>
#define TOKENS 100
using namespace std;

class Token {
public:
    enum Type { 
      ADD=1, ADDEQ, ADDNE, ADDGT, ADDGE, ADDLT, ADDLE,
      SUB, SUBEQ, SUBNE, SUBGT, SUBGE, SUBLT, SUBLE,
      FMUL, FMULEQ, FMULNE, FMULGT, FMULGE, FMULLT, FMULLE,
      AND, ANDEQ, ANDNE, ANDGT, ANDGE, ANDLT, ANDLE,
      ORR, ORREQ, ORRNE, ORRGT, ORRGE, ORRLT, ORRLE,
      LSL, LSLEQ, LSLNE, LSLGT, LSLGE, LSLLT, LSLLE,
      LSR, LSREQ, LSRNE, LSRGT, LSRGE, LSRLT, LSRLE,
      LDR, LDREQ, LDRNE, LDRGT, LDRGE, LDRLT, LDRLE,
      STR, STREQ, STRNE, STRGT, STRGE, STRLT, STRLE,
      ASR, ASREQ, ASRNE, ASRGT, ASRGE, ASRLT, ASRLE,
      ROR, ROREQ, RORNE, RORGT, RORGE, RORLT, RORLE,
      B, BEQ, BNE, BGT, BGE, BLT, BLE,
      
      LCOR, RCOR, COMMA, SEMICOLON,
      ADDS, SUBS, FMULS,              // oper with act flags
      DNUM, HEXNUM, REG,              // values
      LABEL, TPOINTS,         // LABEL branching
      ERR, END
    };
    enum Mnemonic { UNCOND=0, EQ, NE, GT, GE, LT, LE };

    static const char* token_names[TOKENS];
    static const char* mnemonic_names[7];
    Type type;
    Mnemonic mnemonic = UNCOND;
    string lexema;

    Token(Type type);
    Token(Type type, char c);
    Token(Type type, Mnemonic mnemonic);
    Token(Type type, const string source);
};

const char* Token::token_names[TOKENS] = { 
  "ADD", "ADDEQ", "ADDNE", "ADDGT", "ADDGE", "ADDLT", "ADDLE",
  "SUB", "SUBEQ", "SUBNE", "SUBGT", "SUBGE", "SUBLT", "SUBLE",
  "FMUL", "FMULEQ", "FMULNE", "FMULGT", "FMULGE", "FMULLT", "FMULLE",
  "AND", "ANDEQ", "ANDNE", "ANDGT", "ANDGE", "ANDLT", "ANDLE",
  "ORR", "ORREQ", "ORRNE", "ORRGT", "ORRGE", "ORRLT", "ORRLE",
  "LSL", "LSLEQ", "LSLNE", "LSLGT", "LSLGE", "LSLLT", "LSLLE",
  "LSR", "LSREQ", "LSRNE", "LSRGT", "LSRGE", "LSRLT", "LSRLE",
  "LDR", "LDREQ", "LDRNE", "LDRGT", "LDRGE", "LDRLT", "LDRLE",
  "STR", "STREQ", "STRNE", "STRGT", "STRGE", "STRLT", "STRLE",
  "ASR", "ASREQ", "ASRNE", "ASRGT", "ASRGE", "ASRLT", "ASRLE",
  "ROR", "ROREQ", "RORNE", "RORGT", "RORGE", "RORLT", "RORLE",
  "B", "BEQ", "BNE", "BGT", "BGE", "BLT", "BLE",
  
  "LCOR", "RCOR", "COMMA", "SEMICOLON",
  "ADDS", "SUBS", "FMULS",              // oper with act flags
  "DNUM", "HEXNUM", "REG",              // values
  "LABEL", "TPOINTS",         // LABEL branching
  "ERR", "END"
};

const char* Token::mnemonic_names[7] = { "UNCOND", "EQ", "GT", "LT", "GE", "LE", "NE" };

Token::Token(Type type):type(type) { lexema = ""; }

Token::Token(Type type, char c):type(type) { lexema = c; }

Token::Token(Type type, Mnemonic mnemonic): type(type), mnemonic(mnemonic) {}

Token::Token(Type type, const string source): type(type), lexema(source) {}

std::ostream& operator << ( std::ostream& outs, const Token & tok ) {
    string tokk = Token::token_names[tok.type-1];
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

const Token::Type ordered[TOKENS-14] = { 
    Token::ADD, Token::ADDEQ, Token::ADDNE, Token::ADDGT, Token::ADDGE, Token::ADDLT, Token::ADDLE,
    Token::SUB, Token::SUBEQ, Token::SUBNE, Token::SUBGT, Token::SUBGE, Token::SUBLT, Token::SUBLE,
    Token::FMUL, Token::FMULEQ, Token::FMULNE, Token::FMULGT, Token::FMULGE, Token::FMULLT, Token::FMULLE,
    Token::AND, Token::ANDEQ, Token::ANDNE, Token::ANDGT, Token::ANDGE, Token::ANDLT, Token::ANDLE,
    Token::ORR, Token::ORREQ, Token::ORRNE, Token::ORRGT, Token::ORRGE, Token::ORRLT, Token::ORRLE,
    Token::LSL, Token::LSLEQ, Token::LSLNE, Token::LSLGT, Token::LSLGE, Token::LSLLT, Token::LSLLE,
    Token::LSR, Token::LSREQ, Token::LSRNE, Token::LSRGT, Token::LSRGE, Token::LSRLT, Token::LSRLE,
    Token::LDR, Token::LDREQ, Token::LDRNE, Token::LDRGT, Token::LDRGE, Token::LDRLT, Token::LDRLE,
    Token::STR, Token::STREQ, Token::STRNE, Token::STRGT, Token::STRGE, Token::STRLT, Token::STRLE,
    Token::ASR, Token::ASREQ, Token::ASRNE, Token::ASRGT, Token::ASRGE, Token::ASRLT, Token::ASRLE,
    Token::ROR, Token::ROREQ, Token::RORNE, Token::RORGT, Token::RORGE, Token::RORLT, Token::RORLE,
    Token::B, Token::BEQ, Token::BNE, Token::BGT, Token::BGE, Token::BLT, Token::BLE,
  };


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
  {"GE", "1010"},
  {"GT", "1100"},
  {"LT", "1011"},
  {"LE", "1101"},
  {"UNCOND", "1110"}
  // {"CS", "0010"},
  // {"CC", "0011"},
  // {"MI", "0100"},
  // {"PL", "0101"},
  // {"VS", "0110"},
  // {"VC", "0111"},
  // {"HI", "1000"},
  // {"LS", "1001"},
};

unordered_map<Token::Type, string> tokToStr = {
  {Token::ADD, "ADD"},
  {Token::SUB, "SUB"},
  {Token::FMUL, "FMUL"},
  {Token::AND, "AND"},
  {Token::ORR, "ORR"},
  {Token::LSL, "LSL"},
  {Token::LSR, "LSR"},
  {Token::LDR, "LDR"},
  {Token::STR, "STR"},
  {Token::B, "B"},
  {Token::ADDS, "ADDS"},
  {Token::SUBS, "SUBS"},
  {Token::FMULS, "FMULS"}
};

unordered_map<Token::Mnemonic, string> CToStr = {
  {Token::EQ, "EQ"},
  {Token::GT, "GT"},
  {Token::LT, "LT"},
  {Token::GE, "GE"},
  {Token::LE, "LE"},
  {Token::NE, "NE"},
};