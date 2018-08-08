/* Reconhecedor de documentos HTML */
%{
#include <iostream>
#include <fstream>
#include <stack> 
#include <string>   
using namespace std;

stack<string> tags;
%}

%option noyywrap

/* Caractere: Sintaxe abstrata */

Digit		            [0-9]
LCLetter	            [a-z]
UCLetter	            [A-Z]
Special		            ['()_,\-\./:=?]


/* Caractere: Sintaxe concreta */

LCNMCHAR	            [\.-]
UCNMCHAR	            [\.-]
RE		                \n
RS		                \r
REFC	                ";"
SEPCHAR		            \011
SPACE		            \040


/* Conjunto Delimitador de Referência: Geral */

TAGO	                "<"
TAGC	                ">"
MDC	                    ">"
MDO	                    "<!"
COM	                    "--"
TLIT                    "/"
LIT	                    \"
LITA	                "'"
EQUALS                  "="


/* ML Caractere */
name_start_character	{LCLetter}|{UCLetter}
name_character		    {name_start_character}|{Digit}|{LCNMCHAR}|{UCNMCHAR}

/* Nome */

name		            {name_start_character}{name_character}*
number		            {Digit}+
number_token	        {Digit}{name_character}*
name_token	            {name_character}+

/* Atributos */
attr               {number}|{name}

/* Espaços */
s		                {SPACE}|{RE}|{RS}|{SEPCHAR}
ps		                ({SPACE}|{RE}|{RS}|{SEPCHAR})+

/* Espaços em branco */
ws		                ({SPACE}|{RE}|{RS}|{SEPCHAR})*

/*  Fim de referência */
reference_end	        ({REFC}|{RE})

white                   {reference_end}*

/* Estados */
%s HTML


/* Talvez depois de pegar todo mundo eu possa tirar esse white e botar no fim*/
%%
{MDO}{name}{ws}{name}{MDC}            ;//cout << "Doctype encontrado!"; // <!DOCTYPE html>
{MDO}{COM}([^-]|-[^-])*{COM}{MDC}     ;//cout<< "Comentario encontrado!"; // <!-- COMENTÁRIOS -->
{TAGO}{name}({ws}{name}{EQUALS}{LIT}(.)*{LIT})*{TAGC}           cout << "+--" << YYText() << endl;
{TAGO}{TLIT}{name}{TAGC}                                        cout << "+--" << YYText() << endl;
{white}                                                         ;
{ws}                                                            ;
.                                                               ;
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

int main(int argc, char ** argv)
{
	yyFlexLexer lexer;  // lexer lê da entrada padrão (teclado)
	ifstream fin;

	if (argc > 1) 
	{    
		fin.open(argv[1]);
		if (!fin.is_open()) 
        {
			cout << "Arquivo " << argv[1] << " não pode ser aberto!\n";
			exit(EXIT_FAILURE);
		}
		else
		{
			// altera entrada para arquivo aberto
			lexer.switch_streams(&fin);
		}
	}

	lexer.yylex();

	fin.close();
    // cout << endl;
	return 0;
}
