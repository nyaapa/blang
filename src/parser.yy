%debug
%language "c++"
%defines
%define api.value.type variant
%define parse.assert
%define api.namespace {blang}
%define parser_class_name {Parser}
%locations

%code requires {
	#include <list>
	#include <string>

	namespace blang { class Lexer; }
}

%code {
	#include "lexer.hpp"
	#define yylex lexer.lex
}

%parse-param { blang::Lexer& lexer }

%type <int> INTEGER_VALUE
%type <std::string> STRING_VALUE
%token INTEGER_VALUE
%token STRING_VALUE

%token PLUS 43 "+"

%type <int> int
%type <std::string> str
%%

int
	: INTEGER_VALUE PLUS INTEGER_VALUE { $$ = $1 + $3; }
	| INTEGER_VALUE { $$ = $1; }
	;

str
	: STRING_VALUE { $$ = $1; }
	;
%%

void blang::Parser::error (const Parser::location_type& loc, const std::string& msg) {
	std::cerr << loc << ": " << msg << std::endl;
}
