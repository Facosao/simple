unit symbols;

interface

type
    TSymbolList = record
        variables: array of boolean['a'..'z'];
        constants: array of integer;
    end;

function newList(): TSymbolList;
function appendVariable(var list: TSymbolList; v: char);
function appendConstant(var list: TSymbolList; n: integer);

implementation

const
    DEFAULT_CAPACITY = 8;

function newList(): TSymbolList;
var
    c: char;

begin
    newList.constants.count := 0;
    newList.constants.capacity := DEFAULT_CAPACITY;
    setLength(newList.constants.start, DEFAULT_CAPACITY);

    for c := 'a' to 'z' do
        newList.variables[c] = false;
end;

function appendConstant(var list: TSymbolList; n: integer);
begin
    if list.constants.count >= list.constants.capacity then
    begin
        setLength(list.constants.start, list.constants.capacity * 2);
        list.constants.capacity *= 2;
    end;

    list.constants.start[list.constants.count] := n;
    list.constants.count += 1;
end;