#include "scanner.hh"
#include "ast.hh"
using namespace std;


class Parser {
private:
  Scanner* scanner;
  Token *current, *previous;
  bool match(Token::Type ttype);
  bool check(Token::Type ttype);
  bool advance();
  bool isAtEnd();
  void parserError(string s);
  // get ast from parser
  LineList* parseProgram();
  Instr* parseLine();
  Instr* parseDpInstr();
  Instr* parseMemoryInstr();
  Instr* parseBranchInstr();
  string parseLabel();
  string parseOpcodeDp();
  string parseOpcodeMemory();
  string parseOpcodeBranch();
  string parseSr2();

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
    Token* temp =current;
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
  return;
};

LineList* Parser::parse() {
  current = scanner->nextToken();
  if (check(Token::ERR)) {
      cout << "Error en scanner - caracter invalido" << endl;
      exit(0);
  }
  LineList* p = parseProgram();
  if (current->type != Token::END) {
    cout << "Esperaba fin-de-input, se encontro " << current << endl;
    delete p;
    p = NULL; exit(0);
  }

  if (current) delete current;
  return p;
}

LineList* Parser::parseProgram() {
  LineList* p = new LineList();
  while (!isAtEnd()) {
    Instr* line = parseLine();
    p->add(line);
  }
  return p;
}

Instr* Parser::parseLine() {
  Instr* line = NULL;
  if (match(Token::LABEL)) {
    string label = parseLabel();
    if (match(Token::TPOINTS)) {
      line = new DeclBranch(label);
    } else {
      parserError("Se esperaba ':'");
    }
  } else if (match(Token::BRANCH)) {
    line = parseBranchInstr();
  } else if (match(Token::LDR) || match(Token::STR)) {
    line = parseMemoryInstr();
  } else if (match(Token::ADD) || match(Token::SUB) || match(Token::FMUL) || match(Token::AND) || 
             match(Token::ORR) || match(Token::LSL) || match(Token::LSR) || match(Token::ADDS) || 
             match(Token::SUBS) || match(Token::FMULS)) {
    line = parseDpInstr();
  }
  return line;
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

// cond             -> EQ | GT | LT | GE | LE | NE
// reg              -> [rR][0-9] | [rR][1][0-5]
// label            -> [a-zA-Z_][a-zA-Z0-9_]*