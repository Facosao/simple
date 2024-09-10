unit token;

interface

uses sysutils;

const
    // Control characters
    LF = 10;
    EOF = 03;

    // Single character tokens
    PLUS = 21;
    MINUS = 22;
    PRODUCT = 23;
    DIVISION = 24;
    MODULO = 25;

    // One or two character tokens
    EQUAL = 11;
    EQUAL_EQUAL = 31;
    BANG_EQUAL = 32;
    GREATER = 33;
    LESS = 34;
    GREATER_EQUAL = 35;
    LESS_EQUAL = 36;

    // Single letter identifier
    ID = 41;

    // Number (variable length)
    CONSTANT = 51;

    // Reserved words
    REM = 61;
    INPUT = 62;
    LET = 63;
    PRINT = 64;
    GOTO_ = 65;
    IF_ = 66;
    END_ = 67;

    // Special control tokens
    START_TOKEN = 99;
    FINAL_TOKEN = 100;

    INVALID_TOKEN = 98;
    INVALID_CONSTANT = 101;
    INVALID_IDENTIFIER = 102;

    DEFAULT_CAPACITY = 8;

type
    TToken = record
        id: integer;
        value: integer;
        line: integer;
        column: integer;
    end;

    TTokenList = record
        start: array of TToken;
        count: integer;
        capacity: integer;
    end;

function newList(): TTokenList;
procedure append(var list: TTokenList; token: TToken);
procedure pop(var list: TTokenList);
function idToStr(idValue: integer): string;

implementation

function newList(): TTokenList;
begin
    newList.count := 0;
    newList.capacity := DEFAULT_CAPACITY;
    setLength(newList.start, DEFAULT_CAPACITY);
end;

procedure append(var list: TTokenList; token: TToken);

begin
    //writeLn('capacity = ', list.capacity);
    if list.count >= list.capacity then
    begin
        setLength(list.start, list.capacity * 2);
        list.capacity *= 2;
    end;

    list.start[list.count] := token;
    list.count += 1;
end;

procedure pop(var list: TTokenList);
begin
    if list.count > 0 then
        list.count -= 1;
end;

function idToStr(idValue: integer): string;
begin
    case idValue of
        LF:
            idToStr := 'LINE FEED';
        EOF:
            idToStr := 'END OF FILE';
        PLUS, MINUS, PRODUCT, DIVISION, MODULO:
            idToStr := 'ALGEBRA OPERATOR';
        EQUAL:
            idToStr := 'ASSIGNMENT';
        EQUAL_EQUAL, BANG_EQUAL, GREATER, LESS, GREATER_EQUAL, LESS_EQUAL:
            idToStr := 'BOOLEAN OPERATOR';
        ID:
            idToStr := 'IDENTIFIER';
        CONSTANT:
            idToStr := 'CONSTANT';
        REM:
            idToStr := 'REM';
        INPUT:
            idToStr := 'INPUT';
        LET:
            idToStr := 'LET';
        PRINT:
            idToStr := 'PRINT';
        IF_:
            idToStr := 'IF';
        END_:
            idToStr := 'END';
        GOTO_:
            idToStr := 'GOTO';
        START_TOKEN:
            idToStr := 'START TOKEN';
        FINAL_TOKEN:
            idToStr := 'FINAL TOKEN';
        INVALID_TOKEN:
            idToStr := 'INVALID TOKEN';
        INVALID_CONSTANT:
            idToStr := 'INVALID CONSTANT';
        INVALID_IDENTIFIER:
            idToStr := 'INVALID IDENTIFIER';
        else
            idToStr := sysutils.IntToStr(idValue);
    end;
end;

end.