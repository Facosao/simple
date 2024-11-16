unit linker;

interface

uses
    symbols,
    statement,
    objects;

const
    INST_CONST = 19000;
    INST_VAR = 19001;

type
    TInstruction = record
        instruction: integer;
        operand: integer;
    end;

    TInstructionList = record
        start: array of TInstruction;
        count: integer;
        capacity: integer;
    end;

function link(var blocks: TBlockList): TInstructionList;

implementation

const
    DEFAULT_CAPACITY = 8;

function newInstruction(inst: integer; opr: integer): TInstruction; forward;
function findAddress(var blocks: TBlockList; gotoTarget: TOperand): integer; forward;
function findConstantIndex(constant: integer): integer; forward;
function newList(): TInstructionList; forward;
procedure append(var list: TInstructionList; inst: TInstruction); forward;

function link(var blocks: TBlockList): TInstructionList;

var
    c: char;
    addressCounter, i, j: integer;
    constantsAddresses: array[0..99] of integer;
    instList: TInstructionList;

begin
    instList := newList();
    addressCounter := 0;
    for i := 0 to 99 do begin
        constantsAddresses[i] := 0;
    end;

    // Map instructions to their respective memory address
    for i := 0 to blocks.count - 1 do begin
        blocks.start[i].startAddress := addressCounter;

        // Skip REM instruction
        if blocks.start[i].objectArray.arr[0].instruction <> INST_NOOP then
            addressCounter += blocks.start[i].objectArray.count;
    end;

    // Map constants to their respective memory address
    for i := 0 to symbols.constantsCount - 1 do begin
        constantsAddresses[i] := addressCounter;
        addressCounter += 1;
    end;

    // Map variables to their respective memory address
    for c := 'a' to 'z' do begin
        if symbols.variables[c] = symbols.UNKNOWN_ADDRESS then begin
            symbols.variables[c] := addressCounter;
            addressCounter += 1;
        end;
    end;

    // Write final data structure
    // -- Replace constant operands with their memory address
    // -- Replace ID operands with their memory address
    // -- Replace GOTO operands with their memory address

    for i := 0 to blocks.count - 1 do begin
        for j := 0 to blocks.start[i].objectArray.count - 1 do begin
            case blocks.start[i].objectArray.arr[j].instruction of
                INST_NOOP:
                    continue;

                INST_HALT:
                    append(instList, newInstruction(
                        INST_HALT,
                        0
                    ));

                INST_BRANCH, INST_BRANCHNEG, INST_BRANCHZERO:
                begin
                    if blocks.start[i].objectArray.arr[j].opr.n = INEQUALITY_OPERAND.n then
                        append(instList, newInstruction(
                            blocks.start[i].objectArray.arr[j].instruction,
                            blocks.start[i].startAddress + 4    
                        ))
                    else
                        append(instList, newInstruction(
                            blocks.start[i].objectArray.arr[j].instruction,
                            findAddress(
                                blocks,
                                blocks.start[i].objectArray.arr[j].opr
                            )
                        ));
                end;

                else
                begin
                    case blocks.start[i].objectArray.arr[j].opr.value of
                        constantOperand:
                        begin
                            append(instList, newInstruction(
                                blocks.start[i].objectArray.arr[j].instruction,
                                constantsAddresses[findConstantIndex(
                                    blocks.start[i].objectArray.arr[j].opr.n
                                )]
                            ));
                        end;
                    
                        idOperand:
                        begin
                            append(instList, newInstruction(
                                blocks.start[i].objectArray.arr[j].instruction,
                                symbols.variables[blocks.start[i].objectArray.arr[j].opr.c]
                            ));
                        end;

                        operandError:
                            writeLn('Internal error: linker operand error.');
                    end;
                end;
            end;
        end;
    end;

    // -- Write instructions with their respective operand
    // ----- Already done

    // -- Write constants with their signal preserved
    for i := 0 to symbols.constantsCount - 1 do begin
        append(instList, newInstruction(INST_CONST, symbols.constants[i]));
    end;

    // -- Write the initial value for variables
    for c := 'a' to 'z' do begin
        if symbols.variables[c] <> symbols.UNUSED_VARIABLE then
            case symbols.variablesInitialization[c] of
                UNINITIALIZED_VARIABLE, INITIALIZED_VARIABLE:
                    append(instList, newInstruction(
                        INST_VAR,
                        0
                    ))
                else
                    append(instList, newInstruction(
                        INST_VAR,
                        symbols.variablesInitialization[c]
                    ));
            end;
    end;

    link := instList;
end;

function newInstruction(inst: integer; opr: integer): TInstruction;
begin
    newInstruction.instruction := inst;
    newInstruction.operand := opr;
end;

function findAddress(var blocks: TBlockList; gotoTarget: TOperand): integer;

var
    i: integer;

begin
    // writeLn('TODO: Implement linker.findAddress!!!');
    // findAddress := 1;

    for i := 0 to blocks.count - 1 do begin
        if blocks.start[i].lineNumber = gotoTarget.n then
            exit(blocks.start[i].startAddress);
    end;
end;

function findConstantIndex(constant: integer): integer;

var
    i: integer;

begin
    for i := 0 to symbols.constantsCount - 1 do begin
        if symbols.constants[i] = constant then
            exit(i);
    end;

    exit(-1);
end;

function newList(): TInstructionList;
begin
    newList.count := 0;
    newList.capacity := DEFAULT_CAPACITY;
    setLength(newList.start, DEFAULT_CAPACITY);
end;

procedure append(var list: TInstructionList; inst: TInstruction);
begin
    //writeLn('capacity = ', list.capacity);
    if list.count >= list.capacity then
    begin
        setLength(list.start, list.capacity * 2);
        list.capacity *= 2;
    end;

    list.start[list.count] := inst;
    list.count += 1;
end;

end.
