/* Reconhecedor de documentos HTML */

%{
#include <iostream>
#include "tokens.h"
using std::cout;
%}

%option noyywrap

/* 1 -- Caractere: Sintaxe abstrata */

Digit		            [0-9]
LCLetter	            [a-z]
UCLetter	            [A-Z]
Special		            ['()_,\-\./:=?]


/* 2 -- Caractere: Sintaxe concreta */

LCNMCHAR	            [\.-]
UCNMCHAR	            [\.-]
RE		                \n
RS		                \r
REFC	                ";"
SEPCHAR		            \011
SPACE		            \040


/* 3 -- Conjunto Delimitador de Referência: Geral */

STAGO	                "<"
TAGC	                ">"
MDC	                    ">"
MDO	                    "<!"
COM	                    "--"
LIT	                    \"
LITA	                "'"

/* ML Caractere */
name_start_character	{LCLetter}|{UCLetter}
name_character		    {name_start_character}|{Digit}|{LCNMCHAR}|{UCNMCHAR}

/* Nome */

name		            {name_start_character}{name_character}*
number		            {Digit}+
number_token	        {Digit}{name_character}*
name_token	            {name_character}+

/* Espaços */
s		                {SPACE}|{RE}|{RS}|{SEPCHAR}
ps		                ({SPACE}|{RE}|{RS}|{SEPCHAR})+

/* Espaços em branco */
ws		                ({SPACE}|{RE}|{RS}|{SEPCHAR})*

/*  Fim de referência */
reference_end	        ({REFC}|{RE})

white                   {reference_end}*

%%
{MDO}{name}{ws}{name}{MDC}{white}          ; // Não faça nada
{MDO}{COM}([^-]|-[^-])*{COM}{MDC}{white}   ;
%%
// {MDO}{COM}{ws}{name}{ws}{COM}{MDC}  ;
// nenhuma função auxiliar é necessária

/* if		    return IF; 
then		return THEN; 
else		return ELSE; 
{id}		return ID;  
{numero}	return NUMBER; 
"<"		    return RELOP; 
"<="		return RELOP; 
"="		    return RELOP; 
"<>"		return RELOP; 
">"		    return RELOP;
">="		return RELOP; 
.           cout << YYText() << " é um token inválido!\n";  */