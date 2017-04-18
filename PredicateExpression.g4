
grammar PredicateExpression;

start
    : expr EOF
    ;

expr
    : '(' expr ')'                  # Paren
    | '!' expr                      # UnaryNot
    | expr '&&' expr                # BinaryAnd
    | expr '||' expr                # BinaryOr
    | binary_op_expr                # BinaryOp
    | iter_expr                     # IterExpr
    | regex_expr					# RegexExpr
    ;

binary_op_expr
    : int_implied int_cmp_op int_type
    | int_type int_cmp_op int_implied
    | int_type int_cmp_op int_type
    | str_implied str_cmp_op str_type
    | str_type str_cmp_op str_implied
    | str_type str_cmp_op str_type
    | geo_implied geo_cmp_op geo_type
    ;

iter_expr
    : 'for' var 'in' list_iter_op '(' list_bin ')' '{' ('or' | 'and') '(' expr ')' '}'
    | 'for' var 'in' map_iter_op '(' map_bin ')' '{' ('or' | 'and') '(' expr ')' '}'
    ;

regex_expr
    : 'regex_match' '(' str_implied ',' str_literal ',' int_literal ')'
    ;

int_cmp_op
    : '<'
    | '>'
    | '=='
    | '>='
    | '<='
    | '!='
    ;

str_cmp_op
    : '=='
    | '!='
    ;

geo_cmp_op
    : 'within'
    | 'contains'
    ;

list_iter_op
    : 'listitems'
    ;

map_iter_op
    : 'mapkeys'
    | 'mapvalues'
    ;

// The _implied rules require something else in the grammer to force
// their type.

int_implied
    : int_bin
    | int_var
    ;

str_implied
    : str_bin
    | str_var
    ;

geo_implied
    : geo_bin
    | geo_var
    ;

// The _type rules are unambiguous; their types are explicit.

int_type
    : int_literal
    | int_cast
    | int_metadata
    ;

str_type
    : str_literal
    | str_cast
    ;

geo_type
    : geo_cast
    ;

int_metadata
    : 'rec_device_size' '(' ')'
    | 'rec_last_update' '(' ')'
    | 'rec_void_time' '(' ')'
    | 'rec_digest_modulo' '(' int_literal ')'
    ;

int_cast
    : 'int(' ( int_bin | int_var ) ')'
    ;

str_cast
    : 'str(' ( str_bin | str_var ) ')'
    ;

geo_cast
    : 'GeoJSON(' ( geo_bin | geo_var | geo_literal  ) ')'
    ;

int_bin
    : IDENTIFIER
    ;

str_bin
    : IDENTIFIER
    ;

geo_bin
    : IDENTIFIER
    ;

list_bin
    : IDENTIFIER
    ;

map_bin
    : IDENTIFIER
    ;

var
    : '$' IDENTIFIER
    ;

int_var
    : '$' IDENTIFIER
    ;

str_var
    : '$' IDENTIFIER
    ;

geo_var
    : '$' IDENTIFIER
    ;

int_literal
    : DECIMAL_LITERAL
    | OCTAL_LITERAL
    | HEXADECIMAL_LITERAL
    ;

str_literal
    : STRING_LITERAL
    ;

geo_literal
    : STRING_LITERAL
    ;

DECIMAL_LITERAL
    : NONZERODIGIT DIGIT*
    ;

OCTAL_LITERAL
    : '0' OCTALDIGIT*
    ;

HEXADECIMAL_LITERAL
    : ( '0x' | '0X' ) HEXADECIMALDIGIT HEXADECIMALDIGIT*
    ;

IDENTIFIER
    : IDENTIFIERNONDIGIT ( IDENTIFIERNONDIGIT | DIGIT )*
    ;

fragment
IDENTIFIERNONDIGIT
    : NONDIGIT
    ;

fragment
NONDIGIT
    : [a-zA-Z_]
    ;

fragment
NONZERODIGIT
    : [1-9]
    ;

fragment
DIGIT
    : [0-9]
    ;

fragment
OCTALDIGIT
    : [0-7]
    ;

fragment
HEXADECIMALDIGIT
    : [0-9a-fA-F]
    ;

WS
    : [ \t\r\n]+ -> skip
    ;

COMMENT
    :   '/*' .*? '*/' -> skip
    ;

LINE_COMMENT
    :   '//' ~[\r\n]* -> skip
    ;

// This rule messes up the syntax coloring so it goes last ...
STRING_LITERAL
    : '\'' ( STRING_ESCAPE_SEQ | ~[\\\r\n'] )* '\''
    | '"' ( STRING_ESCAPE_SEQ | ~[\\\r\n"] )* '"'
    ;

fragment STRING_ESCAPE_SEQ
    : '\\' .
    ;
