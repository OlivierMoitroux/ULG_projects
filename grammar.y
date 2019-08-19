%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <iostream>

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
	#include "AST/ComputableNode.hpp"

	#include "lexer.yy.cpp"
	#include "extern_vars.hpp"
	#include "string"

    	// get more accurate error (tells read token and the expected one)
	#define YYERROR_VERBOSE

	/* functions */
	extern "C" int yylex(void);
	void yyerror(char const*);
	void syntax_err(std::string str_err);
%}

// Used to ask explicitly bison to generate yylloc (auto if used in this file though)
%locations

%union
{
	int intLit;
	std::string* strLit;
	ExprNode* expNode;
	AssignNode* assignNode;
	FieldNode* fieldNode;
	BlockNode* blockNode;
	LetNode* letNode;
	WhileNode* whileNode;
	ArgsNode* argsNode;
	FormalsNode* formalsNode;
	CallNode* callNode;
	MethodNode* methodNode;
	ClassNode* classNode;
	ProgramNode* programNode;
	NewNode* newNode;
}


/* Tokens declaration */
%token INT_LIT
%token AND
%token BOOL
%token CLASS
%token DO
%token ELSE
%token EXTENDS
%token FALSE
%token IF
%token IN
%token INT32
%token ISNULL
%token LET
%token NEW
%token NOT
%token STRING
%token THEN
%token TRUE
%token UNIT
%token WHILE
%token TYPE_ID
%token OBJECT_ID
%token STRING_LIT
%token LBRACE
%token RBRACE
%token LPAR
%token RPAR
%token COLON
%token SEMICOLON
%token COMMA
%token PLUS
%token MINUS
%token TIMES
%token DIV
%token POW
%token DOT
%token EQUAL
%token LOWER
%token LOWER_EQ
%token ASSIGN

/* types */
%type <strLit> INT_LIT
%type <strLit> OBJECT_ID STRING_LIT TYPE_ID INT32 STRING BOOL UNIT PLUS MINUS TIMES DIV POW NEW
%type <strLit> type
%type <strLit> boolOp mathOpLowPrec mathOpHighPrec
%type <strLit> inheritance

%type <expNode> computable
%type <expNode> mathBoolExp

%type <callNode> fctCall dotOp
%type <methodNode> method

%type <argsNode> args argsNotEmpty arg
%type <formalsNode> argsDef argsOrEmpty argDef

%type <blockNode> stats statsOrEmpty expStat
%type <blockNode> emptyCom
%type <blockNode> matched unmatched ifStat

%type <letNode> let
%type <whileNode> loop
%type <assignNode> assign
%type <fieldNode> field
%type <newNode> newObject

%type <classNode> classBody class

%type <programNode> startProgram


%start startProgram

/* Operator associativity and precedence */
%left LAST
%left BEFORE_LAST AND
%left BBEFORE_LAST THEN
%left EQUAL LOWER LOWER_EQ 
%left ABOVE_EQ 
%left STRING_LIT INT_LIT TRUE FALSE OBJECT_ID NEW DOT
%left PLUS MINUS LPAR RPAR
%left NEG_NUM
%left TIMES DIV NOT 
%left SECOND POW
%left FIRST LET WHILE IF ELSE SEMICOLON


%%
/* Start input */
startProgram:  class				{$$ = new ProgramNode(@1.first_line,@1.first_column); $$->addClass($1); rootProgramNode = $$;}
	|      class startProgram		{$2->addClass($1); $$ = $2; $1->setPos(@1.first_line, @1.first_column);}
	|      error class startProgram 	{ /* Recover from the error at start of next class */
						 yyerrok; syntax_err("Error in program before class \"" + $2->getName()+"\"");
						 $3->addClass($2); $$ = $3;
						}
	;


