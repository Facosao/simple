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
    i: integer;

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

        tokens := scanner.scanTokens(sourceFile);

        for i := 0 to tokens.count do
        begin
            write(token.idToStr(tokens.start[i].id), ' ');
            if tokens.start[i].id = token.LF then
                write(#10);
        end;

        stmts := parser.parse(tokens);

        close(sourceFile);
    end;
end.