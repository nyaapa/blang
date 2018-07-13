#include "lexer.hpp"
#include <cstdlib>
#include <string>
#include <sstream>
#include <iomanip>
#include <stdlib.h>
#include <memory>

#include "parser.hh"
#include "overloaded.hpp"

#pragma GCC diagnostic ignored "-Wsign-compare"<Paste>

std::stringstream strbuf;

%%{
	machine Lexer;
	alphtype unsigned long;
	write data;

	escapeSequences = '*'[0e()t*'"n];

	action checkStrLiteral {
		if (te == eof) {	
			std::string val{strbuf.str()};
			token.type = blang::Parser::token_type::T_ERROR;
			token.value = "Endless string literal: " + val.substr(0, 3) + (val.length() > 3 ? "..." : "");
			fnext main;
			fbreak;
		}
	}

	action flattenEscapes {
		switch ( ts[1] ) {
			case '0': strbuf << '\0'; break;
			case '(': strbuf <<  '{'; break;
			case ')': strbuf <<  '}'; break;
			case 't': strbuf << '\t'; break;
			case 'n': strbuf << '\n'; break;
			case 'e': strbuf << (char) 4; break;
			
			default:  strbuf << (char) ts[1];
		}

		if (te == eof) {	
			std::string val{strbuf.str()};
			token.type = blang::Parser::token_type::T_ERROR;
			token.value = "Endless string literal: " + val.substr(0, 3) + (val.length() > 3 ? "..." : "");
			fnext main;
		}
	}

	number = digit+;

	ws = [ \t\n];

	qqstr := |*
		escapeSequences => flattenEscapes;

		[^"*] => {
			strbuf << std::string(ts, te);

			if (te == eof) {	
				std::string val{strbuf.str()};
				token.type = blang::Parser::token_type::T_ERROR;
				token.value = "Endless string literal: " + val.substr(0, 3) + (val.length() > 3 ? "..." : "");
				fnext main;
			}
		};

		'"' => {
			token.type = blang::Parser::token_type::T_STRING_VALUE;
			token.value = std::string(strbuf.str());
			fnext main;
		};
	*|;

	qstr := |*
		escapeSequences => flattenEscapes;

		[^'*] => {
			strbuf << std::string(ts, te);

			if (te == eof) {	
				std::string val{strbuf.str()};
				token.type = blang::Parser::token_type::T_ERROR;
				token.value = "Endless string literal: " + val.substr(0, 3) + (val.length() > 3 ? "..." : "");
				fnext main;
			}
		};

		"'" => {
			std::string character{strbuf.str()};
			if (character.length() <= 4) {
				token.type = blang::Parser::token_type::T_CHAR_VALUE;
				token.value = std::move(character);
			} else {
				token.type = blang::Parser::token_type::T_ERROR;
				token.value = "Character literal is too long: " + character;
			}
			fnext main;
			fbreak;
		};
	*|;

	main := |*

		number => {
			token.type = blang::Parser::token_type::T_INTEGER_VALUE;
			token.value = std::stoi(std::string(ts, te));
			fbreak;
		};

		'if'    => { token.type = blang::Parser::token_type::T_IF; fbreak; };
		'else'  => { token.type = blang::Parser::token_type::T_ELSE; fbreak; };
		'while'  => { token.type = blang::Parser::token_type::T_WHILE; fbreak; };
		'return' => { token.type = blang::Parser::token_type::T_RETURN; fbreak; };

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
		  token.type = blang::Parser::token_type::T_IDENTIFIER; fbreak;
		 };

		'{' => { token.type = blang::Parser::token_type::T_LCURVE; fbreak; };
		'}' => { token.type = blang::Parser::token_type::T_RCURVE; fbreak; };

		'(' => { token.type = blang::Parser::token_type::T_LPAREN; fbreak; };
		')' => { token.type = blang::Parser::token_type::T_RPAREN; fbreak; };

		'++'  => { token.type = blang::Parser::token_type::T_INC; fbreak; };
		'--'  => { token.type = blang::Parser::token_type::T_DEC; fbreak; };
		'~'  => { token.type = blang::Parser::token_type::T_NEG; fbreak; };

		'*' => { token.type = blang::Parser::token_type::T_STAR; fbreak; };
		'&' => { token.type = blang::Parser::token_type::T_AMPERSAND; fbreak; };

		'+' => { token.type = blang::Parser::token_type::T_PLUS; fbreak; };
		'-' => { token.type = blang::Parser::token_type::T_MINUS; fbreak; };

		'/' => { token.type = blang::Parser::token_type::T_DIV; fbreak; };
		'%' => { token.type = blang::Parser::token_type::T_MOD; fbreak; };
		
		'<<' => { token.type = blang::Parser::token_type::T_SHL; fbreak; };
		'>>' => { token.type = blang::Parser::token_type::T_SHR; fbreak; };

		'!' => { token.type = blang::Parser::token_type::T_NOT; fbreak; };
		'<' => { token.type = blang::Parser::token_type::T_LT; fbreak; };
		'<=' => { token.type = blang::Parser::token_type::T_LE; fbreak; };
		'==' => { token.type = blang::Parser::token_type::T_EQ; fbreak; };
		'!=' => { token.type = blang::Parser::token_type::T_NE; fbreak; };
		'>=' => { token.type = blang::Parser::token_type::T_GE; fbreak; };
		'>' => { token.type = blang::Parser::token_type::T_GT; fbreak; };

		':' => { token.type = blang::Parser::token_type::T_COLON; fbreak; };
		'?' => { token.type = blang::Parser::token_type::T_TERNARY; fbreak; };

		'[' => { token.type = blang::Parser::token_type::T_LSQUARE; fbreak; };
		']' => { token.type = blang::Parser::token_type::T_RSQUARE; fbreak; };

		';'+ => { token.type = blang::Parser::token_type::T_DELIM; fbreak; };
		',' => { token.type = blang::Parser::token_type::T_COMMA; fbreak; };
		'.' => { token.type = blang::Parser::token_type::T_DOT; fbreak; };

		'=' => { token.type = blang::Parser::token_type::T_ASSIGN; fbreak; };
		'=-' => { token.type = blang::Parser::token_type::T_ASSIGNMINUS; fbreak; };
		'=+' => { token.type = blang::Parser::token_type::T_ASSIGNPLUS; fbreak; };
		'=%' => { token.type = blang::Parser::token_type::T_ASSIGNMOD; fbreak; };
		'=/' => { token.type = blang::Parser::token_type::T_ASSIGNDIV; fbreak; };
		'=<<' => { token.type = blang::Parser::token_type::T_ASSIGNSHL; fbreak; };
		'=>>' => { token.type = blang::Parser::token_type::T_ASSIGNSHR; fbreak; };
		'=|' => { token.type = blang::Parser::token_type::T_ASSIGNOR; fbreak; };
		'=^' => { token.type = blang::Parser::token_type::T_ASSIGNXOR; fbreak; };
		'=&' => { token.type = blang::Parser::token_type::T_ASSIGNAND; fbreak; };
		'=*' => { token.type = blang::Parser::token_type::T_ASSIGNMUL; fbreak; };

		'auto' => { token.type = blang::Parser::token_type::T_AUTO; fbreak; };

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
    Token token{ /*.type =*/ blang::Parser::token_type::T_NONE, /*.value = */ 0 };

    do {
        if (cs >= Lexer_first_final) {
            token.type = blang::Parser::token_type::T_END;
        }

        %%write exec;
        
        if (cs == Lexer_error) {
            token.type = blang::Parser::token_type::T_NONE;
            return token;
        }
    } while (token.type == blang::Parser::token_type::T_NONE);

    return token;
}

int blang::Lexer::lex(Parser::semantic_type* val, blang::Parser::location_type*) {
	if (auto token = this->next(); token.type != blang::Parser::token_type::T_END) {
		std::visit(overloaded {
			[val](const std::string& arg){ val->build(arg); },
			[val](int arg){ val->build(arg); },
		}, token.value);

    	return token.type;
	} else {
		return 0;
	}
}

std::ostream& blang::operator<<(std::ostream& stream, const blang::Token& token) {
    stream << std::to_string(static_cast<int>(token.type)) << "=";
    std::visit(overloaded {
        [&stream](const std::string& arg){stream << std::quoted(arg);},
        [&stream](int arg){stream << std::to_string(arg);},
    }, token.value);
    stream << "\n";
    return stream;
}
