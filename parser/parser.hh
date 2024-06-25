#include "ast.hh"
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
      // ASR, ASREQ, ASRNE, ASRGT, ASRGE, ASRLT, ASRLE,
      // ROR, ROREQ, RORNE, RORGT, RORGE, RORLT, RORLE,
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

class Scanner {
public:
    Scanner(const char* in_s);
    Scanner(string in_s);
    void reset();
    Token* nextToken();
    ~Scanner();
private:
    string input;
    int first, current;
    unordered_map<string, Token::Type> reserved;

    const Token::Mnemonic r_mnemotics[7] = {
      Token::UNCOND, Token::EQ, Token::GT, 
      Token::LT, Token::GE, Token::LE, Token::NE
    };
    const Token::Type r_opers[10] = { 
      Token::ADD, Token::SUB, Token::FMUL, Token::AND, Token::ORR,
      Token::LSL, Token::LSR, Token::LDR, Token::STR, /*Token::ASR, Token::ROR,*/
      Token::B
    };

    char nextChar();
    void rollBack();
    void init_reserved();
    void startLexema();
    string getLexema();
    Token::Type checkReserved(string);
};

class Parser {
private:
  Scanner* scanner;
  Token *current, *previous;
  unordered_map<string, int> decLabels;
  int linePos;
  bool match(Token::Type ttype);
  bool check(Token::Type ttype);
  bool advance();
  bool isAtEnd();
  void loadBranches(ofstream& os);
  void parserError(string s);
  // get ast from parser
  void parseProgram(ofstream& os);
  void parseLine(ofstream& os);
  DpInst* parseDpInstr(bool flags, ofstream& os);
  MemoryInst* parseMemoryInstr(ofstream& os);
  BranchInst* parseBranchInstr(ofstream& os);
  string parseDeclLabel(ofstream& os);
  int parseValue(ofstream& os);

public:
  Parser(Scanner* scanner);
  void parse(ofstream& os);
};