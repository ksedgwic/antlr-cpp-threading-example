Demonstration of Antlr C++ Threading Problem
----------------------------------------------------------------

1) Edit the top of the Makefile to point to your antlr4-runtime and
   antlr-complete.jar

2) make crash

The program doesn't crash every time; "make crash" runs the program in
a bash shell loop 100 times; I seem to harvest quite a few crashes
this way.

