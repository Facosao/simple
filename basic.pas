unit basic;

interface

uses
    statement;

procedure printBasicBlocks(var stmts: TStatementList);

implementation

function findBranchTarget(var stmts: TStatementList; target: integer): integer;

var
    i: integer;

begin
    for i := 0 to stmts.count - 1 do begin
        if stmts.start[i].lineNumber = target then
            exit(i);
    end;

    exit(-1);
end;

procedure printBasicBlocks(var stmts: TStatementList);

var
    leaders: array[0..99] of integer;
    i, leaderCount: integer;

begin
    leaderCount := 0;

    // Identify leaders
    for i := 0 to stmts.count - 1 do begin
        if i = 0 then begin
            leaders[leaderCount] := i;
            leaderCount += 1;
        end;

        case stmts.start[i].reservedWord.value of
            if_, gotoWord:
            begin
                
            end;


        if stmts.start[i].reservedWord.value = if_ then begin
            leaders[leaderCount] := findBranchTarget(stmts, stmts.start[i].reservedWord.thenData.gotoOpr.n);
            leaderCount += 1;
        end;

    end;

end;

end.