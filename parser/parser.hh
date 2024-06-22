#include "ast.hh"
#include <unordered_map>
using namespace std;


class Parser {
private:
  Scanner* scanner;
  Token *current, *previous;
  unordered_map<string, int> posBranches;
  unordered_map<string, int> decLabels;
  int linePos;
  bool match(Token::Type ttype);
  bool check(Token::Type ttype);
  bool advance();
  bool isAtEnd();
  void loadBranches();
  void parserError(string s);
  // get ast from parser
  LineList* parseProgram();
  Instr* parseLine();
  Instr* parseDpInstr(bool flags);
  Instr* parseMemoryInstr();
  Instr* parseBranchInstr();
  string parseDeclLabel();

public:
  Parser(Scanner* scanner);
  LineList* parse();
};


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


void Parser::loadBranches() {
  if (check(Token::ERR)) {
    cout << "Error - caracter invalido" << endl; exit(0);
  }
  do {
    if (match(Token::LABEL)) {
      string label = parseDeclLabel();
      decLabels[label] = linePos + 1;
    } else {
      parseLine();
    }
  } while (match(Token::SEMICOLON));
  if (current->type != Token::END) {
    cout << "Esperaba EOinput, se encontro " << current << endl; exit(0);
  }
  // reset parser
  if (current) { delete current; current = NULL; }
  if (previous) { delete previous; previous = NULL; }
}

LineList* Parser::parse() { 
  current = scanner->nextToken();
  loadBranches();
  linePos = 0;
  scanner->reset();
  current = scanner->nextToken();
  LineList* p = parseProgram();
  if (current) delete current;
  return p;
}

LineList* Parser::parseProgram() {
  LineList* p = new LineList();
  p->add(parseLine());
  while (match(Token::SEMICOLON)) {
    linePos++;
    Instr* line = parseLine();
    p->add(line);
  }
  return p;
}

Instr* Parser::parseLine() {
  Instr* line = NULL;
  if (match(Token::B)) {
    line = parseBranchInstr();
  } else if (match(Token::LDR) || match(Token::STR)) {
    line = parseMemoryInstr();
  } else if (match(Token::ADD) || match(Token::SUB) || match(Token::FMUL) || match(Token::AND) || 
             match(Token::ORR) || match(Token::LSL) || match(Token::LSR)) {
    line = parseDpInstr(false);
  } else if (match(Token::ADDS) || match(Token::SUBS) || match(Token::FMULS)) {
    line = parseDpInstr(true);
  } else if (match(Token::LABEL)) {
    parseDeclLabel();
  }
  return line;
}

Instr* Parser::parseDpInstr(bool flags) {
  Token::Type opcode = previous->type;
  Token::Mnemonic condit = previous->mnemonic;
  if (!match(Token::REG)) parserError("Se esperaba rd");
  int reg1 = stoi(previous->lexema);
  if (!match(Token::COMMA)) parserError("Se esperaba ','");
  if (!match(Token::REG)) parserError("Se esperaba rn");
  int reg2 = stoi(previous->lexema);
  if (!match(Token::COMMA)) parserError("Se esperaba ','");
  if (match(Token::DNUM) || match(Token::HEXNUM) || match(Token::REG)) {
    int sr2 = stoi(previous->lexema);
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

Instr* Parser::parseMemoryInstr() {
  Token::Type opcode = previous->type;
  Token::Mnemonic condit = previous->mnemonic;
  if (!match(Token::REG)) parserError("Se esperaba rd");
  int reg1 = stoi(previous->lexema);
  if (!match(Token::COMMA)) parserError("Se esperaba ','");
  if (!match(Token::LCOR)) parserError("Se esperaba '['");
  if (!match(Token::REG)) parserError("Se esperaba rn");
  int reg2 = stoi(previous->lexema);
  if (!match(Token::COMMA)) parserError("Se esperaba ','");
  if (match(Token::DNUM) || match(Token::HEXNUM) || match(Token::REG)) {
    int sr2 = stoi(previous->lexema);
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

Instr* Parser::parseBranchInstr() {
  Token::Mnemonic condit = previous->mnemonic;
  if (!match(Token::LABEL)) parserError("Se esperaba label");
  string label = previous->lexema;
  cout << label << endl;
  if (condit != Token::UNCOND) {
    return new BranchInst(CToStr[condit], label, decLabels[label] - (linePos + 2));
  }
  return new BranchInst("UNCOND", label, decLabels[label] - (linePos + 2));
}

string Parser::parseDeclLabel() {
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