/* Class declaration */
class:	CLASS TYPE_ID inheritance LBRACE classBody RBRACE	{
						// On a créé le classNode dans classBody en remplissant le contenu mais on avait pas le nom ni les indices
						$5->setClassName(*$2);
						$5->setParentClassName(*$3);
						$5->setPos(@2.first_line, @2.first_column);
						$$ = $5;
								}
	|		CLASS TYPE_ID inheritance error classBody RBRACE 	{
									$5->setClassName(*$2);
									$5->setParentClassName(*$3);
									$5->setPos(@2.first_line, @2.first_column);
									$$ = $5;
									yyerrok; syntax_err("The '{' is missing.");
									}
	|		CLASS TYPE_ID inheritance LBRACE classBody error 	{
									$5->setClassName(*$2);
									$5->setParentClassName(*$3);
									$5->setPos(@2.first_line, @2.first_column);
									$$ = $5;
									yyerrok; syntax_err("The '}' is missing.");
									}
	;

/* Class inheritance */
inheritance:	%empty			{$$ = new std::string("Object");}
	|	EXTENDS TYPE_ID		{$$ = $2;}
	|	EXTENDS error   	{
					$$ = new std::string(""); // Error
					yyerrok; syntax_err("type ID missing");
					}
	;

/* Inside class */
classBody:	%empty 			{$$ = new ClassNode(0, 0);} // tmp indices.
	|	field classBody 	{$2->addField($1);	$$ = $2; }
	|	method classBody	{$2->addMethod($1);	$$ = $2; }
	|	SEMICOLON classBody	{$$ = $2;} //Ignore empty command
	;

/* Function definition */
method:		OBJECT_ID LPAR argsOrEmpty RPAR COLON type LBRACE statsOrEmpty RBRACE	{
					// Pointeur $3, objet surlequel pointé , *$1; en fonction string ou pointeur.
					$$ = new MethodNode(@1.first_line, @1.first_column, *$1, $3, *$6, $8);
					}
	|	OBJECT_ID error argsOrEmpty RPAR COLON type LBRACE statsOrEmpty RBRACE	{
					yyerrok; syntax_err("The '(' is missing.");
					$$ = new MethodNode(@1.first_line, @1.first_column, *$1, $3, *$6, $8);
					}
	|	OBJECT_ID LPAR argsOrEmpty error COLON type LBRACE statsOrEmpty RBRACE	{
					yyerrok; syntax_err("The ')' is missing.");
					$$ = new MethodNode(@1.first_line, @1.first_column, *$1, $3, *$6, $8);
					}
	;

/* Function definition arguments or empty */
argsOrEmpty:	%empty		{$$ = new FormalsNode(0,0);} // We still want to print "[]" if no formals -> use of the to_str()function in formalNode
	|	argsDef		{$$ = $1;}
	;

/* Function definitions arguments */
argsDef:	argDef COMMA argsDef	{$1->fuseFormalsNodeBack($3); $$ = $1;} // Take the first and merge it with the last one.
	|	argDef			{$$ = $1;} // Easier for formalsNode
	;

/* Function definitions argument */
argDef:		OBJECT_ID COLON type	{$$ = new FormalsNode(@1.first_line, @1.first_column, *$1, *$3);}
	;

/* DOT operations */
// dotOp is like fctCall, a CallNode. By default, calls are self.method(). If calling method of other object, replace self by object.
dotOp:	dotOp DOT fctCall			{$3->changeObject($1); $$ = $3;}
 	|	fctCall DOT fctCall		{$3->changeObject($1); $$ = $3;}
 	|	OBJECT_ID DOT fctCall		{$3->changeObject(new ComputableNode(@1.first_line, @1.first_column, *$1, "default")); $$ = $3;}
 	|	LPAR matched RPAR DOT fctCall	%prec FIRST {$5->changeObject($2); $$ = $5;}
	;

/* Function call */
fctCall:  OBJECT_ID LPAR args RPAR		{$$ = new CallNode(@1.first_line, @1.first_column, *$1, $3);}
	|	OBJECT_ID LPAR args error 	{
						yyerrok; syntax_err("')' is missing ");
						$$ = new CallNode(@1.first_line, @1.first_column, *$1, $3);
						}
	;

