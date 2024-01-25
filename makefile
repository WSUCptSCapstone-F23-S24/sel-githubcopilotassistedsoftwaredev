CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++11

c-: parser_bison.o parser_flex.o
	$(CXX) $(CXXFLAGS) -o $@ $^

parser_bison.o: parser_bison.cpp scanType.h
	$(CXX) $(CXXFLAGS) -c $<

parser_flex.o: parser_flex.cpp scanType.h
	$(CXX) $(CXXFLAGS) -c $<

clean:
	rm -f ./c-.exe *.o
