#pragma once

#include <string>
#include <array>
#include <variant>
#include <cstddef>

//#include "parser.hpp"

namespace blang {
	struct Token {
		enum class Type {
			INTEGER_VALUE,
			CHAR_VALUE,
			STRING_VALUE,

			NOT,

			GE,
			GEQ,
			EQ,
			NE,
			LE,
			LEQ,

			MINUS,
			PLUS,
			MOD,
			MUL,
			DIV,

			TERNARY,
			COLON,

			IF,
			ELSE,

			WHILE,

			RETURN,

			ASSIGN,

			COMMA,

			DELIM,

			DOT,

			IDENTIFIER,

			LCURVE,
			RCURVE,

			LPAREN,
			RPAREN,

			LSQUARE,
			RSQUARE,

			AUTO,

			END,

			NONE
		};

		Type type;
		std::variant<std::string, std::array<std::byte, 4>, int> value;
	};

	class Lexer {
		public:
			Lexer(const std::string&);

			Token next();

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