/* Function calls arguments */
args: 	%empty					{$$ = new ArgsNode(0,0);} // No argument in call -> indices don't matter.
	| 	argsNotEmpty			{$$ = $1;} // indices already set
	;

/*  Function calls arguments not empty */
argsNotEmpty:	arg				{$$ = $1;}
	|	arg COMMA argsNotEmpty		{$1->fuseArgsNodeBack($3); $$ = $1;} // make it only one node, indices already set
	;

/* Function calls argument */
arg:	expStat					{$$ = new ArgsNode(@1.first_line,@1.first_column, $1);}
	;

/* Statements or empty */
statsOrEmpty:	%empty 				{
						ExprNode* thisExpNode = new ExprNode(0, 0,std::string(""));
						$$ = new BlockNode(0, 0, thisExpNode);
						// Empty statement -> don't care of indices
						}
	|	stats				{$$ = $1;}
	|	emptyCom stats			{
						//$1->fuseBlockNodeBack($2);
						//$$ = $1;
						$$ = $2;
						}
	|	emptyCom			{$$ = $1;}
	;

emptyCom:	SEMICOLON emptyCom		{
						ExprNode* thisExpNode = new ExprNode(@1.first_line, @1.first_column,std::string(";"));
						$2->addXprFront(thisExpNode);
						$$ = $2;
						}
	|	SEMICOLON			{
						ExprNode* thisExpNode = new ExprNode(@1.first_line, @1.first_column,std::string(";"));
						$$ = new BlockNode(0, 0, thisExpNode);
						}
	;

/* Statements */
stats:		expStat SEMICOLON stats 	%prec BEFORE_LAST { $1->fuseBlockNodeBack($3); $$ = $1; }
	|	expStat				%prec LAST {$$ = $1;}
	;


/* Expression of statement */
expStat:	ifStat				%prec LAST {$$ = $1;}
	;

/* IF - ELSE statement or other statements */
/* The following is done so that ELSE matches to the closest IF*/
ifStat:		matched 			%prec LAST {$$ = $1;} /* all IF matched to an ELSE */
	|	unmatched			%prec LAST {$$ = $1;} /* end with IF unmatched to an ELSE */
	;

