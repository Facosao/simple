unit scanner;

interface

uses
    sysutils,
    token;

type
    charPtr = ^char;

function scanTokens(var source: text): TTokenList;
function number(var source: text; c: charPtr; negative: boolean): integer;
function identifier(var source: text; c: charPtr): integer;

implementation

const
    CONSTANT_ERROR = 32000;
    IDENTIFIER_ERROR = 32001;
    SKIP_READ = 'S';

var
    line: integer = 1;
    column: integer = 1;
    columnBuffer: integer = 0;
    tokens: TTokenList;

procedure advanceTokenColumn();
begin
    column += columnBuffer;
    columnBuffer := 0;
end;

function newToken(tokenId: integer; tokenValue: integer): TToken;
begin
    newToken.id := tokenId;
    newToken.value := tokenValue;
    newToken.line := line;
    newToken.column := column;

    advanceTokenColumn();
end;

procedure lineFeed();
begin
    //writeLn('--- inside line feed!');
    token.append(tokens, newToken(token.LF, 0));
    line += 1;
    column := 1;
end;

function scanTokens(var source: text): TTokenList;

var
    return: integer;
    c, previous: char;

begin
    tokens := token.newList();
    token.append(tokens, newToken(token.START_TOKEN, 0));
    previous := #0;

    while true do
    begin
        if previous <> SKIP_READ then begin
            read(source, c);
            columnBuffer += 1;
        end;
        
        //writeLn('c = ', c, ', ord(c) = ', ord(c));
        case c of
            '+':
                token.append(tokens, newToken(token.PLUS, 0));

            '-':
            begin
                previous := '-';
                token.append(tokens, newToken(token.MINUS, 0));
                continue;
            end;

            '*':
                token.append(tokens, newToken(token.PRODUCT, 0));

            '/':
                token.append(tokens, newToken(token.DIVISION, 0));

            '%':
                token.append(tokens, newToken(token.MODULO, 0));

            '!':
            begin
                previous := '!';
                continue;
            end;
            
            '<':
            begin
                previous := '<';
                token.append(tokens, newToken(token.LESS, 0));
                continue;
            end;

            '>':
            begin
                previous := '>';
                token.append(tokens, newToken(token.GREATER, 0));
                continue;
            end;
            
            '=':
                case previous of
                    #0:
                    begin
                        previous := '=';
                        token.append(tokens, newToken(token.EQUAL, 0));
                        continue;
                    end;

                    '=':
                    begin
                        token.pop(tokens);
                        token.append(tokens, newToken(token.EQUAL_EQUAL, 0));
                    end;

                    '!':
                        token.append(tokens, newToken(token.BANG_EQUAL, 0));

                    '>':
                    begin
                        token.pop(tokens);
                        token.append(tokens, newToken(token.GREATER_EQUAL, 0));
                    end;

                    '<':
                    begin
                        token.pop(tokens);
                        token.append(tokens, newToken(token.LESS_EQUAL, 0));
                    end;
                end;

            '0'..'9':
            begin
                if previous = '-' then
                begin
                    token.pop(tokens);
                    return := number(source, @c, true);
                end
                else
                    return := number(source, @c, false);
                
                if return = CONSTANT_ERROR then
                    token.append(tokens, newToken(token.INVALID_CONSTANT, 0))
                else
                    token.append(tokens, newToken(token.CONSTANT, return));
                
                previous := SKIP_READ;
                continue; // Preserve last read character
            end;

            'a'..'z':
            begin
                //writeLn('id case = ', c, ', id ord  = ', ord(c));
                return := identifier(source, @c);

                case return of
                    IDENTIFIER_ERROR:
                        token.append(tokens, newToken(token.INVALID_IDENTIFIER, 0));

                    97..122: // ASCII letters a .. z
                        token.append(tokens, newToken(token.ID, return));

                    token.REM: begin
                        token.append(tokens, newToken(token.REM, 0));
                        
                        while (c <> #10) and (c <> #26) do
                            read(source, c);

                        //writeLn('---- rem line feed!');
                        lineFeed();
                        continue;
                    end;

                    else
                        token.append(tokens, newToken(return, 0));
                end;
                
                previous := SKIP_READ;
                continue; // Preserve last read character
            end;

            #10: // LF
            begin
                //writeLn('---- main loop line feed!');
                lineFeed();
            end;

            #11, #13, #32: // CR, TAB, SPACE
                repeat until true; // Empty statement

            #26: // EOF
                break;

            else
                token.append(tokens, newToken(token.INVALID_TOKEN, 0));
        end;

        previous := #0;
    end;

    scanTokens := tokens;
end;

function number(var source: text; c: charPtr; negative: boolean): integer;

var
    buffer: string[5] = '+0000';
    temp: string[5] = '00000';
    bufPtr: integer = 2;
    i: integer;

begin
    if negative then
        buffer[1] := '-';

    repeat
        case c^ of
            '0'..'9':
            begin
                if bufPtr <= 5 then begin
                    buffer[bufPtr] := c^;
                end;

                bufPtr += 1;
            end;

            else
                break;
        end;

        read(source, c^);
        //column += 1;
        columnBuffer += 1;
    //until eof(source);
    until false;

    //writeLn('buffer = ', buffer);

    if bufPtr <= 5 then
    begin
        temp := buffer;
        buffer := '00000';
        buffer[1] := temp[1];
        for i := 2 to bufPtr - 1 do
            buffer[6 - bufPtr + i] := temp[i];
    end;

    //writeLn('buffer = ', buffer);
    
    if bufPtr > 6 then
        number := CONSTANT_ERROR
    else
        number := sysutils.strToInt(buffer);
    
    //writeLn('number = ', number, 'bufPtr = ', bufPtr);
end;

function identifier(var source: text; c: charPtr): integer;

var
    buffer: string[5] = '     ';
    bufPtr: integer = 1;

begin
    repeat
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
                break;
        end;

        read(source, c^);
        //column += 1;
        columnBuffer += 1;
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
                identifier := IDENTIFIER_ERROR
            else
                identifier := ord(buffer[1]);
    end;
    //writeLn('buffer = ', buffer, ' identifier = ', identifier);
end;

end.