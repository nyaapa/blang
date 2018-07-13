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

%type <int> T_INTEGER_VALUE
%type <std::string> T_STRING_VALUE

%token T_INTEGER_VALUE
%token T_CHAR_VALUE
%token T_STRING_VALUE

%token T_NOT

%token T_GE
%token T_GT
%token T_EQ
%token T_NE
%token T_LE
%token T_LT

%token T_INC
%token T_DEC
%token T_NEG

// because it's 'indirection' and 'mul' at the same time
%token T_STAR
// because it's 'and' and 'address' at the same time
%token T_AMPERSAND

%token T_MINUS
%token T_PLUS
%token T_MOD
%token T_DIV
%token T_SHL
%token T_SHR

%token T_AND
%token T_XOR
%token T_OR

%token T_TERNARY
%token T_COLON

%token T_IF
%token T_ELSE

%token T_WHILE

%token T_RETURN

%token T_ASSIGN
%token T_ASSIGNMINUS
%token T_ASSIGNPLUS
%token T_ASSIGNMOD
%token T_ASSIGNDIV
%token T_ASSIGNSHL
%token T_ASSIGNSHR
%token T_ASSIGNXOR
%token T_ASSIGNOR
%token T_ASSIGNAND
%token T_ASSIGNMUL

%token T_COMMA

%token T_DELIM

%token T_DOT

%token T_IDENTIFIER

%token T_LCURVE
%token T_RCURVE

%token T_LPAREN
%token T_RPAREN

%token T_LSQUARE
%token T_RSQUARE

%token T_AUTO

%token T_END

%token T_NONE

%token T_ERROR

%type <int> int
%type <std::string> str
%%

int
	: T_INTEGER_VALUE T_PLUS T_INTEGER_VALUE { $$ = $1 + $3; }
	| T_INTEGER_VALUE { $$ = $1; }
	;

str
	: T_STRING_VALUE { $$ = $1; }
	;
%%

void blang::Parser::error (const Parser::location_type& loc, const std::string& msg) {
	std::cerr << loc << ": " << msg << std::endl;
}
