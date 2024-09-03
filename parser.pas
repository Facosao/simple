unit parser;

interface

uses
    token,
    list;

function parse(_tokens: TList): integer;

implementation

type
    TReservedWords = (
        rem,
        input,
        let,
        print,
        goto_,
        if_,
        end_
    );

    TPossibleOperands = (constant, id);

    TOperand = record
        case operand: TPossibleOperands of
            constant: (n: integer);
            id: (c: char);
    end;

    TAlgebraOperator = (
        plus,
        minus,
        product,
        division,
        modulo
    );

    TAlgebraExpr = record
        leftOperand: TOperand;
        algebraOperator: TAlgebraOperator;
        rightOperand: TOperand;
    end;

    TBooleanOperator = (
        equality,
        inequality,
        less,
        greater,
        lessEqual,
        greaterEqual
    );

    TBooleanExpr = record
        leftOperand: TOperand;
        booleanOperator: TBooleanOperator;
        rightOperand: TOperand;
    end;

    TStatement = record
        lineNumber: integer;
        case reservedWord: TReservedWords of
            rem: ();
            input: (inputId: char);
            let: (letId: char; algebraExpr: TAlgebraExpr);
            print: (printId: char);
            goto_: (constant: integer);
            if_: (booleanExpr: TBooleanExpr; constant: integer);
            end_: ();
    end;

var
    tokens: TList;
    current: integer = 0;
    statements: array[0..100] of TStatement;
    hadError: boolean = false;

//procedure statement();
//procedure reservedWord();
//function algebraExpr(): TAlgebraExpr;
//function booleanExpr(): TBooleanExpr;

function parse(_tokens: TList): integer;

var
    auxPtr: ^TNode;

begin
    tokens := _tokens;
    auxPtr := _tokens.head;

    while auxPtr <> nil do
    begin
        break;
    end;
end;

end.