/* a IF matched to an ELSE or ANOTHER statement */
matched:	IF matched THEN matched ELSE matched	%prec LAST{
								// TODO: why not a Block Node that construct itself on a ExprNode (and get its indices ?). Because can also be an IfNode
								IfNode* thisIfNode = new IfNode(@1.first_line, @1.first_column, $2, $4, $6);
								$$ = new BlockNode(@1.first_line, @1.first_column, thisIfNode);
								}
			/* The two below are if else stat. with respectively if and else having 1 statement (if & else or other
			 * but no unmatched if) and resp. else and if with many statements inside brackets */
	|	IF matched THEN matched ELSE LBRACE statsOrEmpty RBRACE	%prec LAST{
								IfNode* thisIfNode = new IfNode(@1.first_line, @1.first_column, $2, $4, $7);
								$$ = new BlockNode(@1.first_line, @1.first_column, thisIfNode);
								}
	|	IF matched THEN LBRACE statsOrEmpty RBRACE ELSE matched %prec LAST{
								IfNode* thisIfNode = new IfNode(@1.first_line, @1.first_column, $2, $5, $8);
								$$ = new BlockNode(@1.first_line, @1.first_column, thisIfNode);
								}
			/* Those one below are considered as a single statement, don't need the matched and unmatched */
	|	IF matched THEN LBRACE statsOrEmpty RBRACE ELSE LBRACE statsOrEmpty RBRACE	%prec LAST{
								IfNode* thisIfNode = new IfNode(@1.first_line, @1.first_column, $2, $5, $9);
								$$ = new BlockNode(@1.first_line, @1.first_column, thisIfNode);
								}
	|     	matched mathOpLowPrec matched	%prec PLUS	{
								BinOpNode* thisBinNode = new BinOpNode(@2.first_line, @2.first_column, *$2, $1, $3,
								"int32", "int32");
								$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_column, thisBinNode)); // TODO: indices correct ?
								}
	|     	matched mathOpHighPrec matched	%prec TIMES 	{
								BinOpNode* thisBinNode = new BinOpNode(@2.first_line, @2.first_column, *$2, $1, $3,
								"int32", "int32");
								$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_column, thisBinNode));
								}
	|	MINUS matched		%prec NEG_NUM		{
								UnaryOpNode* thisUnNode = new UnaryOpNode(@1.first_line, @1.first_column,
								std::string("-"), $2, "int32", "int32");
								$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_column, thisUnNode));
								}
	|	matched AND matched	%prec BBEFORE_LAST 	{
								BinOpNode* thisBinNode  = new BinOpNode(@2.first_line, @2.first_column,
								std::string("and"), $1, $3, "bool", "bool");
								$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_column, thisBinNode));
								}
	|	LBRACE statsOrEmpty RBRACE AND matched 		%prec BBEFORE_LAST {
									BinOpNode* thisBinNode  = new BinOpNode(@1.first_line, @1.first_column,
									std::string("and"), $2, $5, "bool", "bool");
									$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_column, thisBinNode));
									}
	|	LBRACE statsOrEmpty RBRACE AND LBRACE statsOrEmpty RBRACE %prec BBEFORE_LAST {
									BinOpNode* thisBinNode  = new BinOpNode(@1.first_line, @1.first_column,
									std::string("and"), $2, $6, "bool", "bool");
									$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_column, thisBinNode));
									}
	|	matched AND LBRACE statsOrEmpty RBRACE		%prec BBEFORE_LAST {
									BinOpNode* thisBinNode  = new BinOpNode(@1.first_line, @1.first_column,
									std::string("and"), $1, $4, "bool", "bool");
									$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_column, thisBinNode));
									}
	|	NOT matched					%prec BEFORE_LAST {
									UnaryOpNode* thisUnNode = new UnaryOpNode (@1.first_line, @1.first_column,
									std::string("not"), $2, "bool", "bool");
									$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_line, thisUnNode));
									}
	|	NOT LBRACE statsOrEmpty RBRACE			%prec BEFORE_LAST {
									UnaryOpNode* thisUnNode = new UnaryOpNode (@1.first_line, @1.first_column,
									std::string("not"), $3, "bool", "bool");
									$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_line, thisUnNode));
									}
	|	matched boolOp matched %prec ABOVE_EQ {
							BinOpNode* thisBinNode = new BinOpNode(@2.first_line, @2.first_column, *$2, $1, $3,
							"bool", "int32");
							$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_line, thisBinNode));
							}
	|	matched boolOp LBRACE statsOrEmpty RBRACE %prec ABOVE_EQ {
									BinOpNode* thisBinNode = new BinOpNode(@1.first_line, @1.first_column, *$2, $1, $4,
									"bool", "int32");
									$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_line, thisBinNode));
									}
	|	LBRACE statsOrEmpty RBRACE boolOp matched %prec ABOVE_EQ {
									BinOpNode* thisBinNode = new BinOpNode(@2.first_line, @2.first_column, *$4, $2, $5,
									"bool", "int32");
									$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_line, thisBinNode));
									}
	|	LBRACE statsOrEmpty RBRACE boolOp LBRACE statsOrEmpty RBRACE %prec ABOVE_EQ {
									BinOpNode* thisBinNode = new BinOpNode(@2.first_line, @2.first_column, *$4, $2, $6,
									"bool", "int32");
									$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_line, thisBinNode));
									}
	|	ISNULL matched	%prec NEG_NUM {
						UnaryOpNode* thisUnNode = new UnaryOpNode (@1.first_line, @1.first_column,
						std::string("isnull"), $2, "bool", "");
						$$ = new BlockNode(@1.first_line, @1.first_column, new ExprNode(@1.first_line, @1.first_column, thisUnNode));
						}
	|		mathBoolExp		{$$ = new BlockNode(@1.first_line, @1.first_column, $1);}
	|		LPAR matched RPAR	%prec LAST {$$ = $2;}
	|		assign			{$$ = new BlockNode(@1.first_line, @1.first_column, $1);}
	|		let			{$$ = new BlockNode(@1.first_line, @1.first_column, $1);}
	|		loop			{$$ = new BlockNode(@1.first_line, @1.first_column, $1);}
	;

