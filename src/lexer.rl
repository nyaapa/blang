#include "lexer.hpp"
#include <cstdlib>
#include <string>
#include <sstream>
#include <stdlib.h>
#include <memory>

#pragma GCC diagnostic ignored "-Wsign-compare"<Paste>

std::stringstream strbuf;

%%{
	machine Lexer;
	alphtype unsigned long;
	write data;

	number = digit+;

	ws = [ \t\n];

	qqstr := |*
		'\\'["nt\\] => {
			switch ( ts[1] ) {
				case 'n': strbuf << "\n"; break;
				case 't': strbuf << "\t"; break;
				default:  strbuf << std::string(ts + 1, te);
			}
		};

		[^"\\] => {
			strbuf << std::string(ts, te);
		};

		'"' => {
			token.type = Token::Type::STRING_VALUE;
			token.value = std::string(strbuf.str());
			fnext main;
			fbreak;
		};
	*|;

	qstr := |*
		'\\'['\\] => {
			strbuf << std::string(ts + 1, te);
		};

		'\\' | [^'\\] => {
			strbuf << std::string(ts, te);
		};

		"'" => {
			token.type = Token::Type::STRING_VALUE;
			token.value = std::string(strbuf.str());
			fnext main;
			fbreak;
		};
	*|;

	main := |*

		number => {
			token.type = Token::Type::INTEGER_VALUE;
			token.value = atoi(std::string(ts, te).c_str());
			fbreak;
		};

		'if'    => { token.type = Token::Type::IF; fbreak; };
		'else'  => { token.type = Token::Type::ELSE; fbreak; };
		'while'  => { token.type = Token::Type::WHILE; fbreak; };
		'return' => { token.type = Token::Type::RETURN; fbreak; };

		'"' => {
			strbuf.str("");
			fgoto qqstr;
		};


		"'" => {
			strbuf.str("");
			fgoto qstr;
		};


		 ((0x0400..0x04FF) | [a-zA-Z0-9_])+ => {
		  token.value = std::string(ts, te);
		  token.type = Token::Type::IDENTIFIER; fbreak;
		 };

		'{' => { token.type = Token::Type::LCURVE; fbreak; };
		'}' => { token.type = Token::Type::RCURVE; fbreak; };

		'(' => { token.type = Token::Type::LPAREN; fbreak; };
		')' => { token.type = Token::Type::RPAREN; fbreak; };

		'+' => { token.type = Token::Type::PLUS; fbreak; };
		'-' => { token.type = Token::Type::MINUS; fbreak; };

		'*' => { token.type = Token::Type::MUL; fbreak; };
		'/' => { token.type = Token::Type::DIV; fbreak; };
		'%' => { token.type = Token::Type::MOD; fbreak; };

		'!' => { token.type = Token::Type::NOT; fbreak; };
		'<' => { token.type = Token::Type::LE; fbreak; };
		'<=' => { token.type = Token::Type::LEQ; fbreak; };
		'==' => { token.type = Token::Type::EQ; fbreak; };
		'!=' => { token.type = Token::Type::NE; fbreak; };
		'>=' => { token.type = Token::Type::GEQ; fbreak; };
		'>' => { token.type = Token::Type::GE; fbreak; };

		':' => { token.type = Token::Type::COLON; fbreak; };
		'?' => { token.type = Token::Type::TERNARY; fbreak; };

		'[' => { token.type = Token::Type::LSQUARE; fbreak; };
		']' => { token.type = Token::Type::RSQUARE; fbreak; };

		';'+ => { token.type = Token::Type::DELIM; fbreak; };
		',' => { token.type = Token::Type::COMMA; fbreak; };
		'.' => { token.type = Token::Type::DOT; fbreak; };

		'=' => { token.type = Token::Type::ASSIGN; fbreak; };

		'auto' => { token.type = Token::Type::AUTO; fbreak; };

		ws;

		'//' [^\n]+;

	*|;
}%%

blang::Lexer::Lexer(const std::string& input) : buffer(input) {
    %%write init;

    // set up the buffer here
    p = buffer.c_str();
    pe = p + buffer.size();
    eof = pe;
}

blang::Token blang::Lexer::next() {
    Token token;

    token.type = Token::Type::NONE;

    do {
        if (cs >= Lexer_first_final) {
            token.type = Token::Type::NONE;
        }

        %%write exec;
        
        if (cs == Lexer_error) {
            token.type = Token::Type::NONE;
            return token;
        }
    } while (token.type == Token::Type::NONE);

    return token;
}
