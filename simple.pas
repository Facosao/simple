program simple;

uses
    token,
    scanner,
    statement,
    parser,
    symbols,
    semantic,
    objects,
    linker,
    assemble;

var
    sourceFile, outputFile: text;
    tokens: TTokenList;
    stmts: TStatementList;
    blockList: TBlockList;
    instructionList: TInstructionList;
    // semanticError: boolean;
    //i: integer;
    //c: char;

begin
    if paramCount() <> 2 then begin
        writeLn('Usage: ./simple [input_file_name] [output_file_name]');
        exit();
    end else begin
        assign(sourceFile, paramStr(1));
        reset(sourceFile);

        tokens := scanner.scanTokens(sourceFile);

        //for i := 0 to tokens.count - 1 do begin
        //    write(token.idToStr(tokens.start[i].id), ' ');
        //    case tokens.start[i].id of
        //        token.LF, token.START_TOKEN:
        //            write(#10);
        //    end;
        //end;
        //write(#10);

        stmts := parser.parse(tokens);

        //writeLn('----- VARIABLES');
        //for c := 'a' to 'z' do begin
        //    if c in symbols.variables then
        //        writeLn(c, ' is being used!');
        //end;
        //
        //writeLn('----- CONSTANTS');
        //for i := 0 to symbols.constantsCount - 1 do
        //    writeLn('constant = ', symbols.constants[i]);
        //
        //writeLn('----- LINES');
        //for i := 0 to symbols.linesCount - 1 do
        //    writeLn('line = ', symbols.lines[i]);

        semantic.analyze(stmts);
        //writeLn('semanticError = ', semanticError);

        if parser.hadError or semantic.hadError then begin
            write(#10);
            writeLn('Errors detected in source file.');
            writeLn('Compilation aborted.');
        end else begin
            writeLn('No errors detected in source file.');
            blockList := generateBlocks(stmts);
            instructionList := link(blockList);

            assign(outputFile, paramStr(2));
            rewrite(outputFile);
            assemble.writeFile(outputFile, instructionList);
            close(outputFile);
        end;

        close(sourceFile);
    end;
end.