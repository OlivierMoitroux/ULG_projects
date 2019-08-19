#define _USE_MATH_DEFINES
#define __USE_MINGW_ANSI_STDIO 0 // Mandatory if i want to use to_string on windows (double definition of to_string in MINGW...)
/*=============================================================================
*                            Martist implementation                           *
*                            **********************                           *
* ============================================================================*/
#include <iostream>
#include <vector>
#include <string>
#include <stdlib.h>     // srand, rand
#include <stdexcept>    // domain_error
#include <list>
#include <sstream>      // istringstream
#include <stack>
#include <math.h>

#include "parser.hpp"
#include "martist.hpp"

using namespace std;


/**
* Constructor
* @param buffer array to store image pixels, width, height, depths of expr. for r-g-b
*/
Martist::Martist(unsigned char* buffer, size_t width, size_t height, int rdepth, int gdepth, int bdepth){

    if(rdepth < 0 || gdepth < 0 || bdepth < 0)
        throw domain_error("Bad input");

    if(buffer == NULL)
        throw domain_error("Buffer ptr. is NULL");

    imgBuffer = buffer;

    this->width     = width;
    this->height    = height;
    this->rDepth    = rdepth;
    this->gDepth    = gdepth;
    this->bDepth    = bdepth;
    seed(time(NULL));
}

/**
* Sets the depth of the red-green-blue expression
* @param depth
* @return /
*/
void Martist::redDepth(int depth){
    if(depth < 0)
        throw domain_error("Expected positive depth");

    rDepth = depth;
    // Update random expression
    redXpr = randXpr(rDepth);
}

void Martist::greenDepth(int depth){
    if(depth < 0)
        throw domain_error("Expected positive depth");
    gDepth = depth;
    greenXpr = randXpr(gDepth);
}

void Martist::blueDepth(int depth){
    if(depth < 0)
        throw domain_error("Expected positive depth");
    bDepth = depth;
    blueXpr = randXpr(bDepth);
}


/**
* Gets the depth of the red-green-blue expression
* @param /
* @return depth
*/
int Martist::redDepth() const{
    return rDepth;
}

int Martist::greenDepth() const{
    return gDepth;
}

int Martist::blueDepth() const{
    return bDepth;
}


/**
* Changes the artistic style of the martist
* @param seed
* @return /
*/
void Martist::seed(int seed){
    if(seed < 0)
        throw domain_error("Expected positive seed");
    srand(seed);
    // Generate new random expressions
    redXpr   = randXpr(rDepth);
    greenXpr = randXpr(gDepth);
    blueXpr  = randXpr(bDepth);
}


/**
* Changes the image buffer
* @param image buffer, width, height
* @return /
*/
void Martist::changeBuffer(unsigned char* buffer, size_t width, size_t height){

    if(buffer == NULL)
        throw domain_error("buffer ptr is NULL !");
    imgBuffer = buffer;
}


