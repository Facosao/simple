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
    size := sysutils.strToInt(input);

    if input[1] = '-' then begin
        isNegative := true;
        start := 2;
    end else begin
        isNegative := false;
        start := 1;
    end;
    
    for i := 0 to size - 1 do begin
        leadingZeros[6 - size + i] := input[start + i]
    end;

    if isNegative then
        leadingZeros[1] := '-';
end;

procedure writeFile(var outputFile: text; var instructionList: TInstructionList);

var
    buffer: string[5];
    wordBuffer: string[2];

    i, j: integer;

begin
    for i := 0 to instructionList.count - 1 do begin
        buffer := '+0000';
        
        case instructionList.start[i].instruction of
            linker.INST_VAR:
                repeat until true; // Empty instruction

            linker.INST_CONST:
            begin
                // Figure out if one can read string[0] to figure out its size
                buffer := sysutils.IntToStr(abs(instructionList.start[i].operand));
                buffer := leadingZeros(buffer);
                
                if instructionList.start[i].operand < 0 then
                    buffer[1] := '-';
            end;

            else
            begin
                wordBuffer := '00';
                wordBuffer := sysutils.IntToStr(instructionList.start[i].instruction);
                buffer[2] := wordBuffer[1];
                buffer[3] := wordBuffer[2];
                
                wordBuffer := '00';
                wordBuffer := sysutils.IntToStr(instructionList.start[i].operand);
                buffer[4] := wordBuffer[1];
                buffer[5] := wordBuffer[2];
            end;
        end;

        write(outputFile, buffer);
        write(outputFile, #10);
    end;
end;

end.
