unit scanner;

interface

uses
    sysutils,
    token;

type
    charPtr = ^char;

function scanTokens(var source: text): TTokenList;
function number(var source: text; c: charPtr): integer;
function identifier(var source: text; c: charPtr): integer;

implementation

var
    line: integer = 1;
    column: integer = 0;
    tokens: TTokenList;

procedure lineFeed();
begin
    token.append(tokens, token.newToken(token.LF, 0, line, column));
    line += 1;
    column := 0;
end;

function scanTokens(var source: text): TTokenList;

var
    return: integer;
    c, previous: char;

begin
    tokens := token.newList();
    previous := #0;

    while true do
    begin
        read(source, c);
        column += 1;
        writeLn('c = ', c);
        case c of
            '+':
                token.append(tokens, token.newToken(
                    token.PLUS,
                    0,
                    line,
                    column
                ));

            '-':
                token.append(tokens, token.newToken(
                    token.MINUS,
                    0,
                    line,
                    column
                ));

            '*':
                token.append(tokens, token.newToken(
                    token.PRODUCT,
                    0,
                    line,
                    column
                ));

            '/':
                token.append(tokens, token.newToken(
                    token.DIVISION,
                    0,
                    line,
                    column
                ));

            '%':
                token.append(tokens, token.newToken(
                    token.MODULO,
                    0,
                    line,
                    column
                ));

            '!':
            begin
                previous := '!';
                continue;
            end;
            
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
                        token.append(tokens, token.newToken(
                            token.EQUAL_EQUAL,
                            0,
                            line,
                            column
                        ));

                    '!':
                        token.append(tokens, token.newToken(
                            token.BANG_EQUAL,
                            0,
                            line,
                            column
                        ));

                    '>':
                        token.append(tokens, token.newToken(
                            token.GREATER_EQUAL,
                            0,
                            line,
                            column
                        ));

                    '<':
                        token.append(tokens, token.newToken(
                            token.LESS_EQUAL,
                            0,
                            line,
                            column
                        ));

                    ' ':
                        token.append(tokens, token.newToken(
                            token.EQUAL,
                            0,
                            line,
                            column
                        ));
                end;

            ' ':
            begin
                case previous of
                    '<':
                        token.append(tokens, token.newToken(
                            token.LESS,
                            0,
                            line,
                            column
                        ));

                    '>':
                        token.append(tokens, token.newToken(
                            token.GREATER,
                            0,
                            line,
                            column
                        ));
                end;
            end;

            '0'..'9':
            begin
                return := number(source, @c);
                token.append(tokens, token.newToken(
                    token.CONSTANT,
                    return,
                    line,
                    column
                ));
            end;

            'a'..'z':
            begin
                return := identifier(source, @c);

                if return = -1 then
                    token.append(tokens, token.newToken(
                        token.ID,
                        ord(return),
                        line,
                        column
                    ))
                else
                    if return = token.REM then
                    begin
                        token.append(tokens, token.newToken(
                            token.REM,
                            0,
                            line,
                            column
                        ));
                        
                        while c <> #10 do
                            read(source, c);

                        lineFeed();
                        continue;
                    end
                    else
                        token.append(tokens, token.newToken(
                            return,
                            0,
                            line,
                            column
                        ));
            end;

            #10: // LF
                lineFeed();

            #11, #13: // CR, TAB
                repeat until true; // Empty statement

            #26: // EOF
                break;

            else
                writeLn('Unexpected character ', ord(c),
                        ' at position (', line, ', ', column, ').');
        end;

        previous := #0;
    end; 

    token.append(tokens, token.newToken(token.FINAL_TOKEN, 0, line, column));
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
                writeLn('Unexpected identifier ', buffer,
                        ' at (', line, ', ', column, ')');
            
            c^ := buffer[1];
            identifier := -1;
    end;
    writeLn('buffer = ', buffer, ' identifier = ', identifier);
end;

end.