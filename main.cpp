/**-----------------------------------------------------------------------------
 *                 Project Compilers : vsop -> llvm
 *                 ********************************
 *
 * @Author : Hockers Pierre, Moitroux Olivier, Roekens Joachim
 * @Date : 23.02.19
 *----------------------------------------------------------------------------*/

/// Include std library
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <string.h>
#include <cstring>
#include <string>

/// Include Nodes
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

/// Include semantic analysis support, code generation and type management.
#include "Semantic/semantic.hpp"
#include "LLVM/llvmGen.hpp"
#include "Semantic/types.hpp"

/* ---------------------------------------------
 * Integration of flex functions
 * ---------------------------------------------*/

#include "FlexLexer.h"
#include "extern_vars.hpp"  // cnt_err, not2MuchLexErr
#include "LLVM/extern_vars.hpp"
#include "grammar.tab.h"  // parse() and tokens


/* ---------------------------------------------
 * Function definitions
 * ---------------------------------------------*/

bool importVsopcLibraries(const std::string ABSOLUTE_PATH_TO_LIBRARY);
std::string buildPathToLibrary(std::string exec);


/* ---------------------------------------------
 * Constants definitions
 * ---------------------------------------------*/

int MAX_ARGS = 3;
int MIN_ARGS = 2;
const int MAX_ALLOWED_ERR = 3;

extern "C" FILE* yyin;
extern "C" int yylex();
extern "C" int parse();

/// Definition of the global variables
char* filename;
bool verbose_lex = false;
int cnt_parse_err = 0;
int cnt_sem_err = 0;
int DEBUG = 0;
std::string strGlobVar = ""; // string global to add at beginning of llvm code
std::string globVarInit = ""; // string to contain the initializer of the class to call in the beginning of main
int strNbr = 1; // number of next string
int vnsMain = 1; // VariableNameStart of the main in llvm
std::map<std::string, std::string> vsopVarNameToLlvm;  // variable name in the current scope
std::map<std::string, int> fieldsNameToInt;
int posField = 0;
std::string currClassType = "";
std::list<std::string> fieldsNotToUpdate;
int ifNum = 0;
std::map<std::string, int> classRank;
bool memory = false;
std::map<std::string, std::tuple<std::string, std::string, std::string> > oldAndNewLLVMNameAndVsopName;

ProgramNode* rootProgramNode; // store the root of the AST tree

std::string PATH_TO_LIBRARY = "libraries/IOlibrary.vsop";  // relative path the library in this project structure.