/**
* Generates a new random image
* @param /
* @return token
* NB : depending on how you oriented your y axis in the square 2*2
*     (not told in the statement), you may need to change line commented with #
*/
void Martist::paint(){
    try{
        /*
        redXpr = "(cos(pi*(x*y)) * avg(y, sin(pi * cos(pi*cos(pi*sin(pi*(x*avg(y,y))))))))";
        greenXpr = "( y * cos(pi*cos(pi*cos(pi * cos(pi* cos( pi *(sin (pi * x) * cos(pi*y))))))))";
        blueXpr = "sin(pi *( (y*y) * cos (pi * cos(pi* cos(pi * sin(pi * sin(pi* avg(x,y))))))))";
        */

        Exp redRPN, greenRPN, blueRPN;

        if(rDepth != 0){
            std::istringstream rStream(redXpr);
            Parser rParser(rStream);
            rParser.parse(redRPN);
        }
        else redRPN.push_back("0");

        if(gDepth != 0){
            std::istringstream gStream(greenXpr);
            Parser gParser(gStream);
            gParser.parse(greenRPN);
        }
        else greenRPN.push_back("0");

        if(bDepth != 0){
            std::istringstream bStream(blueXpr);
            Parser bParser(bStream);
            bParser.parse(blueRPN);
        }
        else blueRPN.push_back("0");

        float resY, resX;
        if(height == 1)
            resY = 0;
        else resY = 2/((float)height - 1 );

        if(width == 1)
            resX = 0;
        else resX = 2/((float)width  - 1);

        unsigned char r,g,b;

        // y axis currently set in a way that i have the same picture as you gave us in
        // the statement (except that you swapped red and blue, surely when copy-pasting your xpr)
        float y = -1; // # +1
        for(size_t j = 0; j < height ; j++){

            float x = -1 ;
            for(size_t i = 0; i < width; i++){

                r = scaleUp( computeXpr(redRPN,x, y) );
                g = scaleUp( computeXpr(greenRPN,x, y) );
                b = scaleUp( computeXpr(blueRPN,x, y) );

                updateBuffer(r, g, b, j * width + i);
                /* ex:
                * R0G0B0 R1G1B1 R2G2B2
                * R3G3B3 R4G4B4 R5G5B5
                */
                x += resX;
            }
            y += resY; // # y -= resY;
        }

        /* Statement : void paint(); generates a new (random) image.
        *  => That means that each time user call paint() its different. Ok right.
        *     However, let's be clear : if user inputs sth manually, user should not expect it to be the same at next call then !
        *     Next expressions will be random !
        */
        redXpr      = randXpr(rDepth);
        greenXpr    = randXpr(gDepth);
        blueXpr     = randXpr(bDepth);
    }
    catch(domain_error& e){cerr << e.what() << endl; throw domain_error("Paint error : bad expression");}
}

/**
* [Private] Generates a new random mathematical expression
* @param max depth allowed
* @return a random expression
*/
string Martist::randXpr(const int maxDepth){

    // Let's use a double linked list of token (ptr to last element is stored)
    // Should be faster than vector to add at the front (no need to shift) in theory.
    // In practice, for short expressions, vector is the way to go. But let's try list for once its handy!
    fastExp lNode;

    if(maxDepth == 0)
        return "0";

    // Let's start with a X or a Y
    Lexer::token tk = singleOprd[rand()%singleOprd.size()];
    lNode.push_front(tk);

    int depth = 1 + rand()%maxDepth; // [1:maxDepth]

    for(int i = 0; i < depth ; ++i){

        Lexer::token rNode = leaf[rand()%leaf.size()];

        if(rNode == Lexer::COS || rNode == Lexer::SIN){
            // Merge the two nodes
            buildXpr(lNode, rNode);
        }

        else if(rNode == Lexer::TIMES || rNode == Lexer::AVG){
            // Let's take a 2nd oprd randomly between X and Y
            Lexer::token oprd2 = singleOprd[rand()%singleOprd.size()];

            // Merge the two nodes while applying the oprt btwn them
            buildXpr(lNode, rNode, oprd2);
        }
    }

    string res;
    for(fastExp::iterator tk = lNode.begin(); tk != lNode.end(); tk++){
        if(*tk == Lexer::TIMES){
            res += ' ';
            res += Lexer::toString(*tk);
            res+= ' ';
        }
        else res += Lexer::toString(*tk);
    }
    return res;
}

/**
* [Private] Merge two nodes of token while applying an oprt.
* @param list of token (oprd1), token (oprt), [ token (oprd2) ]
* @return /
* NB : [] must not be given if the oprt is a SIN or COS (single oprd oprt)
*/
void Martist::buildXpr(fastExp& oprd1, const Lexer::token oprt, const Lexer::token oprd2){

    if(oprt == Lexer::AVG){
        oprd1.push_front(Lexer::OPEN_PAR);
        oprd1.push_front(Lexer::AVG);
        oprd1.push_back(Lexer::COMMA);
    }
    else if(oprt == Lexer::TIMES){
        oprd1.push_front(Lexer::OPEN_PAR);
        oprd1.push_back(Lexer::TIMES);
    }
    else throw domain_error("[buildXpr] bad oprt");
    oprd1.push_back(oprd2);
    oprd1.push_back(Lexer::CLOSE_PAR);
}

