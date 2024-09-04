unit statement;

interface

const
    DEFAULT_CAPACITY = 2;

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
            goto_: (gotoConstant: integer);
            if_: (booleanExpr: TBooleanExpr; ifConstant: integer);
            end_: ();
    end;

    TStatementList = record
        start: array of TStatement;
        count: integer;
        capacity: integer;
    end;

function init(): TStatementList;
procedure append(var list: TStatementList; stmt: TStatement);
procedure pop(var list: TStatementList);

implementation

function init(): TStatementList;

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
