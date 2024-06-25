
#include "parser.hh"
using namespace std;

int main(int argc, const char* argv[]) {
  
  if (argc != 2) {
    cout << "Incorrect number of arguments" << endl;
    exit(1);
  }
 
  string file = argv[1];
  std::ifstream t("parser/" + file + ".asm");
  std::ofstream out("src/" + file + ".mem");
  std::stringstream buffer;
  buffer << t.rdbuf();
  Scanner scanner(buffer.str());
  Parser parser(&scanner);

  cout << "program in ARM: " << endl;
  parser.parse(out);  // el parser construye el AST de Program
  cout << "Machine code generated in " << file << ".mem" << endl;
  out.close();

}
