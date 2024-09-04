program simple;

uses
    scanner,
    token,
    statement,
    parser;

var
    sourceFile: text;
    tokens: TTokenList;
    stmts: TStatementList;

begin
    if paramCount() <> 1 then
    begin
        writeLn('Usage: ./simple [file_name]');
        exit();
    end
    else
    begin
        assign(sourceFile, paramStr(1));
        reset(sourceFile);

        //writeLn('arg = ', paramStr(1));
        //read(sourceFile, c);
        //writeLn('c = ', c);
        
        //while not eof(sourceFile) do
        //begin
        //    read(sourceFile, c);
        //    writeLn('c = ', c);
        //end;

        tokens := scanner.scanTokens(sourceFile);
        stmts := parser.parse(tokens);

        close(sourceFile);
    end;
end.