unit statement;

interface

const
    DEFAULT_CAPACITY = 2;

type
    TPossibleOperands = (constantOperand, idOperand, operandError);

    TOperand = record
        case value: TPossibleOperands of
            constantOperand: (n: integer);
            idOperand: (c: char);
            operandError: ();
    end;

    TAlgebraOperator = (
        plus,
        minus,
        product,
        division,
        modulo,
        algebraOperatorError
    );

    TAlgebraExpr = record
        leftOperand: TOperand;
        algebraExprOperator: TAlgebraOperator;
        rightOperand: TOperand;
    end;

    TPossibleAssignment = (
        assignmentOperand,
        assignmentAlgebraExpr,
        assignmentError
    );

    TAssignment = record
        case value: TPossibleAssignment of
            assignmentOperand: (o: TOperand);
            assignmentAlgebraExpr: (expr: TAlgebraExpr);
            assignmentError: ();
    end;

    TBooleanOperator = (
        equality,
        inequality,
        less,
        greater,
        lessEqual,
        greaterEqual,
        booleanOperatorError
    );

    TBooleanExpr = record
        leftOperand: TOperand;
        booleanExprOperator: TBooleanOperator;
        rightOperand: TOperand;
    end;

    TGoto = record
        gotoOpr: TOperand;
        gotoLine: integer;
        gotoColumn: integer;
    end;

    TPossibleWords = (
        rem,
        input,
        let,
        print,
        gotoWord,
        if_,
        end_,
        wordError
    );

    TReservedWord = record
        case value: TPossibleWords of
            rem: ();
            input: (inputOpr: TOperand);
            let: (letOpr: TOperand; letAssignment: TAssignment);
            print: (printOpr: TOperand);
            gotoWord: (gotoData: TGoto);
            if_: (ifBooleanExpr: TBooleanExpr; thenData: TGoto);
            end_: ();
            wordError: ();
    end;

    TStatement = record
        sourceLine: integer;
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
begin
    newList.count := 0;
    newList.capacity := DEFAULT_CAPACITY;
    setLength(newList.start, DEFAULT_CAPACITY);
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
