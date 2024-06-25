#include <sstream>
#include <stdlib.h>
#include <cstring>
#include <unordered_map>
#include <fstream>
#include <iostream>

using namespace std;

class Instr {
public:
  virtual void getARMcode() = 0;
  virtual void getMachineCode(ofstream& os) = 0;
  // virtual ~Instr() = 0;
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
  DpInst(string cmd, string cond, int rd, int rn, int sr2, bool flags, bool inmediate);
  
  void getARMcode();
  void getMachineCode(ofstream& os);
  ~DpInst();
};

class MemoryInst : public Instr {
public:
  string cmd;
  string cond;
  int rd;
  int rn;
  int offset;
  bool inmediate;
  MemoryInst(string cmd, string cond, int rd, int rn, int offset, bool inmediate);
  
  void getARMcode();
  void getMachineCode(ofstream& os);
  ~MemoryInst();
};

class DeclBranch: public Instr {
public:
  string label;
  DeclBranch(string label);
  
  void getARMcode();
  void getMachineCode(ofstream& os);
  ~DeclBranch();
};

class BranchInst : public Instr {
public:
  string cond;
  string label;
  int count_pos_instr;
  BranchInst(string cond, string label, int count_pos_instr);
  
  void getARMcode();
  void getMachineCode(ofstream& os);
  ~BranchInst();
};

// class LineList {
// public:
//   list<Instr*> lines;
//   LineList();
//   void add(Instr* line);

//   void getARMcode();
//   void getMachineCode(ofstream& os);
//   ~LineList();
// };