unit scanner;

interface

uses
    sysutils,
    token,
    list;

type
    charPtr = ^char;

function scanTokens(var source: text): TList;
function number(var source: text; c: charPtr): integer;
function identifier(var source: text; c: charPtr): integer;

implementation

function scanTokens(var source: text): TList;

var
    line, column, return: integer;
    tokens: TList;
    c, previous: char;

begin
    line := 0;
    column := 0;
    tokens := list.init();
    previous := #0;

    while true do
    begin
        read(source, c);
        case c of
            '+':
                list.append(@tokens, token.PLUS);

            '-':
                list.append(@tokens, token.MINUS);

            '*':
                list.append(@tokens, token.PRODUCT);

            '/':
                list.append(@tokens, token.DIVISION);

            '%':
                list.append(@tokens, token.MODULO);
            
            '=':
                case previous of
                    #0:
                    begin
                        previous := '=';
                        continue;
                    end;

                    '=':
                        list.append(@tokens, token.EQUAL_EQUAL);

                    '!':
                        list.append(@tokens, token.BANG_EQUAL);

                    '>':
                        list.append(@tokens, token.GREATER_EQUAL);

                    '<':
                        list.append(@tokens, token.LESS_EQUAL);

                    else
                        list.append(@tokens, token.EQUAL);
                end;

            '0'..'9':
            begin
                return := number(source, @c);
                list.append(@tokens, token.CONSTANT);
            end;

            'a'..'z':
            begin
                return := identifier(source, @c);

                if return = -1 then
                    list.append(@tokens, token.ID);
            end;

            #10:
            begin
                list.append(@tokens, token.LF);
                line += 1;
                column := 0;
            end;

            #11, #13, ' ':         // \r, \t, ' '

            else
                writeLn('Unexpected character at position (', line, ', ', column, ').');
        end;

        column += 1;
        previous := #0;
    end; 

    scanTokens := tokens;
end;

function number(var source: text; c: charPtr): integer;

var
    buffer: string;
    bufPtr: integer;

begin
    bufPtr := 0;

    repeat
        case c^ of
            '0'..'9':
                buffer[bufPtr] := c^;
                //bufPtr += 1;

            else
                break;
        end;

        read(source, c^);
    until eof(source);

    number := sysutils.strToInt(buffer);
end;

function identifier(var source: text; c: charPtr): integer;

var
    buffer: string;
    bufPtr: integer;

begin
    bufPtr := 0;

    repeat
        case c^ of
            'a'..'z':
                buffer[bufPtr] := c^;
                bufPtr += 1;

            else
                break;
        end;

        read(source, c^);
    until eof(source);

    case buffer of
        'rem':
            identifier := token.REM;
        'input':
            identifier := token.INPUT;
        'let':
            identifier := token.LET;
        'print':
            identifier := token.PRINT;
        'if':
            identifier := token.IF_;
        'goto':
            identifier := token.GOTO_;
        'end':
            identifier := token.END_;
        else
            c^ := buffer[0];
            identifier := -1;
    end;
end;

end.