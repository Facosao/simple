unit symbols;

interface

type
    TPossibleIdentifiers = set of 'a' .. 'z';

var
    variables: TPossibleIdentifiers;
    constants: array of integer;
    // lines: array of integer; // Redundant: Lines are part of a statement.
    constantsCount: integer;
    constantsCapacity: integer;
    // linesCount: integer;
    // linesCapacity: integer;

procedure appendConstant(n: integer);
// procedure appendLine(l: integer);

implementation

const
    DEFAULT_CAPACITY = 8;

procedure appendConstant(n: integer);

var
    i: integer;

begin
    if constantsCount > 0 then
        for i := 0 to constantsCount - 1 do
            if constants[i] = n then
                exit();

    if constantsCount >= constantsCapacity then
    begin
        setLength(constants, constantsCapacity * 2);
        constantsCapacity *= 2;
    end;

    constants[constantsCount] := n;
    constantsCount += 1;
end;

initialization
begin
    constantsCount := 0;
    constantsCapacity := DEFAULT_CAPACITY;
    setLength(constants, DEFAULT_CAPACITY);

    variables := [];
end;

end.