#include <cstring>
#include <iostream>
#include <sstream>

#include "antlr4-runtime.h"
#include "PredicateExpressionLexer.h"
#include "PredicateExpressionParser.h"
#include "PredicateExpressionBaseVisitor.h"

using namespace std;
using namespace antlr4;


// The throwstream macro assembles the string argument to the
// exception constructor from an iostream.
//
#define throwstream(__except, __msg)                \
    do {                                            \
        std::ostringstream __ostrm;                 \
        __ostrm << __msg;                           \
        throw __except(__ostrm.str().c_str());      \
    } while (false)


size_t const g_numthreads = 100;
size_t const g_numparsers = 100;

class SampleErrorListener : public BaseErrorListener {
public:
	SampleErrorListener(ostream & i_ostrm)
		: ostrm(i_ostrm)
		, sawError(false)
	{}
	
    virtual void
	syntaxError(Recognizer *recognizer,
				Token * offendingSymbol,
				size_t line,
				size_t charPositionInLine,
				const std::string &msg,
				std::exception_ptr e) override {
		ostrm << "ERROR: line " << line << ':' << charPositionInLine
			  << ": " << msg << endl;

		sawError = true;
	}

	ostream & ostrm;
	bool sawError;
};

void
create_parse_tree()
{
	string stmt = "amenity == \"restaurant\"";

	istringstream istrm(stmt);
	ANTLRInputStream input(istrm);
	PredicateExpressionLexer lexer(&input);
	CommonTokenStream tokens(&lexer);
	PredicateExpressionParser parser(&tokens);

	lexer.removeErrorListener(&ConsoleErrorListener::INSTANCE);
	parser.removeErrorListener(&ConsoleErrorListener::INSTANCE);

	ostringstream errstrm;
	SampleErrorListener errlistener(errstrm);
	lexer.addErrorListener(&errlistener);
	parser.addErrorListener(&errlistener);

	tree::ParseTree * tree = parser.start();

	// Real program would visit the parse tree here ...
}

pthread_barrier_t g_barrier;

void *
worker(void * argp)
{
	// All threads should start at once ...
	pthread_barrier_wait(&g_barrier);

	for (size_t ii = 0; ii < g_numparsers; ++ii) {
		create_parse_tree();
	}
}

int
run(int & argc, char ** & argv)
{
    vector<pthread_t> thrds;

	pthread_barrier_init(&g_barrier, NULL, g_numthreads);
	
    // Create all the threads.
    thrds.resize(g_numthreads);
    for (size_t ii = 0; ii < g_numthreads; ++ii)
    {
        int err = pthread_create(&thrds[ii], NULL, &worker, NULL);
        if (err != 0)
            throwstream(runtime_error,
						"create thread failed: " << strerror(err));
    }

    // Collect the threads on completion.
    for (size_t ii = 0; ii < g_numthreads; ++ii)
        pthread_join(thrds[ii], NULL);
	
	return 0;
}

int
main(int argc, char ** argv)
{
    try
    {
        return run(argc, argv);
    }
    catch (exception const & ex)
    {
        cerr << "EXCEPTION: " << ex.what() << endl;
        return 1;
    }
}
