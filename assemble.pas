unit assemble;

interface

uses
    sysutils,
    linker;

procedure writeFile(var outputFile: text; var instructionList: TInstructionList);

implementation

type
    ConstantString = string[5];

function leadingZeros(input: ConstantString): ConstantString;

var
    isNegative: boolean;
    start, i, size: integer;

begin
    leadingZeros := '+0000';
    size := Length(input);

    if input[1] = '-' then begin
        isNegative := true;
        start := 2;
    end else begin
        isNegative := false;
        start := 1;
    end;
    
    for i := 0 to size - 1 do
        leadingZeros[6 - size + (start - 1) + i] := input[start + i];

    if isNegative then
        leadingZeros[1] := '-';
end;

function min(a: integer; b: integer): integer;
begin
    if a < b then
        min := a
    else
        min := b;
end;

procedure writeFile(var outputFile: text; var instructionList: TInstructionList);

var
    buffer: string[5];
    wordBuffer: string[2];
    i: integer;

begin
    for i := 0 to min(instructionList.count - 1, 99) do begin
        buffer := '+0000';
        
        case instructionList.start[i].instruction of
            linker.INST_VAR, linker.INST_CONST:
            begin
                buffer := sysutils.IntToStr(instructionList.start[i].operand);
                buffer := leadingZeros(buffer);
            end;

            else // Actual valid executable instruction
            begin
                // Instruction itself, whose value is always >= 10 (no leading zeros)
                wordBuffer := '00';
                wordBuffer := sysutils.IntToStr(instructionList.start[i].instruction);
                buffer[2] := wordBuffer[1];
                buffer[3] := wordBuffer[2];
                
                // Instruction operand, which in rare cases may be < 10
                // May require a leading zero
                wordBuffer := '00';
                wordBuffer := sysutils.IntToStr(instructionList.start[i].operand);
                if Length(wordBuffer) = 1 then
                    buffer[5] := wordBuffer[1]
                else begin
                    buffer[4] := wordBuffer[1];
                    buffer[5] := wordBuffer[2];
                end;
            end;
        end;

        write(outputFile, buffer);
        write(outputFile, #10);
    end;
end;

end.
