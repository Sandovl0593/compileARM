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
    unordered_map<string, Token::Mnemonic> r_mnemotics;
    char nextChar();
    void rollBack();
    void init_reserved();
    void startLexema();
    string getLexema();
    Token::Type checkReserved(string);
    Token::Mnemonic checkRMnemonic(string);
};

void Scanner::init_reserved() {
  reserved["ADD"] = Token::ADD;
  reserved["SUB"] = Token::SUB;
  reserved["FMUL"] = Token::FMUL;
  reserved["LDR"] = Token::LDR;
  reserved["STR"] = Token::STR;
  reserved["LSL"] = Token::LSL;
  reserved["LSR"] = Token::LSR;
  reserved["AND"] = Token::AND;
  reserved["ORR"] = Token::ORR;

  r_mnemotics["EQ"] = Token::EQ;
  r_mnemotics["GT"] = Token::GT;
  r_mnemotics["LT"] = Token::LT;
  r_mnemotics["GE"] = Token::GE;
  r_mnemotics["LE"] = Token::LE;
  r_mnemotics["NE"] = Token::NE;
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

Token::Mnemonic Scanner::checkRMnemonic(string lexema) {
  std::unordered_map<std::string,Token::Mnemonic>::const_iterator it = r_mnemotics.find(lexema);
  if (it == r_mnemotics.end())
    return Token::ERRMNE;
  else
    return it->second;
}

Token* Scanner::nextToken() {
  Token* token;
  char c, c2, c3;
  // consume whitespaces
  c = nextChar();
  while (c == ' ') c = nextChar();
  if (c == '\0') return new Token(Token::END);

  startLexema();
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
  } 
  
  else if (strchr(":[],#", c)) {
    switch(c) {
      case '[': token = new Token(Token::LCOR); break;
      case ']': token = new Token(Token::RCOR); break;
      case ',': token = new Token(Token::COMMA); break;
      case '#': token = new Token(Token::NUMERAL); break;
      case ':': token = new Token(Token::TPOINTS); break;
      default: cout << "No deberia llegar aca" << endl;
    }
  }
  
  else if (isalpha(c)) {
    if (c == 'B') {
      c2 = nextChar();
      if (c2 == ' ') {
        rollBack(); rollBack();
        token = new Token(Token::BRANCH);
      } else {
        c3 = nextChar();
        string mnemote = "";
        mnemote += c2; mnemote += c3;
        Token::Mnemonic mne = checkRMnemonic(mnemote);
        if (mne != Token::ERRMNE) {
          token = new Token(Token::BRANCH, mne);
        } else {
          token = new Token(Token::ERR, mnemote);
        } 
      }
    }
    else if (c == 'r' || c == 'R') {
      c = nextChar();
      if (isdigit(c)) {
        if (c == '1') {
          c = nextChar();
          if (isdigit(c)) {
            if (c >= '0' && c <= '5')
              token = new Token(Token::REG, getLexema());
            else 
              token = new Token(Token::ERR, c);
          } else if (c == ' ') {
            rollBack(); rollBack();
            token = new Token(Token::REG, getLexema());
          } else
            token = new Token(Token::ERR, c);
        } else
          token = new Token(Token::REG, getLexema());
      } 
      else 
        token = new Token(Token::ERR, c);
    } 
    else {
      c = nextChar();
      while (isalpha(c) || isdigit(c) || c=='_') c = nextChar();
      rollBack();
      string lex = getLexema();
      int size_lex = lex.size();
      // dividir lex en dos partes para ver si es un mnemonico
      string cmd = lex.substr(lex.size()-1, 1);
      Token::Type cmd_t = checkReserved(cmd);
      if (size_lex > 4) {
        // si tiene mnemonico
        string mnem = lex.substr(0, size_lex-2);
        Token::Mnemonic mne_t = checkRMnemonic(lex);
        if (mne_t != Token::ERRMNE) {
          token = new Token(cmd_t, mne_t);
        } else {
          token = new Token(Token::ERR, lex);
        }
      } else {
        // si no tiene mnemonico
        if (cmd_t != Token::ERR)
          token = new Token(cmd_t);
        else
          token = new Token(Token::LABEL, lex);
      }
    }
  }
  else {
    token = new Token(Token::ERR, c);
  }
  return token;
}

Scanner::~Scanner() { }

char Scanner::nextChar() { return input[current++]; }

void Scanner::rollBack() { current--; }

void Scanner::startLexema() { first = current-1; } 

string Scanner::getLexema() { return input.substr(first,current-first); }