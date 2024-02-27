BIN  = parser
BINS  = c- # name of the final executable
CC   = g++
CFLAGS = -DCPLUSPLUS -g -I. # Add necessary flags and include directories

SRCS = $(BIN).y $(BIN).l
HDRS = scanType.h ourgetopt.h TreeUtils.h treeNodes.h
OBJS = lex.yy.o $(BIN).tab.o ourgetopt.o TreeUtils.o
LIBS = -lm 

# Rule for final executable
$(BINS): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o $(BINS)

# Bison generates both .c file and header
$(BIN).tab.h $(BIN).tab.c: $(BIN).y
	bison -v -t -d $(BIN).y  

# Flex lexer
lex.yy.c: $(BIN).l $(BIN).tab.h
	flex $(BIN).l

# Rule for compiling ourgetopt.c
ourgetopt.o: ourgetopt.c
	$(CC) $(CFLAGS) -c ourgetopt.c

# Rules for comiling TreeUtils
TreeUtils.o: TreeUtils.c TreeUtils.h treeNodes.h
	$(CC) $(CFLAGS) -c TreeUtils.c
# Default rule to build everything
all:    
	touch $(SRCS) 
	make $(BINS)

# Clean rule to remove generated files
clean:
	rm -f $(OBJS) $(BINS) lex.yy.c $(BIN).tab.h $(BIN).tab.c $(BIN).tar $(BIN).output *~

# Rule to create a tarball of your source and headers
tar:
	tar -cvf $(BIN).tar $(SRCS) $(HDRS) makefile 
	ls -l $(BIN).tar