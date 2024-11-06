unit assemble;

interface

uses
    sysutils,
    linker;

procedure writeFile(var outputFile: text; var instructionList: TInstructionList);

implementation

procedure writeFile(var outputFile: text; var instructionList: TInstructionList);

var
    buffer: string[5];
    wordBuffer: string[2];
    i: integer;

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
