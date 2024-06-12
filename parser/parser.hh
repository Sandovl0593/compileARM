#include "scanner.hh"
using namespace std;


class Parser {
private:
  Scanner* scanner;
  Token *current, *previous;
  bool match(Token::Type ttype);
  bool check(Token::Type ttype);
  bool advance();
  bool isAtEnd();
  string parseLine();
  string parseDataProcessingExp();
  string parseLoadStoreExp();
  string parseBranchExp();
  string parseDeclLabel();
  string parseOpcodeDp();
  string parseOpcodeDpStat();
  string parseOpcodeDpCond();
  string parseOpcodeDpFlags();
  string parseOpcodeMemory();
  string parseSr2();

public:
  Parser(Scanner* scanner);
  string parse();
};

// GRAMATICA ARMv7
// line             -> dp_exp | memory_exp | branch_exp | decl_label
// dp_exp           -> opcode_dp  reg ',' reg ',' sr2
// memory_exp       -> opcode_memory reg ',' '[' reg (',' sr2)? ']'
// sr2              -> '#' number | reg
// branch_exp       -> (B | B[cond]) label
// decl_label       -> label ':'

// opcode_dp        -> opcode_dpstat | opcode_dpcond | opcode_dpflags
// opcode_dpcond    -> opcode_dpstat[cond]
// opcode_dpstat    -> ADD | SUB | FMUL | AND | ORR | LSL | LSR
// opcode_dpflags   -> ADDS | SUBS | FMULS
// opcode_memory    -> LDR | STR

// cond             -> EQ | GT | LT | GE | LE | NE
// reg              -> [rR][0-9] | [rR][1][0-5]
// label            -> [a-zA-Z_][a-zA-Z0-9_]*