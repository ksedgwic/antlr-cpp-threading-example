# Fit to your environment ...

INCS +=		-I/usr/local/include/antlr4-runtime
LIBS +=		-L/usr/local/lib -lantlr4-runtime

ANTLRJAR =	/usr/local/lib/antlr-complete.jar
ANTLRCMD =	java -Xmx500M -cp "$(ANTLRJAR):$(CLASSPATH)" org.antlr.v4.Tool

# ----------------------------------------------------------------

TARGEXE =	OBJ/example

GRAMMAR =	PredicateExpression.g4

BASE =		$(GRAMMAR:%.g4=%)

GENSRC =	\
			GEN/$(BASE)BaseVisitor.h \
			GEN/$(BASE)Visitor.h \
			GEN/$(BASE)BaseListener.h \
			GEN/$(BASE)Listener.h \
			GEN/$(BASE)Lexer.h \
			GEN/$(BASE)Parser.h \
			GEN/$(BASE)BaseListener.cpp \
			GEN/$(BASE)Listener.cpp \
			GEN/$(BASE)BaseVisitor.cpp \
			GEN/$(BASE)Visitor.cpp \
			GEN/$(BASE)Lexer.cpp \
			GEN/$(BASE)Parser.cpp \
			GEN/$(BASE)Lexer.tokens \
			GEN/$(BASE).tokens \
			$(NULL)

TARGSRC =	\
			example.cpp \
			$(NULL)

OBJS =		\
			OBJ/$(BASE)BaseVisitor.o \
			OBJ/$(BASE)Visitor.o \
			OBJ/$(BASE)BaseListener.o \
			OBJ/$(BASE)Listener.o \
			OBJ/$(BASE)Lexer.o \
			OBJ/$(BASE)Parser.o \
			$(TARGSRC:%.cpp=OBJ/%.o) \
			$(NULL)

CPPCMD =	g++
DEFS +=		-std=c++11 -g -O0

LIBS +=		-lpthread

INSTDIRCMD =	install -d

LDCMD =		g++
LDFLAGS =	

all:		$(GENSRC) $(TARGEXE)

crash:		$(TARGEXE)
			for n in {1..100}; do OBJ/example; done

$(GENSRC):	$(GRAMMAR)
			@$(CHKDIR)
			$(ANTLRCMD) -Dlanguage=Cpp -visitor -o GEN $(GRAMMAR)

OBJ/%.o:	GEN/%.cpp
			@$(CHKDIR)
			$(CPPCMD) -o $@ -c $(DEFS) $(INCS) $<

OBJ/%.o:	%.cpp
			@$(CHKDIR)
			$(CPPCMD) -o $@ -c $(DEFS) -IGEN $(INCS) $<

$(TARGEXE):	$(OBJS)
			$(LDCMD) $(LDFLAGS) -o $@ $(DEFS) $(OBJS) $(LIBS)

clean:
			rm -rf GEN OBJ

# macro to construct needed target directories
define CHKDIR
if test ! -d $(@D); then $(INSTDIRCMD) $(@D); else true; fi
endef
