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
LEFT(?=[(])                                                     { return 'LEFT'; }
RIGHT(?=[(])                                                    { return 'RIGHT'; }
MID(?=[(])                                                      { return 'MID'; }
FIND(?=[(])                                                     { return 'FIND'; }
CONTAINS(?=[(])                                                 { return 'CONTAINS'; }
ADDSLASHES(?=[(])                                               { return 'ADDSLASHES'; }
LOCALNOW(?=[(])                                                 { return 'LOCALNOW'; }
LOCALTODAY(?=[(])                                               { return 'LOCALTODAY'; }
NOW(?=[(])                                                      { return 'NOW'; }
YEAR(?=[(])                                                     { return 'YEAR'; }
TODAY(?=[(])                                                    { return 'TODAY'; }
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
">" 								                            {return '>';}
"<"                                                             {return '<';}
"="	                                                            {return '=';}
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

%left '='
%left '<=' '>=' '<>'
%left '>' '<'
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
        {$$ = yytext.substring(1, yytext.length-1);}
    ;

e
    : PRIMITIVES
    | VARIABLE
        {$$ = yytext;} 
    | MATH_OPERATIONS
    | COMPARISON_OPERATIONS
    | '(' e ')'
        {$$ = $2;}
    | FUNCTION
    ;

MATH_OPERATIONS
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

COMPARISON_OPERATIONS
    : e '=' e 
        {$$ = $1 == $3}
    | e '<' '=' e 
        {$$ = $1 <= $4}
    | e '>' '=' e 
        {$$ = $1 >= $4}
    | e '<' '>' e 
        {$$ = $1 != $4;}
    | e '>' e 
        {$$ = $1 > $3;}
    | e '<' e 
        {$$ = $1 < $3;}
    ;

FUNCTION
    : LOGIC_OPERATIONS_FUNCTIONS
    | ARITHMETIC_FUNCTIONS
    | STRING_FUNCTIONS
    | DATE_TIME_FUNCTIONS
    ;

LOGIC_OPERATIONS_FUNCTIONS
    : IF '(' e ',' e ',' e ')'
        {$$ = $3 ? $5 : $7;}
    | AND '(' e ',' e ')'
        {$$ = $3 && $5;}
    | OR '(' e ',' e ')'
        {$$ = $3 || $5;}
    | NOT '(' e ')'
        {$$ = !$1;}
    ;

ARITHMETIC_FUNCTIONS
    : MAX '(' expression_list ')'
        {$$ = Math.max.apply(null, $expression_list);}
    | MIN '(' expression_list ')'
        {$$ = Math.min.apply(null, $expression_list);}
    | ROUND '(' e ',' e ')'
        {$$ = Math.round(($3 + Number.EPSILON) * Math.pow(10, $5)) / Math.pow(10, $5);}
    ;

STRING_FUNCTIONS
    : CONCATENATE '(' expression_list ')'
        {$$ = $expression_list.join('');}
    | LEFT '(' e ',' e ')'
        {$$ = $3.substring(0,~~$5+1);}
    | RIGHT '(' e ',' e ')'
        {$$ = $3.substring(~~$3.length-~~$5-1);}
    | MID '(' e ',' e ',' e ')'
        {$$ = $3.substring(~~$5, ~~$5+~~$7);}
    | FIND '(' e ',' e ')'
        {
            var position = $3.indexOf($5)
            $$ = position > -1 ? position + 1 : -1;
        }
    | CONTAINS '(' e ',' e ')'
        {$$ = $3.indexOf($5) !== -1;}
    | ADDSLASHES '(' e ')'
        {
            var str = JSON.stringify(String($3))
            $$ = str.substring(1, str.length-1);
        }
    ;

DATE_TIME_FUNCTIONS
    : LOCALNOW '(' ')'
        {
            $$ = (new Date()).toLocaleString('en-GB', { 
                hour12: false, 
                day: "2-digit",
                month: "2-digit",
                year: "numeric",
                hour: "2-digit", 
                minute: "2-digit"
            }).split(',').join('');
        }
    | LOCALTODAY '(' ')'
        {
            $$ = (new Date()).toLocaleString('en-GB', { 
                day: "2-digit",
                month: "2-digit",
                year: "numeric",
            });
        }
    | NOW '(' ')'
        {
            $$ = Date.now();
        }
    | YEAR '(' e ')'
        {
            var d = new Date($3);
            $$ = d.getFullYear();
        }
    | TODAY '(' ')'
        {
            //Calculation accurate only for the Gregorian calendar
            var now = new Date();
            $$ = 25567 + 1 + Math.floor(now/8.64e7);
        }
    ;