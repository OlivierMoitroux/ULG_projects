
#define __USE_MINGW_ANSI_STDIO 0 // Mandatory if i want to use to_string on windows (double definition of to_string in MINGW...)
/*=============================================================================
*                             LEXER implementation                            *
*                            **********************                           *
* ============================================================================*/
#include<iostream>
#include<string>
#include<stdexcept> // domain_error
#include<algorithm> // find, copy
#include"parser.hpp"

using namespace std;

/// Constructor
Lexer::Lexer(istream& in){
    if(in){
        inputStream = &in;
        cntr = 0;
    }
    else throw domain_error("EOI");
}


/**
* Gets and consumes the next token in the istream.
* @param /
* @return token
*/
Lexer::token Lexer::next(){
    toBeRestored.clear(); // Normally not necessary (done in code below)
    badSequence.clear();
    token res = analyse_token(false);
    return res;
}

/**
* Peeks the next token in the istream. Istream is fully restored at the end.
* @param /
* @return the next token (without removing it from the input)
* Several consecutive calls to peek() return the same token,
* until a call to next() is interposed.
*/

Lexer::token Lexer::peek(){
    toBeRestored.clear();
    badSequence.clear();
    token res = analyse_token(true);
    return res;
}

/**
* [Private] Analyze the syntax of the next token in the istream
* @param backInstream, should be set to true if istream shouldn't
*        be modified
* @return the next token
*/
Lexer::token Lexer::analyse_token(const bool backInStream){

    if(!*inputStream)
        throw domain_error("EOI");

    char  in = inputStream->peek();
    cntr++;
    if(inputStream->eof())
        throw domain_error("EOI");

    if(in == ' '){
        inputStream->get(in);
        if(backInStream)
            toBeRestored.push_back(in);
        while(in == ' '){
            in = inputStream->peek();

            if(inputStream->eof()){
                if(backInStream )
                    restore_stream();
                throw domain_error("EOI");
            }
            if(backInStream )
                toBeRestored.push_back(in);
            cntr++;
            inputStream->get();
        }
        inputStream->unget();
        toBeRestored.pop_back();
    }

    token res;
    //try{
        switch(in){

            case 's' :
                if(!lexical_check("sin", backInStream)){
                    if(backInStream)
                        Lexer::restore_stream();
                    throw domain_error("BAD TOKEN" + badSequence); // expected sin
                }
                res = SIN; break;

            case 'c' :

                if(!lexical_check("cos", backInStream)){
                    if(backInStream)
                        Lexer::restore_stream();
                    throw domain_error("BAD TOKEN" + badSequence); // expected cos
                }
                res = COS; break;

            case 'p' :
                if(!lexical_check("pi", backInStream)){
                    if(backInStream)
                        Lexer::restore_stream();
                    throw domain_error("BAD TOKEN" + badSequence); // expected pi
                }
                res = PI; break;

            case 'a' :
                if(!lexical_check("avg", backInStream)){
                    if(backInStream)
                        Lexer::restore_stream();
                    throw domain_error("BAD TOKEN" + badSequence); // expected avg
                }
                res = AVG; break;

            default :
                if(find(validChar.begin(), validChar.end(), in) == validChar.end()){
                    fill_bad_sequence(backInStream);
                    if(backInStream)
                        Lexer::restore_stream();
                    throw domain_error("BAD TOKEN" + badSequence); // unknown symbol inputed
                }
                // Valid delimiter => no need to push in badSequence
                inputStream->get(in); // consume it
                if(backInStream)
                    toBeRestored.push_back(in);
                res = char_to_token(in);
        }
        if(backInStream)
            Lexer::restore_stream();

        return res;
    /*
    }

    catch(domain_error& e){
        // cerr << e.what() << endl;
        if(backInStream)
            Lexer::restore_stream();
        throw domain_error("BAD TOKEN: " + badSequence);
    }
    */
}

/**
* Count the number of characters that has been read from the istream since last reset()
* @param /
* @return the number of characters that have been read from the istream since
* the last call to reset() that resets the character count to zero.
*/
std::streamoff Lexer::count() const{
    return cntr;
}

