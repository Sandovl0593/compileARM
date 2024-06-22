#include <sstream>
#include <fstream>
#include <iostream>

#include "parser.hh"
using namespace std;

int main(int argc, const char* argv[]) {

  bool useparser = true;
  LineList *program; 
  
   if (argc != 2) {
    cout << "Incorrect number of arguments" << endl;
    exit(1);
  }
 
  std::ifstream t(argv[1]);
  std::stringstream buffer;
  buffer << t.rdbuf();
  Scanner scanner(buffer.str());
  Parser parser(&scanner);
  program = parser.parse();  // el parser construye el AST de Program

  cout << "program in ARM: " << endl;
  program->getARMcode();
  cout << endl;
  cout << "program in machine code: " << endl;
  program->getMachineCode();

  delete program;

}
