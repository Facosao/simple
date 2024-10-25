unit objects;

interface

uses
    statement;

// let a = b
// +20--b
// +21--a

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
    ARRAY_CAPACITY = 3;

type
    TAddressTarget = (constantAddress, idAddress, lineAddress);

    TObject = record
        instruction: integer;
        address: integer;
        addressTarget: TAddressTarget; 
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

function newList(): TBlockList;
procedure append(var list: TBlockList; blck: TBlock);
procedure pop(var list: TBlockList);
function generateObjects(var stmtList: TStatementList): TBlockList;

implementation

procedure internalError(message: string);
begin
    writeLn('Internal error: Unexpected ', message);
end;

function charToAddress(c: char): integer;
begin
    charToAddress := ord(c) - 97;
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
        arrayAdd := false;
    end;
    
    writeLn('Internal error: TObjectArray capacity was exceeded.');
    arrayAdd := true;
end;

function objectBuilder(instruction: integer; address: integer; addressTarget: TAddressTarget): TObject;
begin
    objectBuilder.instruction := instruction;
    objectBuilder.address := address;
    objectBuilder.addressTarget := addressTarget;
end;

function loadOperand(operand: TOperand): TObject;
begin
    loadOperand.instruction := INST_LOAD;

    case operand.value of
        TPossibleOperands.constantOperand:
        begin
            loadOperand.address := operand.n;
            loadOperand.addressTarget := constantAddress;
        end;

        TPossibleOperands.idOperand:
        begin
            loadOperand.address := charToAddress(operand.c);
            loadOperand.addressTarget := idAddress;
        end;

        TPossibleOperands.operandError:
        begin
            internalError('operandError');
            loadOperand.address := 0;
            loadOperand.addressTarget := constantAddress;
        end;
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
    // compile.count := 0;

    case stmt.reservedWord.value of
        // rem: ();
        statement.TPossibleWords.rem:
        begin
            // Create a empty object:
            // the linker may need the line number from this TObject.
            arrayAdd(compile.objectArray, objectBuilder(INST_NOOP, 0, lineAddress));
        end;

        // input: (inputId: char);
        statement.TPossibleWords.input:
        begin
            newObject.instruction := INST_READ;
            newObject.address := charToAddress(stmt.reservedWord.inputId);
            newObject.addressTarget := idAddress;

            // compile.objectArray[compile.count] := newObject;
            // compile.count += 1;

            arrayAdd(compile.objectArray, newObject);
        end;

        // let: (letId: char; letAssignment: TAssignment);
        statement.TPossibleWords.let:
        begin
            case stmt.reservedWord.letAssignment.value of
                TPossibleAssignment.assignmentOperand:
                begin
                    arrayAdd(compile.objectArray, loadOperand(stmt.reservedWord.letAssignment.o));
                end;

                statement.TPossibleAssignment.assignmentAlgebraExpr:
                begin
                    arrayAdd(compile.objectArray, loadOperand(stmt.reservedWord.letAssignment.expr.leftOperand));
                    newObject := loadOperand(stmt.reservedWord.letAssignment.expr.rightOperand);

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
                        charToAddress(stmt.reservedWord.letId),
                        idAddress
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
                charToAddress(stmt.reservedWord.printId),
                idAddress
            ));
        end;

        // gotoWord: (gotoData: TGoto);
        statement.TPossibleWords.gotoWord:
        begin
            arrayAdd(compile.objectArray, objectBuilder(
                INST_BRANCH,
                stmt.reservedWord.gotoData.gotoConstant,
                lineAddress
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

            arrayAdd(compile.objectArray, loadOperand(firstOperand));
            
            newObject := loadOperand(secondOperand);
            newObject.instruction := INST_SUBTRACT;
            arrayAdd(compile.objectArray, newObject);

            case stmt.reservedWord.ifBooleanExpr.booleanExprOperator of
                TBooleanOperator.equality:
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHZERO,
                        stmt.reservedWord.thenData.gotoConstant,
                        lineAddress
                    ));

                TBooleanOperator.inequality:
                begin
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHNEG,
                        stmt.reservedWord.thenData.gotoConstant,
                        lineAddress
                    ));

                    arrayAdd(compile.objectArray, loadOperand(secondOperand));

                    newObject := loadOperand(firstOperand);
                    newObject.instruction := INST_SUBTRACT;
                    arrayAdd(compile.objectArray, newObject);

                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHNEG,
                        stmt.reservedWord.thenData.gotoConstant,
                        lineAddress
                    ));
                end;

                TBooleanOperator.less, TBooleanOperator.greater:
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHNEG,
                        stmt.reservedWord.thenData.gotoConstant,
                        lineAddress
                    ));

                TBooleanOperator.lessEqual, TBooleanOperator.greaterEqual:
                begin
                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHNEG,
                        stmt.reservedWord.thenData.gotoConstant,
                        lineAddress
                    ));

                    arrayAdd(compile.objectArray, objectBuilder(
                        INST_BRANCHZERO,
                        stmt.reservedWord.thenData.gotoConstant,
                        lineAddress
                    ));
                end;
            end;
        end;

        // end_: ();
        statement.TPossibleWords.end_:
        begin
            arrayAdd(compile.objectArray, objectBuilder(
                INST_HALT,
                0,
                lineAddress
            ));
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