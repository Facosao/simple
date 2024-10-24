unit semantic;

interface

uses
    symbols,
    statement,
    parser;

// Returns 'true' if an error was found.
function analyze(var stmts: TStatementList): boolean;

implementation

function analyze(var stmts: TStatementList): boolean;

var
    lastLine, lineLabel, targetLine, targetColumn, i, j: integer;
    found: boolean;
begin
    analyze := false;

    // Check if all line labels are in ascending order
    lastLine := 0;

    for i := 0 to stmts.count - 1 do
    begin
        //writeLn('lastLine = ', lastLine);
        if lastLine = 0 then
            lastLine := stmts.start[i].lineNumber
        else
        begin
            if stmts.start[i].lineNumber <= lastLine then
            begin
                analyze := true;
                writeLn('Error at (', stmts.start[i].sourceLine,
                ', 1): Line label ', stmts.start[i].lineNumber,
                ' is not in ascending order.');
            end;
            
            lastLine := stmts.start[i].lineNumber;
        end;
    end;

    // Check if GOTO labels exist
    for i := 0 to stmts.count - 1 do
    begin
        case stmts.start[i].reservedWord.value of
            TPossibleWords.gotoWord:
            begin
                lineLabel := stmts.start[i].reservedWord.gotoData.gotoConstant;
                targetLine := stmts.start[i].reservedWord.gotoData.gotoLine;
                targetColumn := stmts.start[i].reservedWord.gotoData.gotoColumn;
            end;

            TPossibleWords.if_:
            begin
                lineLabel := stmts.start[i].reservedWord.thenData.gotoConstant;
                targetLine := stmts.start[i].reservedWord.thenData.gotoLine;
                targetColumn := stmts.start[i].reservedWord.thenData.gotoColumn;
            end;

            else
                continue;
        end;

        found := false;

        for j := 0 to stmts.count - 1 do begin
            if stmts.start[j].lineNumber = lineLabel then
                found := true;
        end;

        if not found then
        begin
            analyze := true;
            writeLn('Error at (', targetLine, ', ', targetColumn, '): ',
            'Line label ', lineLabel, ' was not declared.');
        end;
    end;

    // Check if a END exists
    for i := 0 to stmts.count - 1 do begin
        if stmts.start[i].reservedWord.value = end_ then
            exit();
    end;

    analyze := true;
    writeLn('Semantic error: END statement not found in source file.');
end;

end.