unit objects;

interface

uses statement;

const
    // I/O
    INST_READ = 10;
    INST_WRITE = 11;
    INST_LOAD = 20;
    INST_STORE = 21;
    
    // Algebra
    INST_ADD = 30;
    INST_SUBTRACT = 31;
    INST_DIVIDE = 32;
    INST_MULTIPLY = 33;
    INST_MODULO = 34;

    // Control flow
    INST_BRANCH = 40;
    INST_BRANCHNEG = 41;
    INST_BRANCHZERO = 42;
    INST_HALT = 43;

    // Internal
    INST_NOOP = 60;
    NO_ADDRESS = -1;

    // Miscellaneous
    DEFAULT_CAPACITY = 8;
    ARRAY_CAPACITY = 5;
    EMPTY_OPERAND: TOperand = (value: operandError; n: 0);

type
    TAddressTarget = (constantAddress, idAddress, lineAddress);

    TObject = record
        instruction: integer;
        opr: TOperand;
    end;

    TObjectArray = record
        arr: array[0..ARRAY_CAPACITY] of TObject;
        count: integer;
    end;

    TBlock = record
        lineNumber: integer;
        startAddress: integer;
        objectArray: TObjectArray;
    end;

    TBlockList = record
        start: array of TBlock;
        count: integer;
        capacity: integer;
    end;

function generateObjects(var stmtList: TStatementList): TBlockList;

implementation

function newList(): TBlockList; forward;
procedure append(var list: TBlockList; blck: TBlock); forward;
procedure pop(var list: TBlockList); forward;

procedure internalError(message: string);
begin
    writeLn('Internal error: Unexpected ', message);
end;

procedure initializeArray(var obj: TObjectArray);
begin
    obj.count := 0;
end;

function arrayAdd(var objectArray: TObjectArray; obj: TObject): boolean;
begin
    if objectArray.count < ARRAY_CAPACITY then begin
        objectArray.arr[objectArray.count] := obj;
        objectArray.count += 1;
        exit(false);
    end;
    
    writeLn('Internal error: TObjectArray capacity was exceeded.');
    writeLn('Count: ', objectArray.count);
    arrayAdd := true;
end;

function objectBuilder(instruction: integer; opr: TOperand): TObject;
begin
    objectBuilder.instruction := instruction;
    objectBuilder.opr := opr;
end;

function newOperand(operandType: TPossibleOperands; num: integer; chr: char): TOperand;
begin
    newOperand.value := operandType;
    case operandType of
        TPossibleOperands.constantOperand:
            newOperand.n := num;
        TPossibleOperands.idOperand:
            newOperand.c := chr;
    end;
end;

function compile(stmt: TStatement): TBlock;

var
    newObject: TObject;
    firstOperand: TOperand;
    secondOperand: TOperand;

