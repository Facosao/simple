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
    INST_MODULE = 34;

    // Control flow
    INST_BRANCH = 40;
    INST_BRANCHNEG = 41;
    INST_BRANCHZERO = 42;
    INST_HALT = 43;

    // Internal
    INST_NOOP = 60;

    // Basic
    DEFAULT_CAPACITY = 8;

type
    TAddressTarget = (constantAddress, idAddress, lineAddress);

    TObject = record
        instruction: integer;
        address: integer;
        addressTarget: TAddressTarget; 
    end;

    TBlock = record
        lineNumber: integer;
        startAddress: integer;
        objectArray: array[0..4] of TObject;
        count: integer;
    end;

    TBlockList = record
        start: array of TBlock;
        count: integer;
        capacity: integer;
    end;

function newList(): TBlockList;
procedure append(var list: TBlockList; blck: TBlock);
procedure pop(var list: TBlockList);

implementation

procedure internalError(message: string);
begin
    writeLn('Internal error: Unexpected ', message);
end;

function objectBuilder(instruction: integer; address: integer; addressTarget: TAddressTarget): TObject;
begin
    objectBuilder.instruction := instruction;
    objectBuilder.address := address;
    objectBuilder.addressTarget := addressTarget;
end;

function compile(stmt: TStatement): TBlock;

var
    newObject: TObject;

begin
    compile.lineNumber := stmt.lineNumber;
    compile.startAddress := -1;
    compile.count := 0;

    case stmt.reservedWord.value of
        // rem: ();
        statement.TPossibleWords.rem:
        begin
            // Create a empty object:
            // the linker may need the line number from this TObject.
            // exit(nil); Doesn't work!
        end;

        // input: (inputId: char);
        statement.TPossibleWords.input:
        begin
            newObject.instruction := INST_READ;
            newObject.address := ord(stmt.reservedWord.inputId) - 97;
            newObject.addressTarget := idAddress;

            compile.objectArray[compile.count] := newObject;
            compile.count += 1;
        end;

        // let: (letId: char; letAssignment: TAssignment);
        statement.TPossibleWords.let:
        begin
            case stmt.reservedWord.letAssignment.value of
                statement.TPossibleAssignment.assignmentOperand:
                begin
                    case stmt.reservedWord.letAssignment.o.value of
                        statement.TPossibleOperands.constantOperand:
                        begin
                            compile.objectArray[compile.count] := objectBuilder(
                                INST_READ,
                                stmt.reservedWord.letAssignment.o.n,
                                constantAddress
                            );
                            compile.count += 1;
                        end;

                        statement.TPossibleOperands.idOperand:
                        begin
                            compile.objectArray[compile.count] := objectBuilder(
                                INST_READ,
                                ord(stmt.reservedWord.letAssignment.o.c) - 97,
                                idAddress
                            );
                            compile.count += 1;
                        end;

                        statement.TPossibleOperands.operandError:
                            internalError('operandError');
                    end;
                end;

                statement.TPossibleAssignment.assignmentAlgebraExpr:
                begin
                    
                end;

                statement.TPossibleAssignment.assignmentError:
                begin
                    writeLn('Internal error: Unexpected assignmentError.');
                end;
            end;
        end;

        // print: (printId: char);
        statement.TPossibleWords.print:
        begin
            
        end;

        // gotoWord: (gotoData: TGoto);
        statement.TPossibleWords.gotoWord:
        begin
            
        end;

        // if_: (ifBooleanExpr: TBooleanExpr; thenData: TGoto);
        statement.TPossibleWords.if_:
        begin
            
        end;

        // end_: ();
        statement.TPossibleWords.end_:
        begin
            
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

end.