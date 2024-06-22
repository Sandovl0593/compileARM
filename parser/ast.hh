#include <sstream>
#include <stdlib.h>
#include <cstring>
#include <bitset>
#include <list>
#include "scanner.hh"

using namespace std;

class Instr {
public:
  void getARMcode() {}
  void getMachineCode() {}
  ~Instr() {}
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
  
  void getARMcode() {
    cout << "  " << cmd << (cond!=""?cond:"") << (flags?"S":"");
    cout << " R" << rd << ", R" << rn << ", " << (inmediate?"#":"R") << sr2;
  }
  void getMachineCode() {
    cout << conditions[cond];           // cond
    cout << "00";                       // op
    cout << (inmediate)? "1" : "0";     // I
    cout << commands[cmd];              // cmd
    cout << (flags)? "1" : "0";         // S
    cout << bitset<4>(rn).to_string();  // Rn
    cout << bitset<4>(rd).to_string();  // Rd

    if (inmediate) {
      // get 8 bits from sr2 with 4 bits of rotation 
      int sr2_ = sr2;
      int rot = 0;
      while (sr2_ > 255) {
        sr2_ = sr2_ >> 2;
        rot += 1;
      }
      cout << bitset<4>(rot).to_string(); // rotation
      cout << bitset<8>(sr2_).to_string(); // sr2
    } else {
      // register without shift
      cout << "0000"; // no shift
      cout << "000"; // default
      cout << bitset<5>(sr2).to_string(); // rm
    }
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
  
  void getARMcode() {
    cout << "  "  << cmd << (cond!=""?cond:"");
    cout << " R" << rd << ", [R" << rn << ", " << (inmediate?"#":"R") << offset << "]";
  }
  void getMachineCode() {
    cout << conditions[cmd];                        // cond
    cout << "01";                                   // op
    cout << (inmediate)? "0" : "1";                 // ~I
    cout << "0";                                    // P
    cout << "0";                                    // U
    cout << (strchr(cmd.c_str(), 'B')? "1" : "0");  // B
    cout << "0";                                    // W
    cout << (strchr(cmd.c_str(), 'L')? "1" : "0");  // L
    cout << bitset<4>(rn).to_string();              // Rn
    cout << bitset<4>(rd).to_string();              // Rd

    if (inmediate) {
      // get 12 bits from offset
      cout << bitset<12>(offset).to_string(); // offset
    } else {
      // register without shift
      cout << "00000";                        // no shift
      cout << "001";                          // default
      cout << bitset<4>(offset).to_string();  // rm
    }
  }
  ~MemoryInst() {}
};

class DeclBranch: public Instr {
public:
  string label;
  DeclBranch(string label): label(label) {}
  
  void getARMcode() { cout << label + ":"; }
  void getMachineCode() { }
  ~DeclBranch() {}
};

class BranchInst : public Instr {
public:
  string cond;
  string label;
  int count_pos_instr;
  BranchInst(string cond, string label, int count_pos_instr): cond(cond), label(label), count_pos_instr(count_pos_instr) {}
  
  void getARMcode() {
    cout << "  B " + label;
  }
  void getMachineCode() {
    cout << conditions[cond];               // cond
    cout << "10";                           // op
    cout << "10";                           // 1L (no linked in this case)
    cout << bitset<24>(count_pos_instr).to_string();  // count_pos_instr between BTA and PC+8
  }
  ~BranchInst() {}
};

class LineList {
public:
  list<Instr*> lines;
  LineList() {}
  void add(Instr* line) { lines.push_back(line); }

  void getARMcode() {
    for (auto it = lines.begin(); it != lines.end(); ++it) {
      (*it)->getARMcode();
      cout << endl;
    }
  }
  void getMachineCode() {
    for (auto it = lines.begin(); it != lines.end(); ++it) {
      (*it)->getMachineCode();
    }
  }
  ~LineList() {
    // for (Instr* line : lines) {
    //   delete line;
    // }
  }
};