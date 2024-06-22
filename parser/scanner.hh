#include "token.hh"
#include <cstring>
#include <unordered_map>

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
    const Token::Type r_opers[12] = { 
      Token::ADD, Token::SUB, Token::FMUL, Token::AND, Token::ORR,
      Token::LSL, Token::LSR, Token::LDR, Token::STR, Token::ASR, Token::ROR, Token::B
    };

    char nextChar();
    void rollBack();
    void init_reserved();
    void startLexema();
    string getLexema();
    Token::Type checkReserved(string);
};

void Scanner::init_reserved() {
  for (int i=0; i < 84; i++) {
    reserved[Token::token_names[i]] = ordered[i];
  }
  reserved["ADDS"] = Token::ADDS;
  reserved["SUBS"] = Token::SUBS;
  reserved["FMULS"] = Token::FMULS;
}

Scanner::Scanner(string in_s): input(in_s), first(0), current(0) {
  init_reserved();
}

Scanner::Scanner(const char* in_s): input(in_s), first(0), current(0) {
  init_reserved();
}

void Scanner::reset() { current = 0; first = 0; input = ""; }

Token::Type Scanner::checkReserved(string lexema) {
  std::unordered_map<std::string,Token::Type>::const_iterator it = reserved.find(lexema);
  if (it == reserved.end())
    return Token::ERR;
 else
   return it->second;
}

Token* Scanner::nextToken() {
  Token* token;
  char c, c2, c3;
  // consume whitespaces
  c = nextChar();
  while (c == ' ' || c == '\n') c = nextChar();
  if (c == '\0') return new Token(Token::END);

  startLexema();
  if (c == '#') {
    c = nextChar();
    if (isdigit(c)) {
      char cn = nextChar();
      if (c == '0' && cn == 'x') {
        c = nextChar();
        while (isdigit(c)) c = nextChar();
        rollBack();
        token = new Token(Token::HEXNUM, getLexema());
      } else {
        rollBack();
        c = nextChar();
        while (isdigit(c)) c = nextChar();
        rollBack();
        token = new Token(Token::DNUM, getLexema());
      }
    } else 
      token = new Token(Token::ERR, c);
  }

  else if (c == 'R') {

  }
    
  else if (strchr(":[],;", c)) {
    switch(c) {
      case '[': token = new Token(Token::LCOR); break;
      case ']': token = new Token(Token::RCOR); break;
      case ',': token = new Token(Token::COMMA); break;
      case ';': token = new Token(Token::SEMICOLON); break;
      case ':': token = new Token(Token::TPOINTS); break;
      default: cout << "No deberia llegar aca" << endl;
    }
  }
  
  else if (isalpha(c)) {
    c = nextChar();
    while (isalpha(c) || isdigit(c) || c=='_') c = nextChar();
    rollBack();
    string lex = getLexema();
    Token::Type tt = checkReserved(lex);
    for (int i=0; i < 12; ++i) {
      if (tt >= (7*i+1) && tt <= 7*(i+1)) {
        token = new Token(r_opers[i], r_mnemotics[(tt % 7)-1]);
        cout << token << endl;
        return token;
      }
    }
    if (tt == Token::ADDS || tt == Token::SUBS || tt == Token::FMULS)
      token = new Token(tt, Token::UNCOND);
    else
      token = new Token(Token::LABEL, getLexema());
  }
  else {
    token = new Token(Token::ERR, c);
  }
  cout << token << endl;
  return token;
}

Scanner::~Scanner() { }

char Scanner::nextChar() { return input[current++]; }

void Scanner::rollBack() { current--; }

void Scanner::startLexema() { first = current-1; } 

string Scanner::getLexema() { return input.substr(first,current-first); }