#pragma once

#include <string>
#include <array>
#include <variant>
#include <cstddef>

#include "parser.hh"

namespace blang {
	struct Token {
		int type;
		std::variant<std::string, int> value;
	};

	std::ostream& operator<<(std::ostream&, const Token&);

	class Lexer {
		public:
			Lexer(const std::string&);

			Token next();

			int lex(Parser::semantic_type*, Parser::location_type*);

		private:
			// buffer state
			const char* p, * pe, * eof;
			// current token
			const char* ts, * te;
			// machine state
			int act, cs, top, stack[1];

			std::string buffer;
	};
}