/* a statement ending with IF unmatched to an ELSE  */
unmatched:	IF matched THEN ifStat 	%prec LAST{
						IfNode* thisIfNode = new IfNode(@1.first_line, @1.first_column, $2, $4);
						$$ = new BlockNode(@1.first_line, @1.first_column, thisIfNode);
						}
	|	IF matched THEN LBRACE statsOrEmpty RBRACE %prec SECOND {
									IfNode* thisIfNode = new IfNode(0, 0, $2, $5);
									$$ = new BlockNode(@1.first_line, @1.first_column, thisIfNode);
									}
	|	IF matched THEN matched ELSE unmatched	%prec LAST{
								IfNode* thisIfNode = new IfNode(0, 0, $2, $4, $6);
								$$ = new BlockNode(@1.first_line, @1.first_column, thisIfNode);
								}
	;

/* Assignment - assign value to object identifier */
assign:		OBJECT_ID ASSIGN expStat %prec LAST {$$ = new AssignNode(@1.first_line, @1.first_column,
									new ComputableNode(@1.first_line, @1.first_column, *$1, "default"), $3);
						}
	|       OBJECT_ID ASSIGN error    {
					yyerrok; syntax_err("missing value");
					ExprNode* errNode = new ExprNode(@2.first_line, @2.first_column, std::string("error recovered"));
					BlockNode* blockNode =  new BlockNode(@2.first_line, @2.first_column, errNode);
					$$ = new AssignNode(@1.first_line, @1.first_column,
					new ComputableNode(@1.first_line, @1.first_column, *$1, "default"), blockNode)
					;}
	;

/* field variable */
field:		OBJECT_ID COLON type ASSIGN expStat SEMICOLON %prec LAST{$$ = new FieldNode(@1.first_line, @1.first_column, *$1, *$3, $5);}
	|		OBJECT_ID COLON type ASSIGN LBRACE statsOrEmpty RBRACE	{$$ = new FieldNode(@1.first_line, @1.first_column, *$1, *$3, $6);}
	|		OBJECT_ID COLON type ASSIGN error   	{
								yyerrok; syntax_err("missing value");
								ExprNode* errNode = new ExprNode(0,0, std::string("error recovered")); // TODO/ which indices for errNode ?
								BlockNode* blockNode = new BlockNode(0, 0, errNode);
								$$ = new FieldNode(@1.first_line, @1.first_column, *$1, *$3, blockNode);
								}
	|		OBJECT_ID COLON error ASSIGN error SEMICOLON  	{
									yyerrok; syntax_err("missing type");
									ExprNode* errNode = new ExprNode(0,0, std::string("error recovered"));
									BlockNode* blockNode = new BlockNode(0, 0, errNode);
									$$ = new FieldNode(@1.first_line, @1.first_column, *$1,  std::string("error"), blockNode);
									//TODO find other name than error
									}
	|		OBJECT_ID COLON type SEMICOLON		{$$ = new FieldNode(@1.first_line, @1.first_column, *$1, *$3);}
	;