void Martist::buildXpr(fastExp& oprd1, const Lexer::token oprt){

    if(oprt != Lexer::COS && oprt != Lexer::SIN)
        throw domain_error("[buildXpr] bad calling argument");

    oprd1.push_back(Lexer::CLOSE_PAR);
    oprd1.push_front(Lexer::TIMES);
    oprd1.push_front(Lexer::PI);
    oprd1.push_front(Lexer::OPEN_PAR);
    if(oprt == Lexer::COS)
        oprd1.push_front(Lexer::COS);
    else oprd1.push_front(Lexer::SIN);
}

/**
* [Private] Evaluates a mathematical RPN expression
* @param RPN sequence, x and y (the pt in which we evaluate the expr.)
* @return The resulting float number
*
* NB : If given an expression of depth 0 => return 0.0
*/
float Martist::computeXpr(Exp& xpr,const float x, const float y){

    if(xpr[0] == "0")
        return 0.0;

    /* General idea */
    // push oprds on stack and when there is an oprt, consume last two el. Push res.

    // We will use a stack to store operands.
    stack<float> oprdStack;

    for(Exp::size_type i = 0; i < xpr.size() ; ++i){
        if(xpr[i] == "(" || xpr[i] == ")" || xpr[i] == "enter")
            continue; // skip

        else if(xpr[i] == "x")
            oprdStack.push(x);

        else if(xpr[i] == "y")
            oprdStack.push(y);

        else if (xpr[i] == "pi")
            oprdStack.push(M_PI);

        else if (xpr[i] == "2")
            oprdStack.push(2.0);
        else{
            float b = oprdStack.top();
            oprdStack.pop();

            if(xpr[i] == "sin"){
                oprdStack.push(sin(b));
            }

            else if(xpr[i] == "cos"){
                oprdStack.push(cos(b));
            }

            else if(xpr[i] == "*"){
                float a = oprdStack.top();
                oprdStack.pop();
                oprdStack.push(b * a);
            }

            else if(xpr[i] == "+"){
                float a = oprdStack.top();
                oprdStack.pop();
                oprdStack.push(b + a);
            }

            else if(xpr[i] == "/"){
                float a = oprdStack.top();
                oprdStack.pop();
                oprdStack.push(a / b);
            }

            else throw domain_error("[computeXpr] BAD TOKEN " + xpr[i]);
        }
    }
    return oprdStack.top(); // No pop : stack destroyed after } anyway
}


/**
* [Private] Updates private r-g-bDepth.
* @param r-g-b expressions (string) - inputted manually by user -
* @return /
* NB : Depth of an expression = Nb of open or close parentheses + 1
*/
void Martist::updateDepth(string rStr, string gStr, string bStr){
    size_t i = 0;
    if(rStr.length() == 0)
        rDepth = 0;
    else{
        for( i = 0 ; i < rStr.size() ; ++i){
            if(rStr[i] == '(')
                rDepth ++;
        }
        rDepth ++; // ok for x or y as well (depth = 1);
    }

    if(gStr.length() == 0)
        gDepth = 0;
    else{
        for( i = 0 ; i < gStr.size() ; ++i){
            if(gStr[i] == '(')
                gDepth ++;
        }
        gDepth ++; // ok for x or y as well (depth = 1);
    }

    if(bStr.length() == 0)
        bDepth = 0;
    else{
        for( i = 0 ; i < rStr.size() ; ++i){
            if(bStr[i] == '(')
                bDepth ++;
        }
        bDepth ++; // ok for x or y as well (depth = 1);
    }
}

/**
* [Private] Updates one pixel (indx) in the buffer with r-g-b being intensity color level of the pixel
* @param r-g-b intensity in [0:255] and the index of pixel (left-to-right, top-to-bottom)
* @return /
* NB : Indexing is left to right, then top to bottom.
*/
void Martist::updateBuffer(const unsigned char r, const unsigned char g, const unsigned char b, const size_t pxlIdx ){

    // assert() not necessary if well coded
    size_t pxlColIdx = pxlIdx * 3;
    imgBuffer[pxlColIdx]     = r;
    imgBuffer[pxlColIdx + 1] = g;
    imgBuffer[pxlColIdx + 2] = b;
}

/**
* [Private] Translation + scaling of nb in [-1:1] to [0:255]
* @param float nb in [-1:1]
* @return uchar res in [0:255]
*/
unsigned char Martist::scaleUp(float nb){
    return (unsigned char)( (nb+1)*(255/2) );
}
