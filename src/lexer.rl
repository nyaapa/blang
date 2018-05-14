#include "lexer.hpp"
#include <cstdlib>
#include <string>
#include <sstream>
#include <iomanip>
#include <stdlib.h>
#include <memory>

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
			token.type = Token::Type::ERROR;
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
			token.type = Token::Type::ERROR;
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
				token.type = Token::Type::ERROR;
				token.value = "Endless string literal: " + val.substr(0, 3) + (val.length() > 3 ? "..." : "");
				fnext main;
			}
		};

		'"' => {
			token.type = Token::Type::STRING_VALUE;
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
				token.type = Token::Type::ERROR;
				token.value = "Endless string literal: " + val.substr(0, 3) + (val.length() > 3 ? "..." : "");
				fnext main;
			}
		};

		"'" => {
			std::string character{strbuf.str()};
			if (character.length() <= 4) {
				token.type = Token::Type::CHAR_VALUE;
				token.value = std::move(character);
			} else {
				token.type = Token::Type::ERROR;
				token.value = "Character literal is too long: " + character;
			}
			fnext main;
			fbreak;
		};
	*|;

	main := |*

		number => {
			token.type = Token::Type::INTEGER_VALUE;
			token.value = std::stoi(std::string(ts, te));
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

		'++'  => { token.type = Token::Type::INC; fbreak; };
		'--'  => { token.type = Token::Type::DEC; fbreak; };
		'~'  => { token.type = Token::Type::NEG; fbreak; };

		'*' => { token.type = Token::Type::STAR; fbreak; };
		'&' => { token.type = Token::Type::AMPERSAND; fbreak; };

		'+' => { token.type = Token::Type::PLUS; fbreak; };
		'-' => { token.type = Token::Type::MINUS; fbreak; };

		'/' => { token.type = Token::Type::DIV; fbreak; };
		'%' => { token.type = Token::Type::MOD; fbreak; };
		
		'<<' => { token.type = Token::Type::SHL; fbreak; };
		'>>' => { token.type = Token::Type::SHR; fbreak; };

		'!' => { token.type = Token::Type::NOT; fbreak; };
		'<' => { token.type = Token::Type::LT; fbreak; };
		'<=' => { token.type = Token::Type::LE; fbreak; };
		'==' => { token.type = Token::Type::EQ; fbreak; };
		'!=' => { token.type = Token::Type::NE; fbreak; };
		'>=' => { token.type = Token::Type::GE; fbreak; };
		'>' => { token.type = Token::Type::GT; fbreak; };

		':' => { token.type = Token::Type::COLON; fbreak; };
		'?' => { token.type = Token::Type::TERNARY; fbreak; };

		'[' => { token.type = Token::Type::LSQUARE; fbreak; };
		']' => { token.type = Token::Type::RSQUARE; fbreak; };

		';'+ => { token.type = Token::Type::DELIM; fbreak; };
		',' => { token.type = Token::Type::COMMA; fbreak; };
		'.' => { token.type = Token::Type::DOT; fbreak; };

		'=' => { token.type = Token::Type::ASSIGN; fbreak; };
		'=-' => { token.type = Token::Type::ASSIGNMINUS; fbreak; };
		'=+' => { token.type = Token::Type::ASSIGNPLUS; fbreak; };
		'=%' => { token.type = Token::Type::ASSIGNMOD; fbreak; };
		'=/' => { token.type = Token::Type::ASSIGNDIV; fbreak; };
		'=<<' => { token.type = Token::Type::ASSIGNSHL; fbreak; };
		'=>>' => { token.type = Token::Type::ASSIGNSHR; fbreak; };
		'=|' => { token.type = Token::Type::ASSIGNOR; fbreak; };
		'=^' => { token.type = Token::Type::ASSIGNXOR; fbreak; };
		'=&' => { token.type = Token::Type::ASSIGNAND; fbreak; };
		'=*' => { token.type = Token::Type::ASSIGNMUL; fbreak; };

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
    Token token{ /*.type =*/ Token::Type::NONE, /*.value = */ 0 };

    do {
        if (cs >= Lexer_first_final) {
            token.type = Token::Type::END;
        }

        %%write exec;
        
        if (cs == Lexer_error) {
            token.type = Token::Type::NONE;
            return token;
        }
    } while (token.type == Token::Type::NONE);

    return token;
}

template<class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
template<class... Ts> overloaded(Ts...) -> overloaded<Ts...>;

int blang::Lexer::lex(Parser::semantic_type* val, blang::Parser::location_type* loc) {
    auto token = this->next();
    std::visit(overloaded {
        [val](const std::string& arg){ val->build(arg); },
        [val](int arg){ val->build(arg); },
    }, token.value);
    auto pos = blang::position();
    *loc = blang::Parser::location_type(pos, pos);
    // check for -1 and other spec values
    return static_cast<int>(token.type);
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
