unit parser;

interface

uses
    token,
    statement;

function parse(var _tokens: TTokenList): integer;

implementation

var
    tokens: TTokenList;
    current: integer = 0;
    statements: TStatementList;
    hadError: boolean = false;

//procedure statement();
//procedure reservedWord();
//function algebraExpr(): TAlgebraExpr;
//function booleanExpr(): TBooleanExpr;

function parse(var _tokens: TTokenList): integer;

begin
    writeLn('hello!');
    parse := 1;
end;

end.