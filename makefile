C=gcc
CXX=g++
CXXFLAGS= -std=c++14 -Wall -Wundef -pedantic -pedantic -Winline -Wmissing-declarations -Wunreachable-code
# Others for development: -Wextra
#-lfl to link with other flex libraries
LIBRARIES = -lfl # removed, otherwise, double main.
NODES = AST/*.cpp AST/AstNode/*.cpp
SEMANTICS = Semantic/semantic.cpp Semantic/types.cpp Semantic/scopes/*.cpp
LLVM = LLVM/llvmGen.cpp

vsopc:clean
	$(MAKE) grammar
	$(MAKE) lexer
	$(MAKE) nodes
	$(MAKE) semantic
	$(MAKE) llvm
	$(CXX) -c -std=c++14 grammar.tab.c lexer.yy.cpp
	ar rvs lexgram.a grammar.tab.o *.o
	$(CXX) $(CXXFLAGS) main.cpp lexgram.a -o vsopc

lexer:
	flex -o lexer.yy.cpp lexer.lex

grammar:
	# -Werror: display error
	# -v: make grammar.output with informations to see conflicts
	# -Wno-eror: ask to not put warning error linked to precedence because it display wrong things.
	# -d:  union declaration is copied onto the .tab.h
	bison -d -Werror --verbose -v -Wno-error=precedence grammar.y

nodes:
	# -c because no main()
	$(CXX) -c $(CXXFLAGS) $(NODES)

semantic:
	$(CXX) -c $(CXXFLAGS) $(SEMANTICS)
	
llvm:
	$(CXX) -c $(CXXFLAGS) $(LLVM)

install-tools:
	sudo apt-get update
	sudo apt-get install libfl-dev
	sudo apt-get install flex bison
	sudo apt install llvm

archive:clean
	mkdir vsopcompiler
	mkdir vsopcompiler/AST
	mkdir vsopcompiler/Semantic
	mkdir vsopcompiler/LLVM
	mkdir vsopcompiler/libraries
	mkdir vsopcompiler/tests

	cp makefile vsopcompiler/
	cp *.hpp  vsopcompiler/
	cp *.cpp  vsopcompiler/
	cp *.lex vsopcompiler/
	cp *.y vsopcompiler/
	cp report.pdf vsopcompiler/

	cp -r AST/* vsopcompiler/AST/

	cp -r Semantic/* vsopcompiler/Semantic/

	cp LLVM/* vsopcompiler/LLVM/

	cp -r libraries/* vsopcompiler/libraries/

	cp -r test/* vsopcompiler/tests

	tar -cJf vsopcompiler.tar.xz vsopcompiler
	rm -r vsopcompiler

clean:
	rm -f vsopc *.o *.yy.cpp *.tab.c *.tab.h grammar.output lexgram.a *.tar.xz
	rm -rf vsopcompiler
