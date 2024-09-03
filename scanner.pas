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

var
    line: integer = 1;
    column: integer = 0;
    tokens: TList;

procedure lineFeed();
begin
    list.append(@tokens, token.LF);
    line += 1;
    column := 1;
end;

function scanTokens(var source: text): TList;

var
    return: integer;
    c, previous: char;

begin
    tokens := list.init();
    previous := #0;

    while true do
    begin
        read(source, c);
        writeLn('c = ', c);
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
            
            '<':
            begin
                previous := '<';
                continue;
            end;

            '>':
            begin
                previous := '>';
                continue;
            end;
            
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

                    ' ':
                        list.append(@tokens, token.EQUAL);
                end;

            ' ':
            begin
                case previous of
                    '<':
                        list.append(@tokens, token.LESS);

                    '>':
                        list.append(@tokens, token.GREATER);
                end;
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
                    list.append(@tokens, token.ID)
                else
                    if return = token.REM then
                    begin
                        list.append(@tokens, token.REM);
                        
                        while c <> #10 do
                            read(source, c);

                        lineFeed();
                        continue;
                    end
                    else
                        list.append(@tokens, return);
            end;

            #10: // LF
                lineFeed();

            #11, #13: // CR, TAB
                repeat until true; // Empty statement

            #26: // EOF
                break;

            else
                writeLn('Unexpected character ', ord(c), ' at position (', line, ', ', column, ').');
        end;

        column += 1;
        previous := #0;
    end; 

    scanTokens := tokens;
end;

function number(var source: text; c: charPtr): integer;

var
    buffer: string[5] = '00000';
    temp: string[5] = '00000';
    bufPtr: integer = 1;
    i: integer;
    //temp: char;

begin
    repeat
        //writeLn('n = ', c^, ', bufPtr = ', bufPtr, ', buffer = ', buffer);
        case c^ of
            '0'..'9':
            begin
                //writeLn('valid digit!');
                if bufPtr <= 5 then
                begin
                    buffer[bufPtr] := c^;
                    bufPtr += 1;
                end;
            end;

            else
                //writeLn('break loop!');
                if c^ = #10 then
                    lineFeed();
                break;
        end;

        read(source, c^);
        column += 1;
    //until eof(source);
    until false;

    writeLn('buffer = ', buffer);

    if bufPtr <= 5 then
    begin
        temp := buffer;
        buffer := '00000';
        for i := 1 to bufPtr - 1 do
            buffer[6 - bufPtr + i] := temp[i];
    end;

    writeLn('buffer = ', buffer);
    
    //number := 5;
    number := sysutils.strToInt(buffer);
    writeLn('number = ', number);
end;

function identifier(var source: text; c: charPtr): integer;

var
    buffer: string[5] = '     ';
    bufPtr: integer = 1;

begin
    repeat
        //writeLn('buffer = ', buffer, ' bufPtr = ', bufPtr, ' c = ', c^);
        case c^ of
            'a'..'z':
            begin
                if bufPtr <= 5 then
                begin
                    buffer[bufPtr] := c^;
                    bufPtr += 1;
                end;
            end;

            else
                if c^ = #10 then
                    lineFeed();

                break;
        end;

        read(source, c^);
        column += 1;
    //until eof(source);
    until false;

    case buffer of
        'rem  ':
            identifier := token.REM;
        'input':
            identifier := token.INPUT;
        'let  ':
            identifier := token.LET;
        'print':
            identifier := token.PRINT;
        'if   ':
            identifier := token.IF_;
        'goto ':
            identifier := token.GOTO_;
        'end  ':
            identifier := token.END_;
        else
            if bufPtr > 2 then
                writeLn('Unexpected identifier ', buffer, ' at (', line, ', ', column, ')');
            
            c^ := buffer[1];
            identifier := -1;
    end;
    writeLn('buffer = ', buffer, ' identifier = ', identifier);
end;

end.