/**
* Reset the character count to zero
* @param /
* @return /
*/
void Lexer::reset(){
    cntr = 0;
}

/**
* [Private] Translate an inputted str to a token
* @param string to translate
* @return token
* @throw domain_error
*/
Lexer::token Lexer::char_to_token(const char inToken){
    if(inToken == '(')       return OPEN_PAR;
    else if(inToken == ')')  return CLOSE_PAR;
    else if(inToken == 'x')  return X;
    else if(inToken == 'y')  return Y;
    else if(inToken == ',')  return COMMA;
    else if(inToken == '*')  return TIMES;
    else {
        badSequence.push_back(inToken);
        throw domain_error("BAD TOKEN:" + inToken);}
}

/**
* [Private] Check if there is any lexical mistake in the next more-than-one-character token
*           extracted from the istream
* @param validToken   : string to translate
         backInstream : bool, set it to true if istream should be restored
* @return true if syntax is correct, false otherwise
*
*/
bool Lexer::lexical_check(const string validToken, const bool backInStream){

    size_t length = distance(validToken.begin(), validToken.end());
    char c;
    cntr--;
    for (size_t i = 0; i < length ; ++i){

        inputStream->get(c);
        cntr++;
        badSequence.push_back(c); // to keep trace of the bad token if it is

        if(backInStream)
            toBeRestored.push_back(c);

        if(c != validToken[i])
            return false;
    }
    char afterToken = inputStream->peek();

    if(afterToken == ' ' || afterToken == '(' || afterToken == '*' || afterToken == ',' || inputStream->eof())
        return true;

    fill_bad_sequence(backInStream);

    return false; // sinom
}

/**
* [Private] Restore stream as before extracting last token
* @param /
* @return /
*/
void Lexer::restore_stream(){
    if(*inputStream){
        for(int i = toBeRestored.size() - 1; i >= 0; --i){
            inputStream->putback(toBeRestored[i]);
            cntr--;
        }
        toBeRestored.clear();
    }
}

/**
* [Private] When an unexpected char has been peeked, update toBeRestored and badSequence so
*           that they store all the problematic expression. ex: sino, tan(, ...
* @param backInStream, bool set to 1 if we need to update toBeRestored
* @return /
*/
void Lexer::fill_bad_sequence(bool backInStream){

    char charAfter[20]; // Take max 20 char after the bad char if they are not spaced
    inputStream->get(charAfter, 20, ' ');
    badSequence += charAfter;
    string str(charAfter);
    if(backInStream){
        copy(str.begin(),str.end(),back_inserter(toBeRestored));
        cntr += badSequence.size()-1; // because restore_stream will decrement cntr
    }
}

/*=============================================================================
*                             PARSER implementation                           *
*                            ***********************                          *
* ============================================================================*/


/**
* [Private] Put a given token into the container that store the res
* @param token
* @return /
* @throw domain_error
*/
void Parser::put_in_xpr(const Lexer::token tk){
    switch(tk){
        case Lexer::AVG :

            xpr->push_back("+");
            xpr->push_back("2");
            xpr->push_back("/");
            break;

        case Lexer::CLOSE_PAR :

            xpr->push_back(")");break;

        case Lexer::COS :

            xpr->push_back("cos"); break;

        case Lexer::OPEN_PAR :

            xpr->push_back("("); break;

        case Lexer::PI :

            if(xpr->size() != 0 && is_bOprd(*(xpr->end()-1)))
                xpr->push_back("enter");

            xpr->push_back("pi"); break;

        case Lexer::SIN :

            xpr->push_back("sin"); break;

        case Lexer::TIMES :

            xpr->push_back("*"); break;

        case Lexer::X :

            if(xpr->size() != 0 && is_bOprd(*(xpr->end()-1)))
                xpr->push_back("enter");

            xpr->push_back("x"); break;

        case Lexer::Y :

            if(xpr->size() != 0 && is_bOprd(*(xpr->end()-1)))
                xpr->push_back("enter");

            xpr->push_back("y"); break;

        default : throw domain_error("BAD TOKEN :" + tk);
    }
}

