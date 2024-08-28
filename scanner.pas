unit scanner;

interface

uses
    token,
    list;

type
    TScanner = record
        start: integer;
        current: integer;
        line: integer;
        column: integer;
    end;

    PScanner = ^TScanner;

function scanTokens(source: text): TList;

implementation

function scanTokens(source: text): TList;

var
    scan: TScanner;
    tokens: TList;
    buffer: char;

begin
    scan.start := 0;
    scan.current := 0;
    scan.line := 0;
    scan.column := 0;

    tokens := list.init();
    
    // buffer
    while current <> EOF do
    begin
        scan.start := scan.current;
        case caractere of
            '+':
                list.insert(@tokens, token.PLUS);

            '-':
                list.insert(@tokens, token.MINUS);

            '*':
                list.insert(@tokens, token.PRODUCT);

            '/':
                list.insert(@tokens, token.DIVISION);

            '%':
                list.insert(@tokens, token.MODULO);
            
            '=':
                case previous of
                    0:
                    begin
                        previous := tokens.EQUAL;
                        continue;
                    end;

                    tokens.EQUAL:
                        list.insert(@tokens, token.EQUAL_EQUAL);

                    tokens.BANG:
                        list.insert(@tokens, token.BANG_EQUAL);

                    tokens.GREATER:
                        list.insert(@tokens, token.GREATER_EQUAL);

                    tokens.LESS:
                        list.insert(@tokens, token.LESS_EQUAL);
                end;
        end;

        previous := 0;
    end; 


end;

function scanToken(character: char, previous: integer): integer;

begin

    // need to advance character!!!
    // replace recursive call with a continue inside main loop
    

end;

end.