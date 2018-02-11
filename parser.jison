/* lexical grammar */
%lex
%%
\s+                                                             /* skip whitespace */
"null"                                                          { return 'NULL'; }
"true"                                                          { return 'TRUE'; }
"false"                                                         { return 'FALSE'; }
'"'("\\"["]|[^"])*'"'				                            { return 'STRING'; }
"'"('\\'[']|[^'])*"'"				                            { return 'STRING'; }
[0-9]+("."[0-9]+)?\b                                            { return 'NUMBER'; }
IF(?=[(])                                                       { return 'IF'; }
AND(?=[(])                                                      { return 'AND'; }
OR(?=[(])                                                       { return 'OR'; }
NOT(?=[(])                                                      { return 'NOT'; }
MAX(?=[(])                                                      { return 'MAX'; }
MIN(?=[(])                                                      { return 'MIN'; }
ROUND(?=[(])                                                    { return 'ROUND'; }
CONCATENATE(?=[(])                                              { return 'CONCATENATE'; }
"*"                                                             { return '*'; }
"/"                                                             { return '/'; }
"-"                                                             { return '-'; }
"+"                                                             { return '+'; }
"^"                                                             { return '^'; }
"%"                                                             { return '%'; }
"("                                                             { return '('; }
")"                                                             { return ')'; }
","                                                             { return ','; }
"@"                                                             { return '@'; }
<<EOF>>                                                         { return 'EOF'; }
" "                                                             { return ' ';}
.                                                               { return 'INVALID'; }

/lex

%token NAME
%token STRING
%token FUNCTION_NAME
%token FUNCTION
%token NUMBER
%token TRUE FALSE
%token NULL
%token EOF

/* operator associations and precedence */

%left '+' '-'
%left '*' '/'
%left '^'
%right '!'
%right '%'
%left UMINUS

%start expressions

%% /* language grammar */

expressions
    : e EOF
        { typeof console !== 'undefined' ? console.log($1) : print($1);
          return $1; }
    | EOF 
        { return ''; }
    ;

expression_list
    : expression_list ',' e
      { $$ = $1.concat([$3]); }
    | e
      { $$ = [$1]; }
    ;

PRIMITIVES
    : NULL
        {$$ = null;}
    | TRUE
        {$$ = true;}
    | FALSE
        {$$ = false;}
    | NUMBER
        {$$ = Number(yytext);}
    | STRING
        {$$ = yytext;}
    ;

e
    : operations
        {$$ = $1;}
    | '(' e ')'
        {$$ = $2;}
    | PRIMITIVES
    | VARIABLE
        {$$ = yytext;}
    | FUNCTION
    ;

operations
    : e '+' e
        {$$ = $1 + $3;}
    | e '-' e
        {$$ = $1 - $3;}
    | e '*' e
        {$$ = $1 * $3;}
    | e '/' e
        {$$ = $1 / $3;}
    | e '^' e
        {$$ = Math.pow($1, $3);}
    | e '%'
        {$$ = $1 / 100;}
    | '-' e %prec UMINUS
        {$$ = -$2;}
    ;

BOOLEAN_RETURNING_EXPRESSIONS
    : AND
    | OR
    | NOT
    ;

FUNCTION
    : IF '(' e ',' e ',' e ')'
        {$$ = $3 ? $5 : $7;}
    | AND '(' e ',' e ')'
        {$$ = $3 && $5;}
    | OR '(' e ',' e ')'
        {$$ = $3 || $5;}
    | NOT '(' e ')'
        {$$ = !$1;}
    | MAX '(' expression_list ')'
        {$$ = Math.max.apply(null, $expression_list);}
    | MIN '(' expression_list ')'
        {$$ = Math.min.apply(null, $expression_list);}
    | ROUND '(' e ',' e ')'
        {$$ = Math.round(($3 + Number.EPSILON) * Math.pow(10, $5)) / Math.pow(10, $5);}
    | CONCATENATE '(' expression_list ')'
        {$$ = $expression_list.join('');}
    ;

    /*
    TODO:
        | COMPUTE
        | LEFT
        | RIGHT
        | MID
        | FIND
        | CONTAINS
        | ADDSLASHES
    */