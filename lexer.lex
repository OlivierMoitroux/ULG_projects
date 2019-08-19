/*** C++ version of the lexer ***/
%option noyywrap

/*** Definition Section ***/
%{

/* Standard library include */
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include <sstream>
#include <iostream>

/* include Nodes */
#include "AST/AstNode/AstNode.hpp"
#include "AST/BinOpNode.hpp"
#include "AST/FormalsNode.hpp"
#include "AST/ExprNode.hpp"
#include "AST/AssignNode.hpp"
#include "AST/BlockNode.hpp"
#include "AST/CallNode.hpp"
#include "AST/MethodNode.hpp"
#include "AST/FieldNode.hpp"
#include "AST/ClassNode.hpp"
#include "AST/IfNode.hpp"
#include "AST/LetNode.hpp"
#include "AST/ProgramNode.hpp"
#include "AST/UnaryOpNode.hpp"
#include "AST/WhileNode.hpp"
#include "AST/ArgsNode.hpp"
#include "AST/NewNode.hpp"

/* include the tokens table */
#include "grammar.tab.h"
#include "extern_vars.hpp"

/* Macros */
// Use this macro for parser to find yylex via extern c linkage
#define YY_DECL extern "C" int yylex()


#define SAVE_TOKEN yylval.strLit = new std::string(yytext)

// Automatically called, save location of token:
// Each time we match a string, move the end cursor to its end
#define YY_USER_ACTION update_loc();

// to locate beginning of string if error
int row_str_start = 1;
int col_str_start = 1;

const int TAB_SIZE = 4;     // Size of \t in numbre of equivalent whitespaces
int cnt_err = 0;            // nb of lexical error(s)
int zeros_cnt = 0;          // number of zeroes in front of string literals to discard
int cmt_cnt = 0;            // nb of nested comments
bool not2MuchLexErr = true; // stops lexing process in main.cpp
std::vector<int> cmt_row;   // contains row of nested comments
std::vector<int> cmt_col;   // contains col of nested comments

// Store tmp strings (used for display content)
std::string str;
std::string tokenDisp;


/* Functions signatures */
void update_loc();
void location_step();
void location_lines(int num);

void print_str(const char* my_string);
void disp_err(const char* str_err);
void disp_err(const char* str_err, int row, int col);
void disp(std::string token);

std::string bin_to_str(const char* yytext);
std::string hex_to_str(const char* yytext);
std::string esc_to_ascii(const char* my_string);
%}


/* ------ Start conditions -------- */
/* %s means inclusive while %x means exclusive (If the start condition is inclusive,
then rules with no start conditions at all will also be active. ) */
%x STR_LIT
%x STR_NEW_LINE
%x STR_NEW_LINE_OK
%x SINGLE_COMMENT
%x MULTI_COMMENT

/* ------------ MACROS ------------ */
/* -- digits -- */
digit     [0-9]
hex_digit [0-9]|[A-F]|[a-f]
/* [0-9a-fA-F] */
bin_digit [0-1]

/* -- numbers --*/
hexa_integer "0x"{hex_digit}+
binary_integer "0b"{bin_digit}+
denary_integer [1-9][0-9]*
denary_float {denary_integer}+\.{denary_integer}+

/* -- letters and names -- */
id         [a-z][a-z0-9]*
letter     [a-zA-Z]
uppercase  [A-Z]
lowercase  [a-z]
underscore [_]
type_identifiers [A-Z][A-Za-z_0-9]*
object_identifiers [a-z][A-Za-z_0-9]*

