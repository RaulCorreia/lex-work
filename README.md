# lex-work
Trabalho da cadeira de compiladores.

Este trabalho consiste em fazer um analisador de código HTML usando o [Flex](http://alumni.cs.ucr.edu/~lgao/teaching/flex.html) para gerar código C++. O analisador deve receber um arquivo no formato **.html** na linha de comando, ou ler da entrada padrão, caso
nenhum arquivo seja fornecido, e exibir:

- A estrutura hierárquica do documento HTML
- As quantidades de:
    - Linhas no arquivo
    - Pares de Tags HTML
    - Caracteres do conteúdo exibido pela página

A hierarquia do documento deve ser apresentada como no exemplo abaixo:

```
+--<html>
|   +--<head>
|   |   +--<style>
|   |   +--</style>
|   |   +--<title>
|   |   |   +--Texto[3]
|   |   +--</title>
|   +--</head>
|   +--<body>
|   |   +--<h1>
|   |   |   +--Texto[20]
|   |   +--</h1>
|   |   +--<p>
|   |   |   +--<b>
|   |   |   |   +--Texto[3]
|   |   |   +--</b>
|   |   |   +--Texto[81]
|   |   |   +--Texto[134]
|   |   |   +--Texto[135]
|   |   |   +--Texto[140]
|   |   +--</p>
|   |   +--<br>
|   |   +--<img src="Images/sample.png">
|   |   +--<br>
|   |   +--<p>
|   |   |   +--Texto[37]
|   |   |   +--<a href="https://www.w3schools.com/">
|   |   |   |   +--Texto[9]
|   |   |   +--</a>
|   |   |   +--Texto[1]
|   |   +--</p>
|   |   +--<br>
|   +--</body>
+--</html>

Tags HTML: 45
Linhas: 84
Caracteres : 1531
```

O indicador **Texto[]** deve substituir o texto que é realmente exibido pela página, com o valor
entre colchetes sendo o número de caracteres desse texto. Observe que as tags que não formam
um par início-fim, como ```<br>``` e ```<img>```, devem também contar como um par de tags.

Cada tag pode conter um ou mais atributos no formato nome="valor", como no exemplo:

    <table width="400">

O arquivo pode conter também o tipo do documento e comentários:

    <!DOCTYPE html>
    <!--comentário -->


Uso
-
>Configurei algumas tarefas pelo **vscode** para facilitar o uso.

Execute as tarefas nessa ordem:

1. cmake
2. make

Esta ultima deve gerar o arquivo **Htmlex** na pasta [Build](https://github.com/aretw0/lex-work/tree/master/Build) e logo você poderá executar-lo com           
        
    ./Build/Htmlex < ./data/lex.html
ou
    
    ./Build/Htmlex ./data/lex.html

>Isso mesmo, só funciona em sistemas operacionais linux.

Referências
-

- [A Lexical Analyzer for HTML and Basic SGML](https://www.w3.org/TR/WD-html-lex/)
- [A lexical analyzer for Basic+/- SGML Documents](https://www.w3.org/TR/WD-html-lex/sgml.l)