/**
* [Private] is_final_oprd Check if a token is a valid ending oprd (X or Y)
* @param token (Lexer::Token)
* @return True if token is X or Y, false otherwise
*/
bool Parser::is_fOprd (const Lexer::token tk){
    return find(validFOprd.begin(), validFOprd.end(), tk) != validFOprd.end();
}

/**
* [Private] is_basic_oprd checks if a token is a valid oprd
* @param token (string)
* @return True if token is X, Y or PI, false otherwise
*/
bool Parser::is_bOprd(const string& oprd){
    return oprd == "x" || oprd == "y" || oprd == "pi";
}

/**
* [Private] Analyze the syntax and correctness of the next expression
* @param /
* @return True if the expression is valid, false otherwise
*/
bool Parser::parse_aux(){

    Lexer::token tok = lexer.next();

    if(is_fOprd(tok)){
        put_in_xpr(tok);
        return true;
    }
    else if(tok == Lexer::CLOSE_PAR) // (sin....)
        return false;

    else if (tok == Lexer::OPEN_PAR){
        if(!parse_aux())
            return false;

        if(lexer.next() != Lexer::TIMES)
            return false;

        if(!parse_aux())
            return false;

        if(lexer.next() != Lexer::CLOSE_PAR)
            return false;

        put_in_xpr(Lexer::TIMES); // because lower precedence than oprd1 et oprd2
        return true; // ')' already checked by oprd2
    }


    else if(tok == Lexer::COS || tok == Lexer::SIN){

        if(lexer.next() != Lexer::OPEN_PAR)
            return false;

        if(lexer.next() != Lexer::PI)
            return false;

        put_in_xpr(Lexer::PI);

        if(lexer.next() != Lexer::TIMES)
            return false;

        if(!parse_aux())
             return false;

        put_in_xpr(Lexer::TIMES);

        if(lexer.next() != Lexer::CLOSE_PAR)
            return false;

        put_in_xpr(tok);
        return true;
    }

    else if(tok == Lexer::AVG){

        if(lexer.next() != Lexer::OPEN_PAR)
            return false;

        if(!parse_aux())
            return false;

        if(lexer.next() != Lexer::COMMA)
            return false;

        if(!parse_aux())
            return false;

        if(lexer.next() != Lexer::CLOSE_PAR)
            return false;

        put_in_xpr(tok);
        return true;
    }

    else return false;
    // tok == Lexer::COMMA or tok == Lexer::TIMES are considered false, due to the way the class work
}

/**
* Parse a sequence of keystroke and store the RPN of this sequence in expr
* @param expr, a pointer to a vector<string>
* @return True if parsing succeeds, false otherwise
* @throw domain_error
*/
bool Parser::parse(Exp& expr){
    expr.clear();
    xpr = &expr;
    try{
        // Initializing recursion
        Lexer::token tk;

        tk = lexer.peek();

        if((tk == Lexer::OPEN_PAR || tk == Lexer::SIN ||
              tk == Lexer::COS || tk == Lexer::AVG)){ // (x)

            if(!parse_aux()){
                throw domain_error("PARSE ERROR at " + to_string(lexer.count()));
                return false;
            }
        }

        else if(is_fOprd(tk)){ // x or x*y
            tk = lexer.next(); // tk not modified (consumed)
            put_in_xpr(tk);
        }
        else{
            throw domain_error("PARSE ERROR at " + to_string(lexer.count()));
            return false;
        }

        try{lexer.next();} // Next to consume the remaining in istream and see if eof()
        catch(domain_error& e){
            const string EOI("EOI");
            if(!EOI.compare(e.what()))
                return true;
        }
        // expected end of expr but not the case
        throw domain_error("PARSE ERROR at " + to_string(lexer.count()));
        return false;
    }
    catch(exception& e){
        // cerr << e.what() << endl;
        throw domain_error("PARSE ERROR at " + to_string(lexer.count()));
        return false;
    }
}