/* -- special sequence --*/
EOL   (\r|\n|\r\n)
whitespaces [\t ]+
ctrl_space_seq [ \r\t\v\n\f]
escape_seq ["\b""\t""\n""\r""\"""\\""\xhh"]
str_char [ a-z:A-Z.0-9,'`()\[\];?!\*/\+-=_<>]

/*** Rule Section ***/
%%

 /** Operators **/
"{"							{disp("lbrace"); return LBRACE;}
"}"							{disp("rbrace"); return RBRACE;}
"("							{disp("lpar"); return LPAR;}
")"							{disp("rpar"); return RPAR;}
":"							{disp("colon"); return COLON;}
";"							{disp("semicolon"); return SEMICOLON;}
","							{disp("comma"); return COMMA;}
"+"							{disp("plus"); SAVE_TOKEN; return PLUS;}
"-"							{disp("minus"); SAVE_TOKEN; return MINUS;}
"*"							{disp("times"); SAVE_TOKEN; return TIMES;}
"/"							{disp("div"); SAVE_TOKEN; return DIV;}
"^"							{disp("pow"); SAVE_TOKEN; return POW;}
"."							{disp("dot"); return DOT;}
"="							{disp("equal"); return EQUAL;}
"<"							{disp("lower"); return LOWER;}
"<="						{disp("lower-equal"); return LOWER_EQ;}
"<-"						{disp("assign"); return ASSIGN;}

 /** whitespaces **/
 /* Skip the blanks, let the first cursor pass over them. */
 /* NB: if \t should be considered as 4 columns indent: [ ]+ {;}  \t+ {yylloc.last_column += yyleng*(TAB_SIZE-1);} */
 {whitespaces}              {;}
 {EOL}                      {
                             // Set last_column to 1, increase Last_line by 1
                             location_lines(1);
                             location_step();
                            }

 /** Keywords **/
"and"						{disp("and"); return AND;}
"bool"						{disp("bool"); SAVE_TOKEN; return BOOL;}
"class"						{disp("class"); return CLASS;}
"do"						{disp("do"); return DO;}
"else"						{disp("else"); return ELSE;}
"extends"					{disp("extends");return EXTENDS;}
"false"						{disp("false"); return FALSE;}
"if"						{disp("if");  return IF;}
"in"						{disp("in");  return IN;}
"int32"						{disp("int32"); SAVE_TOKEN; return INT32;}
"isnull"					{disp("isnull"); return ISNULL;}
"let"						{disp("let"); return LET;}
"new"						{disp("new"); SAVE_TOKEN; return NEW;}
"not"						{disp("not");  return NOT;}
"string"					{disp("string"); SAVE_TOKEN; return STRING;}
"then"						{disp("then"); return THEN;}
"true"						{disp("true"); return TRUE;}
"unit"						{disp("unit");  SAVE_TOKEN; return UNIT;}
"while"						{disp("while"); return WHILE;}

 /** Type identifiers **/
{type_identifiers} 			{
                                tokenDisp = "type-identifier,"+std::string(yytext);
                                disp(tokenDisp);
    							SAVE_TOKEN;
    							return TYPE_ID;
                            }

 /** Object identifiers **/
{object_identifiers} 		{
                                tokenDisp = "object-identifier,"+std::string(yytext);
                                disp(tokenDisp);
								SAVE_TOKEN;
								return OBJECT_ID;
                            }

  /** Strings **/
  /* Start of string */
["] 						{str.clear(); str.append("\""); BEGIN(STR_LIT); row_str_start = yylloc.first_line; col_str_start = yylloc.first_column;}

  /* Body of string */
<STR_LIT>\n					{disp_err("Line feed must be introduced by \\.");
							return -1;}
<STR_LIT>{str_char}*		{str.append(yytext);}
<STR_LIT>\\\\				{str.append("\\\\");}
<STR_LIT>\\{EOL}            {location_lines(1); BEGIN(STR_NEW_LINE_OK);}
<STR_LIT>\\[^btnrx \n\t"] 	{   disp_err("\\ is wrongly used, it can only be used for \\b, \\t, \\n, \\r, \\\", \\xhh (character with byte value hh in hexadecimal) or to introduce a character escape sequence (multiple line string).");
                                return -1;
                            }
<STR_LIT>"\\\""				{str.append("\\\"");}
<STR_LIT>"\\x"/[^0-9A-F]	{disp_err("\\x should be followed by at least one hexadecimal number.");  return -1;}
<STR_LIT>\\/[^ \n\t] 		{str.append("\\");}
<STR_LIT>\\/[ \n\t] 		{BEGIN(STR_NEW_LINE);}
<STR_LIT>["]	 			{
                                str.append("\"");
    							if (verbose_lex == true) {
    								printf("%d,%d,string-literal,", row_str_start, col_str_start);
    		 						print_str(str.c_str()); printf("\n");
    		 					}
    			 				BEGIN(INITIAL); yylval.strLit = new std::string(esc_to_ascii(str.c_str()));
    			 				return STRING_LIT;
                            }
<STR_LIT><<EOF>> 			{disp_err("End of file reached before the \" closing the string-literal", row_str_start,
 							col_str_start);  BEGIN(INITIAL); return -1;}
<STR_LIT>. 					{ disp_err("Illegal token in the string-literal");
 							  BEGIN(INITIAL); return -1;}

 /* String on multiple line - expect to find a \n, ignore " " and "\t", other is error */
<STR_NEW_LINE>{whitespaces} {;}
<STR_NEW_LINE>{EOL}			{location_lines(1);BEGIN(STR_NEW_LINE_OK);}
<STR_NEW_LINE><<EOF>> 		{disp_err("End of file reached before the \" closing the string-literal", row_str_start,
 							col_str_start);  BEGIN(INITIAL); return -1;}
