unit statement;

interface

const
    DEFAULT_CAPACITY = 2;

type
    TPossibleOperands = (constant, id, error);

    TOperand = record
        case operand: TPossibleOperands of
            constant: (n: integer);
            id: (c: char);
            error: ();
    end;

    TAlgebraOperator = (
        plus,
        minus,
        product,
        division,
        modulo,
        error
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
        greaterEqual,
        error
    );

    TBooleanExpr = record
        leftOperand: TOperand;
        booleanOperator: TBooleanOperator;
        rightOperand: TOperand;
    end;

    TPossibleWords = (
        rem,
        input,
        let,
        print,
        goto_,
        if_,
        end_,
        error
    );

    TLetTuple = record
        id: char;
        algebraExpr: TAlgebraExpr;
    end;

    TIfTuple = record
        booleanExpr: TBooleanExpr;
        gotoConstant: integer;
    end;

    TReservedWord = record
        case thisWord: TPossibleWords of
            rem: ();
            input: (inputId: char);
            let: (letTuple: TLetTuple);
            print: (printId: char);
            goto_: (gotoConstant: integer);
            if_: (ifTuple: TIfTuple);
            end_: ();
            error: ();
    end;

    TStatement = record
        lineNumber: integer;
        reservedWord: TReservedWord;
    end;

    TStatementList = record
        start: array of TStatement;
        count: integer;
        capacity: integer;
    end;

function newList(): TStatementList;
procedure append(var list: TStatementList; stmt: TStatement);
procedure pop(var list: TStatementList);

implementation

function newList(): TStatementList;

var
    newList: TStatementList;

begin
    newList.count := 0;
    newList.capacity := DEFAULT_CAPACITY;
    setLength(newList.start, DEFAULT_CAPACITY);

    init := newList;
end;

procedure append(var list: TStatementList; stmt: TStatement);

begin
    //writeLn('capacity = ', list.capacity);
    if list.count >= list.capacity then
    begin
        setLength(list.start, list.capacity * 2);
        list.capacity *= 2;
    end;

    list.start[list.count] := stmt;
    list.count += 1;
end;

procedure pop(var list: TStatementList);
begin
    if list.count > 0 then
        list.count -= 1;
end;

//var
//    test: TStatementList;
//    i: integer;
//
//begin
//    test := init();
//    append(test, 1);
//    append(test, 2);
//    append(test, 3);
//    append(test, 4);
//    append(test, 5);
//
//    pop(test);
//    pop(test);
//
//    writeLn('final count = ', test.count);
//    writeLn('final capacity = ', test.capacity);
//
//    for i := 0 to test.count - 1 do
//        writeLn('value = ', test.start[i]);

end.
