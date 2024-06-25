#include "ast.hh"
#include <bitset>

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

// Definiciones de métodos de la clase DpInst
DpInst::DpInst(string cmd, string cond, int rd, int rn, int sr2, bool flags, bool inmediate)
  : cmd(cmd), cond(cond), rd(rd), rn(rn), sr2(sr2), flags(flags), inmediate(inmediate) {
    // cout << this->cmd << " " << this->cond << " " << this->rd << " " << this->rn << " " << this->sr2 << " " << this->flags << " " << this->inmediate << endl;
  }

void DpInst::getARMcode() {
  cout << "  " << cmd << (cond!="UNCOND"?cond:"") << (flags?"S":"");
  cout << " R" << rd << ", R" << rn << ", " << (inmediate?"#":"R") << sr2 << endl;
}

void DpInst::getMachineCode(ofstream& os) {
  os << conditions[cond];           // cond
  os << "00";                       // op
  os << (inmediate)? "1" : "0";     // I
  os << commands[cmd];              // cmd
  os << (flags)? "1" : "0";         // S
  os << bitset<4>(rn).to_string();  // Rn
  os << bitset<4>(rd).to_string();  // Rd

  if (inmediate) {
    // get 8 bits from sr2 with 4 bits of rotation 
    int sr2_ = sr2;
    int rot = 0;
    while (sr2_ > 255) {
      sr2_ = sr2_ >> 2;
      rot += 1;
    }
    os << bitset<4>(rot).to_string(); // rotation
    os << bitset<8>(sr2_).to_string(); // sr2
  } else {
    // register without shift
    os << "0000"; // no shift
    os << "000"; // default
    os << bitset<5>(sr2).to_string(); // rm
  }
  os << endl;
}

DpInst::~DpInst() {}


// Definiciones de métodos de la clase MemoryInst
MemoryInst::MemoryInst(string cmd, string cond, int rd, int rn, int offset, bool inmediate)
  : cmd(cmd), cond(cond), rd(rd), rn(rn), offset(offset), inmediate(inmediate) {}

void MemoryInst::getARMcode() {
  cout << "  "  << cmd << (cond!="UNCOND"?cond:"");
  cout << " R" << rd << ", [R" << rn << ", " << (inmediate?"#":"R") << offset << "]" << endl;
}

void MemoryInst::getMachineCode(ofstream& os) {
  os << conditions[cmd];                        // cond
  os << "01";                                   // op
  os << (inmediate)? "0" : "1";                 // ~I
  os << "0";                                    // P
  os << "0";                                    // U
  os << (strchr(cmd.c_str(), 'B')? "1" : "0");  // B
  os << "0";                                    // W
  os << (strchr(cmd.c_str(), 'L')? "1" : "0");  // L
  os << bitset<4>(rn).to_string();              // Rn
  os << bitset<4>(rd).to_string();              // Rd

  if (inmediate) {
    // get 12 bits from offset
    os << bitset<12>(offset).to_string(); // offset
  } else {
    // register without shift
    os << "00000";                        // no shift
    os << "001";                          // default
    os << bitset<4>(offset).to_string();  // rm
  }
  os << endl;
}

MemoryInst::~MemoryInst() {}


// Definiciones de métodos de la clase DeclBranch
DeclBranch::DeclBranch(string label) : label(label) {}

void DeclBranch::getARMcode() { cout << label + ":" << endl; }
void DeclBranch::getMachineCode(ofstream& os) {}

DeclBranch::~DeclBranch() {}


// Definiciones de métodos de la clase BranchInst
BranchInst::BranchInst(string cond, string label, int count_pos_instr)
  : cond(cond), label(label), count_pos_instr(count_pos_instr) {}

void BranchInst::getARMcode() {
  cout << "  B " + label << endl;
}

void BranchInst::getMachineCode(ofstream& os) {
  os << conditions[cond];               // cond
  os << "10";                           // op
  os << "10";                           // 1L (no linked in this case)
  os << bitset<24>(count_pos_instr).to_string() << endl;  // count_pos_instr between BTA and PC+8
}

BranchInst::~BranchInst() {}


// Definiciones de métodos de la clase LineList
// LineList::LineList() {}

// void LineList::add(Instr* line) { lines.push_back(line); }

// void LineList::getARMcode() {
//   for (auto it = lines.begin(); it != lines.end(); ++it) {
//     (*it)->getARMcode();
//     cout << endl;
//   }
// }

// void LineList::getMachineCode(ofstream& os) {
//   for (auto it = lines.begin(); it != lines.end(); ++it) {
//     (*it)->getMachineCode(os);
//   }
// }

// LineList::~LineList() {
//   for (auto it = lines.begin(); it != lines.end(); ++it) {
//     delete *it;
//   }
// }