<STR_NEW_LINE>[^ \t\n"] 	{   disp_err("\\ is wrongly used, it can only be used for \\b, \\t, \\n, \\r, \\\", \\xhh (character with byte value hh in hexadecimal) or to introduce a character escape sequence (multiple line string).");
                                return -1;
                            }

 /* String on multiple line - a \n already found, ignore " ", "\t" and "\n", other is restart of body string */
<STR_NEW_LINE_OK>{whitespaces} {;}
<STR_NEW_LINE_OK>{EOL} 		{location_lines(1);}
<STR_NEW_LINE_OK>{str_char} {BEGIN(STR_LIT); str.append(yytext);} /* Ignore all space untill new char */
<STR_NEW_LINE_OK><<EOF>> 	{disp_err("End of file reached before the \" closing the string-literal", row_str_start,
 							col_str_start);  BEGIN(INITIAL); return -1;}
<STR_NEW_LINE_OK>. 			{disp_err("Illegal token in the string-literal");
 							BEGIN(INITIAL); return -1;}



 /** Numbers **/

"0x"({hex_digit}*[g-zG-Z]+{hex_digit}*)* {
                                            std::string err = yytext;
                                            err += " is not a valid integer literal.";
                                            disp_err(err.c_str());  return -1;
                                         }
"0b"({bin_digit}*[2-9a-zA-Z]+{bin_digit}*)* {
                                                std::string err = yytext;
                                                err += " is not a valid integer literal.";
                                                disp_err(err.c_str());
                                                 return -1;
                                            }
[0]+/{ctrl_space_seq}|[,;\+\-\*)]	{
                                        disp("integer-literal,0");  zeros_cnt=0;
                                        /* yylval.intLit = atoi(yytext); */
								        yylval.strLit = new std::string("0"); return INT_LIT;
                                    }
[0]+/[1-9]					{zeros_cnt = yyleng; /* yytext = 0's: ignore 0's before nbr */}
[1-9][0-9]*					{
                                // Start indexing at the first zero if any (e.g. 0035)
                                yylloc.first_column -= zeros_cnt;
                                /* yylval.intLit = atoi(yytext); */
                                disp("integer-literal," + std::string(yytext));
                                zeros_cnt=0; SAVE_TOKEN; return INT_LIT;
                                return INT_LIT;
                            }
{hexa_integer}              {
                                std::string hexNowInt32Str = hex_to_str(yytext);
                                disp("integer-literal,"+hexNowInt32Str);
                                /*yylval.intLit=strtol(yytext, NULL, 16);*/
                                yylval.strLit = new std::string(hexNowInt32Str);
                                return INT_LIT;
                            }
{binary_integer}	        {
                                std::string binNowInt32Str = bin_to_str(yytext);
    							disp("integer-literal," + binNowInt32Str); /*yylval.intLit=strtol(yytext+2, NULL, 2);*/
                                yylval.strLit = new std::string(binNowInt32Str);
    							return INT_LIT;
                            }


 /** Comments **/
"//"						{BEGIN(SINGLE_COMMENT);}
<SINGLE_COMMENT>[^\n]		{;}
<SINGLE_COMMENT>\n			{location_lines(1); BEGIN(INITIAL);}

 /** multiline comment **/
"(*"						{BEGIN(MULTI_COMMENT); cmt_row.push_back(yylloc.first_line); cmt_col.push_back(yylloc.first_column); cmt_cnt++;}
<MULTI_COMMENT>"*)"			{cmt_cnt--; cmt_row.pop_back(); cmt_col.pop_back();	if(cmt_cnt==0) BEGIN(INITIAL);}
<MULTI_COMMENT>"(*"			{cmt_cnt++; cmt_row.push_back(yylloc.first_line); cmt_col.push_back(yylloc.first_column);}
<MULTI_COMMENT>\n			{location_lines(1);}
<MULTI_COMMENT><<EOF>> 		{disp_err("End of file reached before the '*)' closing the multi-line comment.",
							cmt_row.back(), cmt_col.back());  cmt_row.clear(); cmt_col.clear();
							BEGIN(INITIAL); return -1;}
<MULTI_COMMENT>.			{;}

 /** Other **/
. 							{std::string total(std::string("Illegal token beginning : ") + yytext);
							disp_err(total.c_str()); BEGIN(INITIAL); return -1;}

%%

/*** Code Section ***/

/// computes 2 to the power exp
int pow2( int exp){
  if (exp == 0)
    return 1;

  int val = 1;
  while (exp != 0){
    val*=2;
    exp--;
  }
  return val;
}


