#include <iostream>
#include <string>
#include <iterator>
#include <variant>
#include <iomanip>
#include <memory>

#include "../lib/cxxopts/cxxopts.hpp"

#include "lexer.hpp"
#include "parser.hh"
#include "overloaded.hpp"

#include "fun.hpp"

int main(int argc, char** argv) {
    cxxopts::Options options("blangc", " - b language compiler");

	bool lex;
	bool parse;
	bool compile;

    options
      .allow_unrecognised_options()
      .add_options()
      ("l,lex", "lex only", cxxopts::value<bool>(lex))
      ("p,parse", "lex and parse", cxxopts::value<bool>(parse))
      ("c,compile", "lex, parse & compile", cxxopts::value<bool>(compile))
	  ("help", "Print help")
	  ;

	auto result = options.parse(argc, argv);

    if (result.count("help")) {
		std::cout << options.help({""}) << std::endl;
		exit(0);
    }


	if (lex + parse + compile != 1) {
		std::cerr << "should select at lease one option\n";
		std::cout << options.help({""}) << std::endl;
		exit(0);
	}

	std::istreambuf_iterator<char> begin{std::cin}, end;
	blang::Lexer lexer{std::string(begin, end)};
	if (lex) {
		for (auto token = lexer.next(); token.type != blang::Parser::token_type::T_END; token = lexer.next()) {
			std::cout << token;
		}
	} else {
		std::shared_ptr<blang::fun> result;
		blang::Parser parser{lexer, result};

		if ( auto err = parser.parse() )
			throw std::runtime_error("Error while parsing: " + std::to_string(err));

		if (parse) {
			// std::visit(overloaded {
			// 	[](const std::string& arg){std::cout << std::quoted(arg);},
			// 	[](int arg){std::cout << std::to_string(arg);},
			// }, result);
			std::cout << "\n";
		} else {
			std::cout << "section .text\n";
    		std::cout << "\tglobal _start\n";
			std::cout << "_start:\n";
			result->exprs.front()->cgen();
			std::cout << "\tmov rax, 60\n";
			std::cout << "\tmov rdi, 0\n";
			std::cout << "\tsyscall\n";
		}
	}
}
