program simple;

uses
    scanner,
    token,
    statement,
    parser,
    symbols,
    semantic;

var
    sourceFile: text;
    tokens: TTokenList;
    stmts: TStatementList;
    semanticError: boolean;
    i: integer;
    c: char;

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

        for i := 0 to tokens.count - 1 do
        begin
            write(token.idToStr(tokens.start[i].id), ' ');
            if tokens.start[i].id = token.LF then
                write(#10);
        end;

        stmts := parser.parse(tokens);

        writeLn('----- VARIABLES');
        for c := 'a' to 'z' do
        begin
            if c in symbols.variables then
                writeLn(c, ' is being used!');
        end;
        
        writeLn('----- CONSTANTS');
        for i := 0 to symbols.constantsCount - 1 do
            writeLn('constant = ', symbols.constants[i]);
        
        writeLn('----- LINES');
        for i := 0 to symbols.linesCount - 1 do
            writeLn('line = ', symbols.lines[i]);

        semanticError := semantic.analyze(stmts);
        writeLn('semanticError = ', semanticError);

        if parser.hadError or semanticError then
        begin
            writeLn('Errors detected in source file.');
            writeLn('Compilation aborted.');
        end
        else
            writeLn('No errors detected in source file.');

        close(sourceFile);
    end;
end.