/// Computes and return the int value of yytext which is a string representing a
/// binary number
std::string bin_to_str(const char* yytext){
  int value = 0;
  int exp = 0;
  int size = strlen(yytext) - 1; // is supposed to give the length of a string
  std::ostringstream ss;

  while (size != 1){

    value += (yytext[size]-48)*pow2(exp);  // conversion from ASCII to decimal
    size --;
    exp++;
  }

  ss << value;
  return ss.str();
}


/// Takes the hexa string and extract the hexa number, then convert it in std::string.
std::string hex_to_str(const char* yytext){
  std::ostringstream ss;
  ss << (int) strtol(yytext, NULL, 0);
  return ss.str();

}

/// Print the string following the right convention
void print_str(const char* my_string){
	bool prev_backslash = false;
	for (int i = 0; i < (int)strlen(my_string); i++){
		if (!prev_backslash){
			if (my_string[i] == '\\'){
				prev_backslash = true;
				std::cout << my_string[i];
			}
			else{
				std::cout << my_string[i];
			}
		}
		else{
			prev_backslash = false;
			if(my_string[i] == '"'){
				printf("\"");
			}
			else if (my_string[i] == '\\'){
				printf("\\");
			}
			else{
				printf("x");
				if(my_string[i] == 'b'){
					printf("08");
				}
				else if(my_string[i] == 't'){
					printf("09");
				}
				else if(my_string[i] == 'n'){
					printf("0a");
				}
				else if(my_string[i] == 'r'){
					printf("0d");
				}
			}
		}
	}
}

/// Conversion of control sequence (\n, ...) to ascii string
std::string esc_to_ascii(const char* my_string){
	std::string ret("");
	bool prev_backslash = false;
	for (int i = 0; i < (int)strlen(my_string); i++){
		if (!prev_backslash){
			if (my_string[i] == '\\'){
				prev_backslash = true;
				ret += my_string[i];
			}
			else{
				ret +=  my_string[i];
			}
		}
		else{
			prev_backslash = false;
			if(my_string[i] == '"'){
				ret += std::string("\"");
			}
			else if (my_string[i] == '\\'){
				ret += std::string("\\");
			}
			else{
				ret += std::string("x");
				if(my_string[i] == 'b'){
					ret += std::string("08");
				}
				else if(my_string[i] == 't'){
					ret += std::string("09");
				}
				else if(my_string[i] == 'n'){
					ret += std::string("0a");
				}
				else if(my_string[i] == 'r'){
					ret += std::string("0d");
				}
			}
		}
	}
	return ret;
}


/// print the lexical error at a custom position
void disp_err(const char* str_err, int row, int col){
    cnt_err++;
	std::cerr << filename << ":" << row << ":" << col << ": lexical error : " << str_err << "\n";
	if (cnt_err >= MAX_ALLOWED_ERR){
        // -1 because cnt_err++ is called after disp_err();

	    not2MuchLexErr = false;
	    std::cerr << "...\n";
	    std::cerr << filename << ":" << row << ":" << col << ": lexical error : " << "Not going further until the errors above are solved" << "\n";
	}
}

/// print the lexical error at the location stored in yyloc
void disp_err(const char* str_err){
    cnt_err++;
	std::cerr << filename << ":" << yylloc.first_line << ":" << yylloc.first_column << ": lexical error : " << str_err << "\n";
	if (cnt_err >= MAX_ALLOWED_ERR){
	    not2MuchLexErr = false;
	    std::cerr << "...\n";
	    std::cerr << filename << ":" << yylloc.first_line << ":" << yylloc.first_column << ": lexical error : " << "Not going further until the errors above are solved" << "\n";
	}
}

/// Display a given token and its position
void disp(std::string tokenDisp){
    if (verbose_lex == true) {
        std::cout << yylloc.first_line<<"," << yylloc.first_column << ","<< tokenDisp << std::endl;
    }
}

/// Update the current position cursor when facing a new line
void location_lines(int num){
    yylloc.last_column = 1;
    yylloc.last_line += num;
}

/// Udate the current position cursor from the token just read.
void location_step(){
    yylloc.first_column = yylloc.last_column;
    yylloc.first_line = yylloc.last_line;
}

/*
 * Each time a rule is matched, we advance the ending cursor of yyleng characters,
 * except for the rule matching a new line.

 * This is performed thanks to YY_USER_ACTION. Each time we read
 * insignificant characters, such as white spaces, we also move the first cursor
 * to the latest position
*/
void update_loc() {
    /*
    * At each yylex invocation, mark the current position as the start of the next token
    * Alternative: define LOCATION_STEP in %{ ... %} and YY_USER_ACTION to last line of this function
    */
    location_step();
    yylloc.last_column += yyleng;
}
