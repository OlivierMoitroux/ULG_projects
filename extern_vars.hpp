#ifndef CODE_GLOBAL_VARS_HPP
#define CODE_GLOBAL_VARS_HPP

/* Inside main.cpp */
extern char* filename;
extern bool verbose_lex;
extern int cnt_parse_err;
extern int cnt_sem_err;
extern ProgramNode* rootProgramNode;

/* Inside lexer */
extern int cnt_err;
extern bool not2MuchLexErr;
extern const int MAX_ALLOWED_ERR;

#endif //CODE_GLOBAL_VARS_HPP
