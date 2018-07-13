#include <iostream>
#include <string>
#include <iterator>

#include "lexer.hpp"

int main() {
	std::istreambuf_iterator<char> begin(std::cin), end;
	blang::Lexer lexer(std::string(begin, end));
	for (auto token = lexer.next(); token.type != blang::Parser::token_type::T_END; token = lexer.next()) {
		std::cout << token;
	}
}
