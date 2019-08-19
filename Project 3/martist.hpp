
/*=============================================================================
*                            Martist interface                                 *
*                            *****************                                 *
* ============================================================================*/

#ifndef MARTIST_H
#define MARTIST_H

#include <vector>
#include <iostream>
#include <string>
#include <list>
#include <sstream>
#include <time.h>

#include "parser.hpp"

typedef std::list<Lexer::token> fastExp;

/** ------------------------------------------------------------------------- *
 * Martist fills a buffer of unsigned char (RGB) by evaluating random generated
 *  mathematical expressions or inputted-by-user expressions.

 * VALID INPUT EXPRESSIONS
 * see parser.hpp
 *
 * EXCEPTIONS
 * domain_error
 *
 * @author Olivier Moitroux
 * @date 22/12/17
 * ------------------------------------------------------------------------- */
class Martist {

    /// Input stream operator
    friend std::istream &operator>>(std::istream &is, Martist &m) {

        std::string redStr, greenStr, blueStr;
        const std::string red("red ");
        const std::string green("green ");
        const std::string blue("blue ");

        std::getline(is, redStr, '=');
        if(red.compare(redStr))
            throw std::domain_error("red image spec not correctly formatted");
        std::getline(is, m.redXpr);

        std::getline(is, greenStr, '=');
        if(green.compare(greenStr))
            throw std::domain_error("green image spec not correctly formatted");
        std::getline(is, m.greenXpr);

        std::getline(is, blueStr, '=');
        if(blue.compare(blueStr))
            throw std::domain_error("blue image spec not correctly formatted");
        std::getline(is, m.blueXpr);

        m.updateDepth(m.redXpr, m.greenXpr, m.blueXpr);
        // /!\ "red =\ngreen = sin(pi...)" is valid (empty xpr)
        //     but i don't consider "red =  \ngreen = ..." to be a valid expression (>< empty)!
        m.paint();

        return is;
     }

     /// Output stream operator
     friend std::ostream &operator <<( std::ostream &output, Martist &m ) {
         if((m.redXpr).size() != 0 &&  (m.greenXpr).size() != 0 && (m.blueXpr).size() != 0)
            output << "red = " << m.redXpr << "\ngreen = " << m.greenXpr << "\nblue = " << m.blueXpr;

         else {
            if(m.redXpr.size() == 0 || m.greenXpr.size() == 0 || m.blueXpr.size() == 0)
                m.seed(time(NULL)); // time(NULL) don't work
            output << m.redXpr << m.greenXpr << m.blueXpr;
         }
         return output;
      }

    public:
        Martist(unsigned char* buffer, size_t width, size_t height, int rdepth, int gdepth, int bdepth);

        void redDepth(int depth);

        int redDepth() const;

        void greenDepth(int depth);

        int greenDepth() const;

        void blueDepth(int depth);

        int blueDepth() const;

        void seed(int seed);

        void changeBuffer(unsigned char* buffer, size_t width, size_t height);

        void paint();

    private:

        void buildXpr(fastExp& oprd1, const Lexer::token oprt, const Lexer::token oprd2);
        void buildXpr(fastExp& oprd1, const Lexer::token oprt);
        float computeXpr(Exp& xpr,const float x, const float y);
        std::string randXpr(const int depth);

        void updateBuffer(const unsigned char r, const unsigned char g, const unsigned char b, const size_t pxlIdx);
        unsigned char scaleUp(const float nb);
        void updateDepth(std::string rStr, std::string gStr, std::string bStr);

        std::string redXpr;
        std::string greenXpr;
        std::string blueXpr;

        unsigned char* imgBuffer;
        size_t width, height;
        int rDepth, gDepth, bDepth;
        const std::vector<Lexer::token> leaf       = {Lexer::COS, Lexer::SIN, Lexer::TIMES, Lexer::AVG};
        const std::vector<Lexer::token> singleOprd = {Lexer::X, Lexer::Y};
};

#endif
