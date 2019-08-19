
/*=============================================================================
*                            Parser interface                                 *
*                            ****************                                 *
* ============================================================================*/
#ifndef PARSER_H
#define PARSER_H

#include<iostream>
#include<vector>
#include<string>


/** ------------------------------------------------------------------------- *
 * Lexer performs the lexical analysis and should be used before parsing.
 *  It converts a sequence of character (see valid expressions input) into a sequence
 *  of tokens.

 * VALID INPUT EXPRESSIONS
 * # x
 * # y
 * # sin(pi*exp1)
 * # cos(pi*exp1)
 * # (exp1*exp2)
 * # avg(exp1,exp2)
 *
 * EXCEPTIONS
 * domain_error
 *
 * @author Olivier Moitroux
 * @date 6/12/17
 * ------------------------------------------------------------------------- */

class Lexer {
    public:
      enum token {X, Y, SIN, COS, PI, OPEN_PAR, CLOSE_PAR, TIMES, AVG, COMMA};

      explicit Lexer(std::istream&);

      token next();

      token peek();

      std::streamoff count() const;

      void reset();

      static std::string toString(token tk); // @new 22/12/17

    private:
        const std::vector<char> validChar = {'(', ')', '*', ',', 'x', 'y'};
        std::string badSequence;
        std::streamoff cntr;
        std::istream* inputStream;
        std::vector<char> toBeRestored;
        token char_to_token(const char);
        token analyse_token(const bool);
        bool lexical_check(const std::string, const bool);
        void restore_stream();
        void fill_bad_sequence(bool);
};

/// Use this type to store and evaluate effectively RPN keystroke sequence
typedef std::vector<Lexer::token> exp_t; // @new 22/12/17

/** ------------------------------------------------------------------------- *
 * Parser performs a translation from a infix mathematical expression to a
 *  postix RPN notation

 * EXCEPTIONS
 * domain_error
 *
 * @author Olivier Moitroux
 * @date 12/12/17
 * ------------------------------------------------------------------------- */
class Parser{
    private:
        exp_t* xpr; // @new 22/12/17
        Lexer lexer;

        const exp_t validFOprd = {Lexer::X, Lexer::Y}; // validFinalOprd, can be extended easily if required
        void put_in_xpr(const Lexer::token);
        bool is_fOprd (const Lexer::token);
        bool is_bOprd(const std::string&);
        bool parse_aux();

    public:
        explicit Parser(std::istream& in): lexer(in) {};
        bool parse(exp_t&); // @new 22/12/17

};

#endif