int main(int argc, char** argv)
{
    // Init flags
    bool lex = false;
    bool parse = false;
    bool semantic = false;
    bool llvm = false;
    bool exe = false;
    bool inputFromFile = true;


    try {
        /* Check number of parameters */
        if (argc < MIN_ARGS || argc > MAX_ARGS) {
            std::cerr << "Wrong call" << std::endl;
            std::cout << "Usage: ./vsopc [-lex] [-parse] [-check] [-llvm] <SOURCE-FILE>" << std::endl;
            return -1;
        }

        /* check arguments */
        // argv[0] is program name
        if (strcmp(argv[1], "-lex") == 0) {
            lex = true;
        }
        else if (strcmp(argv[1], "-parse") == 0) {
            parse = true;
        }
        else if(strcmp(argv[1], "-check") == 0){
            semantic = true;
        }
        else if(strcmp(argv[1], "-llvm") == 0){
            llvm = true;
        }
        else if(argc == 2){
            exe = true;
        }
        else {
            // Unrecognized/no flag
            std::cerr << "Unkown argument '" << argv[1] << "'" << std::endl;
            std::cout << "Usage: ./vsopc [-lex] [-parse] [-check] [-llvm] <SOURCE-FILE>" << std::endl;
            return -1;
        }

        const char* lastArg = argv[argc-1];
        if(strncmp(lastArg, "-", 1) == 0){
            std::cerr << "Wrong call: please input a file name" << std::endl;
            std::cout << "Usage: ./vsopc [-lex] [-parse] [-check] [-llvm] <SOURCE-FILE>" << std::endl;
            return -1;
        }

        filename =  (char*) argv[argc-1]; //global variable (needed for errors)

        /* Open file */
        FILE* file = fopen(filename, "r");
        if (!file) {
            std::cerr << "Unable to open file " << filename << "\n";
            return 1;   // call system to stop
        }

        if (inputFromFile)
            yyin = file;


        if (lex == true){
            verbose_lex = true;
            /* Scan tokens with flex */
            while(yylex() and not2MuchLexErr) {;}
            fclose(file);
        }
        else if (parse == true) {
            verbose_lex = false;
            if (yyparse() == 0 && cnt_parse_err == 0){
                printf("%s\n", rootProgramNode->toStr(0).c_str());
            }
            else{
                fclose(file);
                return -1;
            }
            fclose(file);
        }
        else if (semantic == true) {

            verbose_lex = false;
            if (yyparse() != 0 || cnt_parse_err != 0){
                fclose(file);
                return -1;
            }
            fclose(file);

            // Save pointer to root program node, otherwise lost by parsing the IO library
            ProgramNode* rootProgramNodeOriginal = rootProgramNode;

            // Import vsop library
            std::string ABSOLUTE_PATH_TO_LIBRARY = buildPathToLibrary(std::string(argv[0]));

            if (!importVsopcLibraries(ABSOLUTE_PATH_TO_LIBRARY)){
                std::cerr << "Could not load library, stop compilation" << std::endl;
                return -1;
            }


            SemanticAnalyzer sa = SemanticAnalyzer(rootProgramNodeOriginal);

            if (sa.analyze() == 0 && cnt_sem_err == 0 ) {
                // Display annotated AST
                printf("%s\n", rootProgramNodeOriginal->toStr(0, true).c_str());
            }
            else {
                return -1;
            }
        }

        else if (llvm == true || exe == true) {
            // Parse
            verbose_lex = false;
            if (yyparse() != 0 || cnt_parse_err != 0){
                fclose(file);
                return -1;
            }
            fclose(file);

            // Save pointer to root program node, otherwise lost by parsing the IO library
            ProgramNode* rootProgramNodeOriginal = rootProgramNode;

            // Load vsop library
            std::string ABSOLUTE_PATH_TO_LIBRARY = buildPathToLibrary(std::string(argv[0]));
            if (!importVsopcLibraries(ABSOLUTE_PATH_TO_LIBRARY)){
                std::cerr << "Could not load library, stop compilation" << std::endl;
                return -1;
            }

            SemanticAnalyzer sa = SemanticAnalyzer(rootProgramNodeOriginal);
            if(sa.analyze() != 0 || cnt_sem_err !=0){
                fclose(file);
                return -1;
            }

            // add the library classes
            for(std::string classLibStr : Types::vsopClassLib) {
                rootProgramNodeOriginal->addClass(Types::getClassNode(classLibStr));
            }

            // llvm
            LlvmGenerator gen = LlvmGenerator(rootProgramNodeOriginal);
            if (llvm) {
                // generate llvm and print
                gen.generateCode(1);
            }
            else {
                // get filename without extension
                std::string str = filename;
                std::string filenameExe = str.substr(0, str.find_first_of("."));

                // generate llvm and executable
                gen.generateCode(0);
                gen.generateExecutable(filenameExe);
            }

        }


    }
    catch (std::exception& e){
        std::cerr << "An exception occurred:" << e.what() << std::endl;
        return -1;
    }
    catch (std::string e){
        std::cerr << e << std::endl;
        return -1;
    }
    catch (const char* e){
        std::cerr << std::string(e) << std::endl;
        return -1;
    }


    if (cnt_err != 0){
        return -1;
    }
    return 0;
}

/// Build the path to the library from the command executed to launch this code.
std::string buildPathToLibrary(std::string exec){

    std::size_t found = exec.find("./");
    if (found != std::string::npos){
        // "remove ./"
        exec.erase(found, 2);
    }

    found = exec.find_last_of("/\\");
    exec = exec.substr(0,found+1);

    std::string ABSOLUTE_PATH_TO_LIBRARY = exec+PATH_TO_LIBRARY;
    return ABSOLUTE_PATH_TO_LIBRARY;
}

/// Parse the IO library and add it to Types::table and Types::vsopClassLib
bool importVsopcLibraries(const std::string ABSOLUTE_PATH_TO_LIBRARY) {

    cnt_parse_err = 0;


    /* Open file */
    FILE* file = fopen(ABSOLUTE_PATH_TO_LIBRARY.c_str(), "r");
    if (!file) {
        std::cerr << "Unable to open file " << ABSOLUTE_PATH_TO_LIBRARY << "\n";
        return false;   // call system to stop
    }

    /* parse file */
    yyin = file;

    if (yyparse() != 0 || cnt_parse_err != 0) {
        std::cerr << "Error, library " << filename << " is not correctly implemented\n" << std::endl;
        fclose(file);
    }

    fclose(file);

    /* Get the classNode */
    std::vector<ClassNode*> libClasses = rootProgramNode->getClasses();

    for(unsigned int i = 0; i < libClasses.size(); i++) {
        Types::add(libClasses[i]->getName(), libClasses[i]);
        Types::vsopClassLib.push_back(libClasses[i]->getName());
    }

    return true;
}
