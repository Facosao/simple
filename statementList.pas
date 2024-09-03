program statementList;

//interface

const
    DEFAULT_CAPACITY = 2;

type
    TStatementList = record
        start: array of integer;
        count: integer;
        capacity: integer;
    end;

function init(): TStatementList;

var
    newList: TStatementList;

begin
    newList.count := 0;
    newList.capacity := DEFAULT_CAPACITY;
    setLength(newList.start, DEFAULT_CAPACITY);

    init := newList;
end;

procedure append(var list: TStatementList; item: integer);

begin
    writeLn('capacity = ', list.capacity);
    if list.count >= list.capacity then
    begin
        setLength(list.start, list.capacity * 2);
        list.capacity *= 2;
    end;

    list.start[list.count] := item;
    list.count += 1;
end;

var
    test: TStatementList;
    i: integer;

begin
    test := init();
    append(test, 1);
    append(test, 2);
    append(test, 3);
    append(test, 4);
    append(test, 5);

    writeLn('final count = ', test.count);
    writeLn('final capacity = ', test.capacity);

    for i := 0 to test.count - 1 do
        writeLn('value = ', test.start[i]);

end.
