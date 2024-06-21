#include <sstream>
#include <stdlib.h>
#include <cstring>
#include <bitset>
#include <list>
#include "scanner.hh"

using namespace std;

class Instr {
public:
  virtual string getARMcode() = 0;
  virtual string getMachineCode() = 0;
  virtual ~Instr() {}
};

class LineList {
public:
  list<Instr*> lines;
  LineList() {}
  void add(Instr* line) { lines.push_back(line); }

  string getARMcode() {
    stringstream ss;
    for (Instr* line : lines) {
      ss << line->getARMcode() << endl;
    }
    return ss.str();
  }
  string getMachineCode() {
    stringstream ss;
    for (Instr* line : lines) {
      ss << line->getMachineCode() << endl;
    }
    return ss.str();
  }
  ~LineList() {
    for (Instr* line : lines) {
      delete line;
    }
  }

};

class DpInst : public Instr {
public:
  string cmd;
  string cond;
  int rd;
  int rn;
  int sr2;
  bool flags;
  bool inmediate;
  DpInst(string cmd, string cond, int rd, int rn, int sr2, bool flags, bool inmediate): cmd(cmd), cond(cond), rd(rd), rn(rn), sr2(sr2), flags(flags), inmediate(inmediate) {}
  
  string getARMcode() {
    stringstream ss;
    ss << "  " << cmd << (cond!=""?cond:"") << (flags?"S":"") << " " << rd << ", " << rn << ", " << sr2;
    return ss.str();
  }
  string getMachineCode() {
    stringstream ss;
    ss << conditions[cond];           // cond
    ss << "00";                       // op
    ss << (inmediate)? "1" : "0";     // I
    ss << commands[cmd];              // cmd
    ss << (flags)? "1" : "0";         // S
    ss << bitset<4>(rn).to_string();  // Rn
    ss << bitset<4>(rd).to_string();  // Rd

    if (inmediate) {
      // get 8 bits from sr2 with 4 bits of rotation 
      int sr2_ = sr2;
      int rot = 0;
      while (sr2_ > 255) {
        sr2_ = sr2_ >> 2;
        rot += 1;
      }
      ss << bitset<4>(rot).to_string(); // rotation
      ss << bitset<8>(sr2_).to_string(); // sr2
    } else {
      // register without shift
      ss << "0000"; // no shift
      ss << "000"; // default
      ss << bitset<5>(sr2).to_string(); // rm
    }
    return ss.str();
  }
  ~DpInst() {}
};

class MemoryInst : public Instr {
public:
  string cmd;
  string cond;
  int rd;
  int rn;
  int offset;
  bool inmediate;
  MemoryInst(string cmd, string cond, int rd, int rn, int offset, bool inmediate): cmd(cmd), cond(cond), rd(rd), rn(rn), offset(offset), inmediate(inmediate) {}
  
  string getARMcode() {
    stringstream ss;
    ss << "  "  << cmd << (cond!=""?cond:"") << " " << rd << ", [" << rn << ", " << offset << "]";
    return ss.str();
  }
  string getMachineCode() {
    stringstream ss;
    ss << conditions[cmd];                        // cond
    ss << "01";                                   // op
    ss << (inmediate)? "0" : "1";                 // ~I
    ss << "0";                                    // P
    ss << "0";                                    // U
    ss << (strchr(cmd.c_str(), 'B')? "1" : "0");  // B
    ss << "0";                                    // W
    ss << (strchr(cmd.c_str(), 'L')? "1" : "0");  // L
    ss << bitset<4>(rn).to_string();              // Rn
    ss << bitset<4>(rd).to_string();              // Rd

    if (inmediate) {
      // get 12 bits from offset
      ss << bitset<12>(offset).to_string(); // offset
    } else {
      // register without shift
      ss << "00000";                        // no shift
      ss << "001";                          // default
      ss << bitset<4>(offset).to_string();  // rm
    }
    return ss.str();
  }
  ~MemoryInst() {}
};

class DeclBranch: public Instr {
public:
  string label;
  DeclBranch(string label): label(label) {}
  
  string getARMcode() { return label + ":"; }
  string getMachineCode() { return ""; }
  ~DeclBranch() {}
};

class BranchInst : public Instr {
public:
  string cond;
  string label;
  int count_pos_instr;
  BranchInst(string cond, string label, int count_pos_instr): cond(cond), label(label), count_pos_instr(count_pos_instr) {}
  
  string getARMcode() {
    return "  B " + label;
  }
  string getMachineCode() {
    stringstream ss;
    ss << conditions[cond];               // cond
    ss << "10";                           // op
    ss << "10";                           // 1L (no linked in this case)
    ss << bitset<24>(count_pos_instr).to_string();  // count_pos_instr between BTA and PC+8
    return ss.str();
  }
  ~BranchInst() {}
};