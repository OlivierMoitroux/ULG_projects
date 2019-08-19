/*
#if defined(__MINGW32__)
#define __MSVCRT_VERSION__ 0x800
#define _WIN32_WINNT 0x0500
#endif

// if needed
#define _fileno fileno
*/
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
#include <fstream>
//#include "CImg.h"
#include "martist.hpp"
#include "parser.hpp"


using namespace std;
/*
 * COMPILING TIPS
 *  g++ -o output -std=c++11 main.cpp martist.cpp parser.cpp -O2 -lm -lpthread -I/usr/X11/include -L/usr/X11/lib -lm -lpthread -lX11
 * or make, then g++ -o output -std=c++11 -lmartist -lm -lpthread -I/usr/X11/include -L/usr/X11/lib -lm -lpthread -lX11
 */

//using namespace cimg_library;

class streamTester {
   private:
      vector<string> a;             // 0 to infinite
      vector<string> b;           // 0 to 12

   public:
      // required constructors
      streamTester() {
         a = {"hello"};
         b  = {"world"};
      }
      friend ostream &operator<<( ostream &output, const streamTester &s ) {
         output << "a : " << s.a[0] << " b : " << s.b[0];
         return output;
      }

      friend istream &operator>>( istream  &input, streamTester &s ) {
         Parser parser(input);
         parser.parse(s.a);
         cout << s.a[0] << endl;
         //input >> s.a[0] ;//>> s.b[0];
         return input;
      }
};

int main()
{
    unsigned char* buf = NULL;
    int width = 32;
    int height = 16;
    buf = new unsigned char[width*height*3];
    buf[0] = 55;

    Martist martist(buf,width,  height, 13, 20, 18);

    martist.seed(time(NULL));
    martist.paint();

    cout << martist << endl;
    cout << "depth = " << martist.redDepth() << " " << martist.greenDepth() << " " << martist.blueDepth() << endl;
    cin  >> martist;
    cout << martist << endl;

/*


    CImg<unsigned char> img1(buf,3,width,height,1,true);
        img1.permute_axes("yzcx");
        img1.display();
*/

    return 0;
}


    //CImg<unsigned char> img(640,400,1,sizeof(unsigned char)); // Define a 640x400 color image with 8 bits per color component.
    //img.fill(0); // Set pixel values to 0 (color : black)
    //unsigned char purple[] = { 255,0,255 }; // Define a purple color
    //img.draw_text(100,100,"Hello World",purple); // Draw a purple "Hello world" at coordinates (100,100).
    //img.display("My first CImg code"); // Display the image in a display window.

