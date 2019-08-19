CXX=g++
CXXFLAGS= -std=c++11 -Wall
FLAGS=-o

martist: martist.o parser.o
	ar rcu libmartist.a martist.o parser.o 
	
martist.o: martist.cpp
	$(CXX) $(CXXFLAGS)  -c  $< $(FLAGS) $@

parser.o: parser.cpp
	$(CXX) $(CXXFLAGS)  -c  $< $(FLAGS) $@


clean:
	rm -f martist-o parser-o
