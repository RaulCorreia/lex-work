/* Reconhecedor de documentos HTML */
%{
#include <iostream>
#include <fstream>
#include <map>
#include <stack> 
#include <string>   
using namespace std;

stack<string> tags;
bool initHTml = false;
unsigned charCount = 0, tagCount = 0, lineCount = 0;

enum Tags {
    HTML = 1,
    HEAD,
    STYLE,
    TITLE,
    BODY,
    H1, H2, H3, H4, H5, H6,
    P, B, I, BR,
    UL, LI,
    TABLE, TR, TH, TD,
    IMG, A,
	INVALID
	};

Tags resolveTag(string input);
%}

%option noyywrap

/* Caractere: Sintaxe abstrata */

Digit		            [0-9]
LCLetter	            [a-z]
UCLetter	            [A-Z]
Special		            ['()_,\-\./:=?;\"&]


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
word 					[^ \t\n]+

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
%s CONTENT


/* Talvez depois de pegar todo mundo eu possa tirar esse white e botar no fim*/
%%
{MDO}{name}{ws}{name}{MDC}            ;//cout << "Doctype encontrado!"; // <!DOCTYPE html>
{MDO}{COM}([^-]|-[^-])*{COM}{MDC}     ;//cout<< "Comentario encontrado!"; // <!-- COMENTÁRIOS -->
{TAGO}{name}({ws}{name}{EQUALS}{LIT}(.)*{LIT})*{TAGC}           {
																	for (int i = 0; i < tags.size();++i) {
																		cout << "|\t";
																	}
																	cout << "+--" << YYText() << endl;
																	++tagCount;
																	string tag(YYText());
																	size_t found = tag.find_first_of(' ');

																	if (found != string::npos) {
																		tag = tag.substr(1,(found-1));
																	} else {
																		tag = tag.substr(1,tag.length()-2);
																	}
																	// teoricamente aqui eu vou ter so a tag para trabalhar

																	if (tag.compare("html") == 0) {
																		if (!initHTml) {
																				initHTml = true;
																				//BEGIN INITIAL;
																				tags.push(tag);
																			} else {
																				cout << "Erro! Tag html ja aberta! Linha: " << lineno();
																				exit(EXIT_FAILURE);
																				// sair
																			}
																	} else {
																		if (!initHTml) {
																				cout << "Erro! Tag html não foi aberta! Linha: " << lineno();
																				exit(EXIT_FAILURE);
																				// sair
																			} else {
																				switch (resolveTag(tag)) {
																					case STYLE:
																					/*case TABLE:
																					case UL:
																					case TR:
																					case BODY:
																					case HEAD:*/
																						tags.push(tag);
																						BEGIN INITIAL;
																						break;
																					default:
																						BEGIN CONTENT;
																						tags.push(tag);
																						break;
																					case IMG:
																					case BR:
																						break;
																					case INVALID:
																						cout << "Erro! Tag "<< tag <<" desconhecida! Linha: " << lineCount;
																						// sair do programa
																						exit(EXIT_FAILURE);
																						break;	
																				}
																			}
																	}
																}
<CONTENT>{SPACE}*({name}|{number}|{Special})({name}|{number}|{Special}|{SPACE})*					{
																	for (int i = 0; i < tags.size();++i) {
																		cout << "|\t";
																	}
																	charCount+=yyleng;
																	cout << "+--" << "Texto[" << yyleng << ']' << endl;
																}
{TAGO}{TLIT}{name}{TAGC}                                        {
																	string tag(YYText());
																	tag = tag.substr(2,tag.length()-3);
																	if (tag.compare(tags.top()) == 0) {
																		tags.pop();
																		for (int i = 0; i < tags.size();++i) {
																			cout << "|\t";
																		}
																		cout << "+--" << YYText() << endl;
																		//BEGIN INITIAL;
																		/*if (tags.size() > 0) {
																			if (tags.top().compare("body") == 0) {
																				BEGIN INITIAL;
																			}
																		}
																		switch (resolveTag(tag)) {
																			case TH:
																			case TD:
																			case LI:
																				BEGIN INITIAL;
																				break; 
																		}*/
																	} else {
																		cout << "Erro! Feche a tag "<< tags.top() <<" primeiro! " << tag <<" na linha: " << lineCount;
																		// sair do programa
																		exit(EXIT_FAILURE);
																	}
																}
{RE}                                                         {++lineCount;}                                                            ;
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
    cout << endl;
	cout << "Tags HTML: " << tagCount << "\n" 
         << "Linhas: " << lineCount+1 << "\n" 
         << "Caracteres: " << charCount << "\n";
	return 0;
}

Tags resolveTag(string input) {
    static const map<string, Tags> tagStrings {
        { "html", HTML },
		{ "head", HEAD },
		{ "style", STYLE },
        { "body", BODY },
		{ "title", TITLE},
		{ "h1", H1 },
		{ "h2", H2 },
		{ "h3", H3 },
		{ "h4", H4 },
		{ "h4", H5 },
		{ "h6", H6 },
		{ "p", P },
		{ "b", B },
		{ "i", I },
		{ "br", BR },
		{ "ul", UL },
		{ "li", LI },
		{ "table", TABLE },
		{ "tr", TR },
		{ "th", TH },
		{ "td", TD },
		{ "img", IMG },
		{ "a", A }
    };

    auto itr = tagStrings.find(input);
    if( itr != tagStrings.end() ) {
        return itr->second;
    }
    return INVALID; 
}