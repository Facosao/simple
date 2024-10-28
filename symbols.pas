unit symbols;

interface

const
    UNUSED_VARIABLE = 16000;
    UNKNOWN_ADDRESS = 17000;

var
    variables: array['a'..'z'] of integer;
    constants: array of integer;
    constantsCount: integer;
    constantsCapacity: integer;

procedure appendConstant(n: integer);

implementation

const
    DEFAULT_CAPACITY = 8;

var
    c: char;

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

    for c := 'a' to 'z' do begin
        variables[c] := UNUSED_VARIABLE;
    end;
end;

end.