begin
    compile.lineNumber := stmt.lineNumber;
    compile.startAddress := NO_ADDRESS;
    initializeArray(compile.objectArray);

    case stmt.reservedWord.value of
        // rem: ();
        statement.TPossibleWords.rem:
        begin
            // Create a empty object: the linker may
            // need the line number from this TObject.
            arrayAdd(compile.objectArray, objectBuilder(INST_NOOP, EMPTY_OPERAND));
        end;

        // input: (inputId: char);
        statement.TPossibleWords.input:
        begin
            arrayAdd(compile.objectArray, objectBuilder(
                INST_READ,
                newOperand(idOperand, 0, stmt.reservedWord.inputId)
            ));
        end;

        // let: (letId: char; letAssignment: TAssignment);
        statement.TPossibleWords.let:
        begin
            case stmt.reservedWord.letAssignment.value of
                TPossibleAssignment.assignmentOperand:
                begin
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_LOAD,
                        stmt.reservedWord.letAssignment.o
                    ));
                end;

                statement.TPossibleAssignment.assignmentAlgebraExpr:
                begin
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_LOAD,
                        stmt.reservedWord.letAssignment.expr.leftOperand
                    ));

                    newObject.opr := stmt.reservedWord.letAssignment.expr.rightOperand;
                    case stmt.reservedWord.letAssignment.expr.algebraExprOperator of
                        TAlgebraOperator.plus:
                            newObject.instruction := INST_ADD;
                        TAlgebraOperator.minus:
                            newObject.instruction := INST_SUBTRACT;
                        TAlgebraOperator.product:
                            newObject.instruction := INST_MULTIPLY;
                        TAlgebraOperator.division:
                            newObject.instruction := INST_DIVIDE;
                        TAlgebraOperator.modulo:
                            newObject.instruction := INST_MODULO;
                        TAlgebraOperator.algebraOperatorError:
                        begin
                            internalError('algebraOperatorError');
                            newObject.instruction := INST_NOOP;
                        end;
                    end;

                    arrayAdd(compile.objectArray, newObject);

                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_STORE,
                        newOperand(idOperand, 0, stmt.reservedWord.letId)
                    ));
                end;

                statement.TPossibleAssignment.assignmentError:
                    writeLn('Internal error: Unexpected assignmentError.');
            end;
        end;

        // print: (printId: char);
        statement.TPossibleWords.print:
        begin
            arrayAdd(compile.objectArray, objectBuilder(
                INST_WRITE,
                newOperand(idOperand, 0, stmt.reservedWord.printId)
            ));
        end;

        // gotoWord: (gotoData: TGoto);
        statement.TPossibleWords.gotoWord:
        begin
            arrayAdd(compile.objectArray, objectBuilder(
                INST_BRANCH,
                newOperand(constantOperand, stmt.reservedWord.gotoData.gotoConstant, 'E')
            ));
        end;

        // if_: (ifBooleanExpr: TBooleanExpr; thenData: TGoto);
        statement.TPossibleWords.if_:
        begin
            firstOperand := stmt.reservedWord.ifBooleanExpr.leftOperand;
            secondOperand := stmt.reservedWord.ifBooleanExpr.rightOperand;

            case stmt.reservedWord.ifBooleanExpr.booleanExprOperator of
                TBooleanOperator.greater, TBooleanOperator.greaterEqual:
                begin
                    firstOperand := stmt.reservedWord.ifBooleanExpr.rightOperand;
                    secondOperand := stmt.reservedWord.ifBooleanExpr.leftOperand;
                end;

                TBooleanOperator.booleanOperatorError:
                    internalError('booleanOperatorError');
            end;

            arrayAdd(compile.objectArray, objectBuilder(INST_LOAD, firstOperand));
            arrayAdd(compile.objectArray, objectBuilder(INST_SUBTRACT, secondOperand));

            case stmt.reservedWord.ifBooleanExpr.booleanExprOperator of
                TBooleanOperator.equality:
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHZERO,
                        newOperand(constantOperand, stmt.reservedWord.thenData.gotoConstant, 'E')
                    ));

                TBooleanOperator.inequality:
                begin
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHNEG,
                        newOperand(constantOperand, stmt.reservedWord.thenData.gotoConstant, 'E')
                    ));

                    arrayAdd(compile.objectArray, objectBuilder(INST_LOAD, secondOperand)); 
                    arrayAdd(compile.objectArray, objectBuilder(INST_SUBTRACT, firstOperand));

                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHNEG,
                        newOperand(constantOperand, stmt.reservedWord.thenData.gotoConstant, 'E')
                    ));
                end;

                TBooleanOperator.less, TBooleanOperator.greater:
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHNEG,
                        newOperand(constantOperand, stmt.reservedWord.thenData.gotoConstant, 'E')
                    ));

                TBooleanOperator.lessEqual, TBooleanOperator.greaterEqual:
                begin
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHNEG,
                        newOperand(constantOperand, stmt.reservedWord.thenData.gotoConstant, 'E')
                    ));

                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHZERO,
                        newOperand(constantOperand, stmt.reservedWord.thenData.gotoConstant, 'E')
                    ));
                end;
            end;
        end;

        // end_: ();
        statement.TPossibleWords.end_:
        begin
            arrayAdd(compile.objectArray, objectBuilder(INST_HALT, EMPTY_OPERAND));
        end;

        // wordError: ();
        statement.TPossibleWords.wordError:
        begin
            writeLn('Internal error: Unexpected wordError.');
        end;
    end;
end;

function newList(): TBlockList;
begin
    newList.count := 0;
    newList.capacity := DEFAULT_CAPACITY;
    setLength(newList.start, DEFAULT_CAPACITY);
end;

procedure append(var list: TBlockList; blck: TBlock);
begin
    //writeLn('capacity = ', list.capacity);
    if list.count >= list.capacity then
    begin
        setLength(list.start, list.capacity * 2);
        list.capacity *= 2;
    end;

    list.start[list.count] := blck;
    list.count += 1;
end;

procedure pop(var list: TBlockList);
begin
    if list.count > 0 then
        list.count -= 1;
end;

function generateObjects(var stmtList: TStatementList): TBlockList;

var
    i: integer;    

begin
    generateObjects := newList();
    for i := 0 to stmtList.count - 1 do
        append(generateObjects, compile(stmtList.start[i]));
end;

end.