#pragma once

#include <string>
#include <array>
#include <variant>
#include <cstddef>

//#include "parser.hpp"

namespace blang {
	struct Token {
		enum class Type : int {
			INTEGER_VALUE,
			CHAR_VALUE,
			STRING_VALUE,

			NOT,

			GE,
			GT,
			EQ,
			NE,
			LE,
			LT,

			INC,
			DEC,
			NEG,

			// because it's 'indirection' and 'mul' at the same time
			STAR,
			// because it's 'and' and 'address' at the same time
			AMPERSAND,

			MINUS,
			PLUS,
			MOD,
			DIV,
			SHL,
			SHR,

			AND,
			XOR,
			OR,

			TERNARY,
			COLON,

			IF,
			ELSE,

			WHILE,

			RETURN,

			ASSIGN,
			ASSIGNMINUS,
			ASSIGNPLUS,
			ASSIGNMOD,
			ASSIGNDIV,
			ASSIGNSHL,
			ASSIGNSHR,
			ASSIGNXOR,
			ASSIGNOR,
			ASSIGNAND,
			ASSIGNMUL,

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

			NONE,

			ERROR
		};

		Type type;
		std::variant<std::string, int> value;
	};

	std::ostream& operator<<(std::ostream&, const Token&);

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
