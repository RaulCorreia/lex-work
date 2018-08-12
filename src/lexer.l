/* Reconhecedor de documentos HTML */
%{
#include <iostream>
#include <fstream>
#include <map>
#include <stack> 
#include <string>   
using namespace std;

// PILHAS DE TAGS ABERTAS
stack<string> tags;

// Para verificar se a principal tag foi aberta
bool initHTml = false;

// estatísticas
unsigned charCount = 0, tagCount = 0, lineCount = 1;

// tokens
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
Special		            ['()_,\*\+\-\./\\:=?;\"&]


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

/* Espaços em branco */
ws		                ({SPACE}|{RE}|{RS}|{SEPCHAR})*

/* tags  */
doctype 				{MDO}{name}{ws}{name}{MDC}
comment					{MDO}{COM}([^-]|-[^-])*{COM}{MDC}
tagdefopen				{name}({ws}{name}{EQUALS}(({LIT}(.)*{LIT})|({LITA}(.)*{LITA})))*
tagdefclose				{TLIT}{name}

tagondef				({tagdefopen}|{tagdefclose}){TAGC}

tagopening				{TAGO}{tagdefopen}{TAGC}
tagclosing				{TAGO}{tagdefclose}{TAGC}

/* conteúdo de texto */
textcontent 			{SPACE}*({name}|{number}|{Special})({name}|{number}|{Special}|{SPACE})*
/* Estados */
%s CONTENT


%%
{doctype}					;// <!DOCTYPE html>
{comment}					;// <!-- COMENTÁRIOS -->
{tagopening}				{	// Abertura de tags
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
											tags.push(tag);
										} else {
											cout << "Erro! Tag html ja aberta! Linha: " << lineCount;
											exit(EXIT_FAILURE);
											// sair
										}
								} else {
									if (!initHTml) {
											cout << "Erro! Tag html não foi aberta! Linha: " << lineCount;
											exit(EXIT_FAILURE);
											// sair
									} else {
										switch (resolveTag(tag)) {
											case STYLE:
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
<CONTENT>{textcontent}		{	// conteúdo de texto
								for (int i = 0; i < tags.size();++i) {
									cout << "|\t";
								}
								charCount+=yyleng;
								cout << "+--" << "Texto[" << yyleng << ']' << endl;
							}
{tagclosing}   				{	// fechamento de tags
								string tag(YYText());
								tag = tag.substr(2,tag.length()-3);
								if (tag.compare(tags.top()) == 0) {
									tags.pop();
									for (int i = 0; i < tags.size();++i) {
										cout << "|\t";
									}
									cout << "+--" << YYText() << endl;
								} else {
									cout << "Erro! Feche a tag "<< tags.top() <<" primeiro! " << tag <<" na linha: " << lineCount;
									// sair do programa
									exit(EXIT_FAILURE);
								}
							}
{RE}						{++lineCount;}                                                            ;
.          					;
%%

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

	// imprimindo estatísticas
    cout << endl;
	cout << "Tags HTML: " << tagCount << "\n" 
         << "Linhas: " << lineCount << "\n" 
         << "Caracteres: " << charCount << "\n";
	return 0;
}

// Função auxiliar para identificação dos tokens
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