/* Let - assign value to object identifier in a given body */
let:	LET OBJECT_ID COLON type ASSIGN expStat IN expStat %prec LAST {$$ = new LetNode(@1.first_line, @1.first_column, *$2, *$4, $8, $6);}
	|	LET OBJECT_ID COLON type ASSIGN expStat IN LBRACE statsOrEmpty RBRACE	%prec LAST {
									$$ = new LetNode(@1.first_line, @1.first_column, *$2, *$4, $9, $6);
									}
	|	LET OBJECT_ID COLON type IN expStat %prec LAST {$$ = new LetNode(@1.first_line, @1.first_column, *$2, *$4, $6);}
	|	LET OBJECT_ID COLON type IN LBRACE statsOrEmpty RBRACE	%prec LAST {
									$$ = new LetNode(@1.first_line, @1.first_column, *$2, *$4, $7);
									}
	;

/* Loop */
loop: WHILE expStat DO LBRACE statsOrEmpty RBRACE	%prec FIRST {$$ = new WhileNode(@1.first_line, @1.first_column, $2, $5);}
	| WHILE expStat DO expStat			%prec FIRST {$$ = new WhileNode(@1.first_line, @1.first_column, $2, $4);}
	;


/* Math or boolean expression */
mathBoolExp:	computable				{$$ = $1;}
	;

/* boolean operator */
boolOp:		EQUAL				{std::string strVal = std::string("=");	 $$ = new std::string(strVal.c_str());}
	|	LOWER				{std::string strVal = std::string("<");	 $$ = new std::string(strVal.c_str());}
	|	LOWER_EQ			{std::string strVal = std::string("<="); $$ = new std::string(strVal.c_str());}
	;

/* Math operator with low precedence */
mathOpLowPrec:	PLUS				{$$ = $1;}
	|	MINUS				{$$ = $1;}
	;

/* Math operator with high precedence */
mathOpHighPrec:	DIV				{$$ = $1;}
	|	TIMES				{$$ = $1;}
	|	POW				{$$ = $1;}
	;

/* Computable object */
computable:	INT_LIT				{$$ = new ExprNode (@1.first_line, @1.first_column, new ComputableNode(@1.first_line, @1.first_column,*$1, "int32"));}
	|		STRING_LIT		{$$ = new ExprNode (@1.first_line, @1.first_column,  new ComputableNode(@1.first_line, @1.first_column,*$1, "string"));}
	|		OBJECT_ID		{$$ = new ExprNode (@1.first_line, @1.first_column,  new ComputableNode(@1.first_line, @1.first_column,*$1, "object_id"));}
	|		fctCall			{$$ = new ExprNode (@1.first_line, @1.first_column, $1); }
	| 		dotOp			%prec LAST {$$ = new ExprNode (@1.first_line, @1.first_column, $1); } //Prec => dotOp reduce < dotop DOT fctCall
	| 		newObject		{$$ = new ExprNode (@1.first_line, @1.first_column, $1); }
	|		TRUE			{$$ = new ExprNode (@1.first_line, @1.first_column, new ComputableNode(@1.first_line, @1.first_column,"true", "bool"));}
	|		FALSE			{$$ = new ExprNode (@1.first_line, @1.first_column, new ComputableNode(@1.first_line, @1.first_column,"false", "bool"));}
	|		LPAR RPAR		{$$ = new ExprNode (@1.first_line, @1.first_column, new ComputableNode(@1.first_line, @1.first_column,"()", "unit"));}
	;

/* newObject with parenthesis */
newObject : NEW TYPE_ID	%prec FIRST {$$ = new NewNode(@1.first_line, @1.first_column, *$2);}
	;

/* Variable types */
type:		INT32 				{$$ = $1; }
	|	STRING 				{$$ = $1; }
	|	BOOL 				{$$ = $1; }
	|	TYPE_ID 			{$$ = $1; }
	|	UNIT				{$$ = $1; }
	;
%%


//print the syntax error
void syntax_err(std::string str_err){
	std::cerr << str_err << "\n";
}


void yyerror(char const* err){
    // row_start, col_start before
    std::cerr << filename << ":" << yylloc.first_line << ":" << yylloc.first_column << ":"  << err << "\n";
    cnt_parse_err++;
}
