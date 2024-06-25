#include "parser.hh"

using namespace std;

// ---- token ---

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
  // "ASR", "ASREQ", "ASRNE", "ASRGT", "ASRGE", "ASRLT", "ASRLE",
  // "ROR", "ROREQ", "RORNE", "RORGT", "RORGE", "RORLT", "RORLE",
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




// ---- scanner ---

void Scanner::init_reserved() {
  reserved["ADD"] = Token::ADD; reserved["ADDEQ"] = Token::ADDEQ; reserved["ADDNE"] = Token::ADDNE; reserved["ADDGT"] = Token::ADDGT; reserved["ADDGE"] = Token::ADDGE; reserved["ADDLT"] = Token::ADDLT; reserved["ADDLE"] = Token::ADDLE;
  reserved["SUB"] = Token::SUB; reserved["SUBEQ"] = Token::SUBEQ; reserved["SUBNE"] = Token::SUBNE; reserved["SUBGT"] = Token::SUBGT; reserved["SUBGE"] = Token::SUBGE; reserved["SUBLT"] = Token::SUBLT; reserved["SUBLE"] = Token::SUBLE;
  reserved["AND"] = Token::AND; reserved["ANDEQ"] = Token::ANDEQ; reserved["ANDNE"] = Token::ANDNE; reserved["ANDGT"] = Token::ANDGT; reserved["ANDGE"] = Token::ANDGE; reserved["ANDLT"] = Token::ANDLT; reserved["ANDLE"] = Token::ANDLE;
  reserved["ORR"] = Token::ORR; reserved["ORREQ"] = Token::ORREQ; reserved["ORRNE"] = Token::ORRNE; reserved["ORRGT"] = Token::ORRGT; reserved["ORRGE"] = Token::ORRGE; reserved["ORRLT"] = Token::ORRLT; reserved["ORRLE"] = Token::ORRLE;
  reserved["LSL"] = Token::LSL; reserved["LSLEQ"] = Token::LSLEQ; reserved["LSLNE"] = Token::LSLNE; reserved["LSLGT"] = Token::LSLGT; reserved["LSLGE"] = Token::LSLGE; reserved["LSLLT"] = Token::LSLLT; reserved["LSLLE"] = Token::LSLLE;
  reserved["LSR"] = Token::LSR; reserved["LSREQ"] = Token::LSREQ; reserved["LSRNE"] = Token::LSRNE; reserved["LSRGT"] = Token::LSRGT; reserved["LSRGE"] = Token::LSRGE; reserved["LSRLT"] = Token::LSRLT; reserved["LSRLE"] = Token::LSRLE;
  reserved["LDR"] = Token::LDR; reserved["LDREQ"] = Token::LDREQ; reserved["LDRNE"] = Token::LDRNE; reserved["LDRGT"] = Token::LDRGT; reserved["LDRGE"] = Token::LDRGE; reserved["LDRLT"] = Token::LDRLT; reserved["LDRLE"] = Token::LDRLE;
  reserved["STR"] = Token::STR; reserved["STREQ"] = Token::STREQ; reserved["STRNE"] = Token::STRNE; reserved["STRGT"] = Token::STRGT; reserved["STRGE"] = Token::STRGE; reserved["STRLT"] = Token::STRLT; reserved["STRLE"] = Token::STRLE;
  reserved["FMUL"] = Token::FMUL; reserved["FMULEQ"] = Token::FMULEQ; reserved["FMULNE"] = Token::FMULNE; reserved["FMULGT"] = Token::FMULGT; reserved["FMULGE"] = Token::FMULGE; reserved["FMULLT"] = Token::FMULLT; reserved["FMULLE"] = Token::FMULLE;
  reserved["B"] = Token::B; reserved["BEQ"] = Token::BEQ; reserved["BNE"] = Token::BNE; reserved["BGT"] = Token::BGT; reserved["BGE"] = Token::BGE; reserved["BLT"] = Token::BLT; reserved["BLE"] = Token::BLE;
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
  char c, c2;
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

  else if (c == 'R' || c == 'r') {
    c = nextChar();
    if (isdigit(c)) {
      if (c - '0' == 1) {
        c2 = nextChar();
        if (isdigit(c2)) {
          cout << "digit " << c2  << endl;
          if (c2 - '0' <= 5) {
            rollBack();
            token = new Token(Token::REG, getLexema());
          } else {
            token = new Token(Token::ERR, c2);
          }
        } else {
          rollBack();
          token = new Token(Token::REG, getLexema());
        }
      } else {
        token = new Token(Token::REG, getLexema());
      }
    } else {
      token = new Token(Token::ERR, c);
    }
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
    for (int i=0; i < 10; ++i) {
      if (tt >= (7*i+1) && tt <= 7*(i+1)) {
        token = new Token(r_opers[i], r_mnemotics[(tt % 7)-1]);
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
  return token;
}

Scanner::~Scanner() { }

char Scanner::nextChar() { return input[current++]; }

void Scanner::rollBack() { current--; }

void Scanner::startLexema() { first = current-1; } 

string Scanner::getLexema() { return input.substr(first,current-first); }





// ---- parser ---

bool Parser::match(Token::Type ttype) {
  if (check(ttype)) {
    advance();
    return true;
  }
  return false;
}

bool Parser::check(Token::Type ttype) {
  if (isAtEnd()) return false;
  return current->type == ttype;
}


bool Parser::advance() {
  if (!isAtEnd()) {
    Token* temp = current;
    if (previous) delete previous;
    current = scanner->nextToken();
    previous = temp;
    if (check(Token::ERR)) {
      cout << "Parse error, unrecognised character: " << current->lexema << endl;
      exit(0);
    }
    return true;
  }
  return false;
} 

bool Parser::isAtEnd() {
  return (current->type == Token::END);
}

void Parser::parserError(string s) {
  cout << "Parsing error: " << s << endl;
  exit(0);
}

Parser::Parser(Scanner* sc):scanner(sc) {
  previous = current = NULL;
  linePos = 0;
  return;
};


void Parser::loadBranches(ofstream& os) {
  if (check(Token::ERR)) {
    cout << "Error - caracter invalido" << endl; exit(0);
  }
  do {
    if (match(Token::LABEL)) {
      string label = parseDeclLabel(os);
      decLabels[label] = ++linePos;
    } else {
      parseLine(os);
    }
  } while (match(Token::SEMICOLON));
  if (current->type != Token::END) {
    cout << "Esperaba EOinput, se encontro " << current << endl; exit(0);
  }
  // reset parser
  if (current) { delete current; current = NULL; }
  if (previous) { delete previous; previous = NULL; }
}

void Parser::parse(ofstream& os) { 
  cout << "MAIN:" << endl;
  current = scanner->nextToken();
  loadBranches(os);
  linePos = 0;
  scanner->reset();
  current = scanner->nextToken();
  parseProgram(os);
  if (current) delete current;
}

void Parser::parseProgram(ofstream& os) {
  parseLine(os);
  while (match(Token::SEMICOLON)) {
    linePos++;
    parseLine(os);
  }
}

void Parser::parseLine(ofstream& os) {
  Instr* line = NULL;
  if (match(Token::B)) {
    line = parseBranchInstr(os);
  } else if (match(Token::LDR) || match(Token::STR)) {
    line = parseMemoryInstr(os);
  } else if (match(Token::ADD) || match(Token::SUB) || match(Token::FMUL) || match(Token::AND) || 
             match(Token::ORR) || match(Token::LSL) || match(Token::LSR)) {
    line = parseDpInstr(false, os);
  } else if (match(Token::ADDS) || match(Token::SUBS) || match(Token::FMULS)) {
    line = parseDpInstr(true, os);
  } else if (match(Token::LABEL)) {
    parseDeclLabel(os);
  }
  line->getARMcode();
  line->getMachineCode(os);
}

int Parser::parseValue(ofstream& os) {
  int size = previous->lexema.size() - 1;
  string extract = previous->lexema.substr(1, size);
  Token::Type type = previous->type;
  if (type == Token::HEXNUM)
    return stoi(extract.substr(2, size-2), 0, 16);
  return stoi(extract);
}

DpInst* Parser::parseDpInstr(bool flags, ofstream& os) {
  Token::Type opcode = previous->type;
  Token::Mnemonic condit = previous->mnemonic;
  if (!match(Token::REG)) parserError("Se esperaba rd");
  int reg1 = parseValue(os);
  if (!match(Token::COMMA)) parserError("Se esperaba ','");
  if (!match(Token::REG)) parserError("Se esperaba rn");
  int reg2 = parseValue(os);
  if (!match(Token::COMMA)) parserError("Se esperaba ','");
  if (match(Token::DNUM) || match(Token::HEXNUM) || match(Token::REG)) {
    int sr2 = parseValue(os);
    bool inmed = previous->type!=Token::REG;
    if (condit != Token::UNCOND) {
      return new DpInst(tokToStr[opcode], CToStr[condit], reg1, reg2, sr2, flags, inmed);
    } else {
      return new DpInst(tokToStr[opcode], "UNCOND", reg1, reg2, sr2, flags, inmed);
    }
  }
  parserError("Se esperaba numero");
  return NULL;
}

MemoryInst* Parser::parseMemoryInstr(ofstream& os) {
  Token::Type opcode = previous->type;
  Token::Mnemonic condit = previous->mnemonic;
  if (!match(Token::REG)) parserError("Se esperaba rd");
  int reg1 = parseValue(os);
  if (!match(Token::COMMA)) parserError("Se esperaba ','");
  if (!match(Token::LCOR)) parserError("Se esperaba '['");
  if (!match(Token::REG)) parserError("Se esperaba rn");
  int reg2 = parseValue(os);
  if (!match(Token::COMMA)) parserError("Se esperaba ','");
  if (match(Token::DNUM) || match(Token::HEXNUM) || match(Token::REG)) {
    int sr2 = parseValue(os);
    bool inmed = previous->type!=Token::REG;
    if (condit != Token::UNCOND) {
      return new MemoryInst(tokToStr[opcode], CToStr[condit], reg1, reg2, sr2, inmed);
    } else {
      return new MemoryInst(tokToStr[opcode], "UNCOND", reg1, reg2, sr2, inmed);
    }
  }
  parserError("Se esperaba ']'");
  return NULL;
}

BranchInst* Parser::parseBranchInstr(ofstream& os) {
  Token::Mnemonic condit = previous->mnemonic;
  if (!match(Token::LABEL)) parserError("Se esperaba label");
  string label = previous->lexema;
  if (condit != Token::UNCOND) {
    return new BranchInst(CToStr[condit], label, decLabels[label] - (linePos + 2));
  }
  return new BranchInst("UNCOND", label, decLabels[label] - (linePos + 2));
}

string Parser::parseDeclLabel(ofstream& os) {
  string label = previous->lexema;
  if (!match(Token::TPOINTS)) parserError("Se esperaba ':'");
  linePos--; // no considerar como linea
  return label;
}

 
// GRAMATICA ARMv7
// program          -> (line)*
// line             -> (opcode_dp dp_Instr | opcode_memory memory_Instr | (B | B[cond]) branch_Instr | label ':')?
// dp_Instr           -> opcode_dp  reg ',' reg ',' sr2
// memory_Instr       -> opcode_memory reg ',' '[' reg (',' sr2)? ']'
// sr2              -> '#' number | reg
// branch_Instr       -> (B | B[cond]) label
// decl_label       -> label ':'

// opcode_dp        -> opcode_dpstat | opcode_dpcond | opcode_dpflags
// opcode_dpcond    -> opcode_dpstat[cond]
// opcode_dpstat    -> ADD | SUB | FMUL | AND | ORR | LSL | LSR
// opcode_dpflags   -> ADDS | SUBS | FMULS
// opcode_memory    -> LDR | STR
