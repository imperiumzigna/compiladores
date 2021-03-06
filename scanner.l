%{
#include <string.h>
#include <stdio.h>
#include "iks_dict.h"
#include "iks_tree.h"
#include "iks_types.h"
#include "iks_grammar.h"
#include "parser.h"


extern YYSTYPE yylval;

int line_number = 1;
char *last_identifier;

iks_grammar_symbol_t *create_symbol(int type) {
    char *identifier;
    int deslocamento=0;
    int d2=0;
    
    if (type==TK_LIT_CHAR || type==TK_LIT_STRING) {
        deslocamento=1; /* para eliminar '' e "" */
        d2=1;
    }
   
    identifier = malloc(yyleng+1-deslocamento-d2);
    identifier = strncpy(identifier,&yytext[deslocamento],yyleng-deslocamento-d2);     
    identifier[yyleng-deslocamento-d2]=0; //string terminal
    last_identifier=identifier;
    
    iks_grammar_symbol_t *symbol;
    symbol = new_iks_grammar_symbol();
    iks_grammar_symbol_set(symbol,type,line_number,identifier);

    /* symbol_table_append(identifier,symbol); - migrated to parser.y:decl*/
    return symbol;
}

%}


%x COMMENT
%%
\/\/[^\n\r]* { }

\/\* { BEGIN COMMENT; }

<COMMENT>.*"*/" { BEGIN 0; }
<COMMENT>[^\n\r] { }
<COMMENT>[\n\r] { line_number++; }


int { return TK_PR_INT; }
float { return TK_PR_FLOAT; }
bool { return TK_PR_BOOL; }
char { return TK_PR_CHAR; }
string { return TK_PR_STRING; }
if { return TK_PR_IF; }
then { return TK_PR_THEN; }
else { return TK_PR_ELSE; }
while { return TK_PR_WHILE; }
do { return TK_PR_DO; }
input { return TK_PR_INPUT; }
output { return TK_PR_OUTPUT; }
return { return TK_PR_RETURN; }

[0-9]+ {
    yylval.symbol = create_symbol(TK_LIT_INT);
    yylval.symbol->token_type = TK_LIT_INT;
    return TK_LIT_INT;
}

([0-9]+|-[0-9]+)\.[0-9]+ {
    yylval.symbol = create_symbol(TK_LIT_FLOAT);
    yylval.symbol->token_type = TK_LIT_FLOAT;
    return TK_LIT_FLOAT;
}

true {
    yylval.symbol = create_symbol(TK_LIT_TRUE);
    yylval.symbol->token_type = TK_LIT_TRUE;
    return TK_LIT_TRUE;
}

false {
    yylval.symbol = create_symbol(TK_LIT_FALSE);
    yylval.symbol->token_type = TK_LIT_FALSE;
    return TK_LIT_FALSE;
}

'[^']' {
    yylval.symbol = create_symbol(TK_LIT_CHAR);
    yylval.symbol->token_type = TK_LIT_CHAR;
    return TK_LIT_CHAR;
}

\"[^\"\n\r]*\" {
    yylval.symbol = create_symbol(TK_LIT_STRING);
    yylval.symbol->token_type = TK_LIT_STRING;
    return TK_LIT_STRING;
}


([a-z]|[A-Z]|_)+([a-z]|[A-Z]|_|[0-9])* {
    yylval.symbol = create_symbol(TK_IDENTIFICADOR);
    yylval.symbol->token_type = TK_IDENTIFICADOR;
    return TK_IDENTIFICADOR;
}

\,|\;|\:|\(|\)|\[|\]|\{|\}|\+|\-|\*|\/|\<|\>|\=|\!|\&|\$ { return yytext[0]; }

\<\= { return TK_OC_LE; }
\>\= { return TK_OC_GE; }
\=\= { return TK_OC_EQ; }
\!\= { return TK_OC_NE; }
\&\& { return TK_OC_AND; }
\|\| { return TK_OC_OR; }

[\n\r] { line_number++; }

[ \t]+ {  }

. { return TOKEN_ERRO; }
%%

int yy_line_number_get() {
    return line_number;
}

char* yy_last_token_identifier_get() {
    return last_identifier;
}

