#include <iostream>
#include <string>
#include <iterator>

#include "lexer.hpp"
#include "parser.hh"
#include "overloaded.hpp"

int main() {
	std::istreambuf_iterator<char> begin{std::cin}, end;
	blang::Lexer lexer{std::string(begin, end)};
	// for (auto token = lexer.next(); token.type != blang::Parser::token_type::T_END; token = lexer.next()) {
	// 	std::cout << token;
	// }

	int result;
	blang::Parser parser{lexer, result};
	if ( auto err = parser.parse() )
		throw std::runtime_error("Error while parsing: " + std::to_string(err));
	std::cout << result << "\n";
}
