# <<<<<< COMPILATION RULES FOR C/C++ & Assembly FILES >>>>>>>>>>

# >> compiler choices
CC      = gcc
CXX     = g++

# >> Warning and Optimization flags
CFLAGS    = -Wextra -Wswitch -O0 -Wall -g 
CXXFLAGS  = -Wextra -Wswitch -O0 -Wall -g
ASMFLAGS = -g

# >> Targeted file
TARGET ?= file

# >> Fallback or arguments inputs
c   ?=  main.c
cpp ?=  main.cpp
asm ?= main.s

# >> Rules for C
c_build:
	$(CC)	$(CFLAGS)	$(c)	-o	$(TARGET) -lm

# >> Rules for C++
cpp_build:
	$(CXX)	$(CXXFLAGS)	$(cpp)	-o	$(TARGET) -lm

asm_build:
	$(CC) $(ASMFLAGS) $(asm) -o $(TARGET) -lm

# >> Running C files
run_c: c_build
	@echo ""
	@echo "\n>>> [+] Executing C Output  Binary File.."
	./$(TARGET)

# >> Running Cpp files
run_cpp: cpp_build
	@echo ""
	@echo "\n>>> [+] Executing C++ Output Binary file..."
	./$(TARGET)

run_asm: asm_build
	@echo ""
	@echo "\n>>> [+] Executing Assembly Output Binary file..."
	./$(TARGET)

# >> Initiating valgrind on C files
valgrind_c: c_build
	@echo ""
	@echo "\n>>> [+] Running Valgrind on $(file)..."
	valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all ./"$(TARGET)"

# >> Initiating valgrind on C++ files
valgrind_cpp: cpp_build
	@echo ""
	@echo "\n>>> [+] Running Valgrind on $(file)..."
	valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all ./"$(TARGET)"

# >> Running the rules so as to trigger execution & triggers
test_c: valgrind_c run_c
test_cpp: valgrind_cpp run_cpp

# >> Cleaning buffer
clean: 
	rm	-f	$(TARGET)	*.o

# >> Handles updates 
.PHONY: c_build cpp_build run_c run_cpp asm_build run_asm valgrind_c valgrind_cpp test_c test_cpp clean test_all clean


