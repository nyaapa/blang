#include <iostream>
#include <string>

#include "lexer.hpp"

int main() {
	std::string test = "auto a = b;";
	blang::Lexer lexer(test);
	std::cout << "oh, hi\n";
}
