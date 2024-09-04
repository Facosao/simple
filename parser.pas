unit parser;

interface

uses
    token,
    statement;

function parse(var _tokens: TTokenList): integer;

implementation

const
    STMT_ERROR: TStatement = (
        lineNumber: 0;
        reservedWord: error;
    );

    CONSTANT_ERROR: integer = -1;

    RESERVED_WORD_ERROR: TReservedWord = (reservedWord: error);

    ID_ERROR: char = 'E'; // used in input() and print() 

    ALGEBRA_EXPR_ERROR: TAlgebraExpr = (
        leftOperand: (operand: error);
        operand: error;
        rightOperand: (operand: error);
    );

    BOOLEAN_EXPR_ERROR: TBooleanExpr = (
        leftOperand: (operand: error);
        operand: error;
        rightOperand (operand: error);
    );

    LET_ERROR: TLetTuple = (
        id: CHARACTER_ERROR;
        algebraExpr: ALGEBRA_EXPR_ERROR;
    );

    IF_ERROR: TIfTuple = (
        booleanExpr: BOOLEAN_EXPR_ERROR;
        gotoConstant: CONSTANT_ERROR;
    );

var
    tokens: TTokenList;
    curToken: ^TToken;
    statements: TStatementList;
    hadError: boolean;
    stmtError: boolean;

procedure stmtError(); forward;
procedure synchronize(); forward;
procedure peek(); forward;

function  addStatement(): TStatement; forward;
function  constant(): integer; forward;
function  id(): char; forward;
function  reservedWord(): TReservedWord; forward;
function  goto_(): integer; forward;
function  algebraExpr(): TAlgebraExpr; forward;
function  booleanExpr(): TBooleanExpr; forward;
procedure lineFeed(); forward;

function parse(var _tokens: TTokenList): TStatementList;

var
    newStmt: TStatement;

begin
    tokens := _tokens;
    curToken := @tokens.start[0];
    statements := statement.newList();
    hadError := false;
    stmtError := false;

    while parser.current^.tokenId <> token.FINAL_TOKEN do
    begin
        newStmt := addStatement(parser);
        
        if stmtError = false then
            statement.append(parser.statements, newStmt);
        else
            synchronize();

        stmtError = false;
    end;

    parse := parser.statements;
end;

function addStatement(): TStatement;
begin
    addStatement.lineNumber := constant();
    addStatement.reservedWord := reservedWord();

    if stmtError then
        exit(STMT_ERROR);

    exit(addStatement);
end;

function constant(): integer;
begin
    if stmtError then
        exit(CONSTANT_ERROR);

    if curToken^.id = token.CONSTANT then
    begin
        constant := curToken^.value;
        // insert value into line number array
    end
    else
    begin
        stmtError();
        writeLn('Expected CONSTANT, got ', token.idToStr(curToken^.id));
        constant := CONSTANT_ERROR;
    end;

    curToken += 1;
end;

function reservedWord(): TReservedWord;
begin
    if stmtError then
        exit(RESERVED_WORD_ERROR);

    case curToken^.id of
        token.REM:
            reservedWord.thisWord := rem;
        
        token.INPUT:
        begin
            reservedWord.thisWord := input;
            reservedWord.inputId := id();
        end;

        token.LET:
        begin
            reservedWord.thisWord := let;
            reservedWord.letTuple := (
                id: id();
                algebraExpr: algebraExpr();
            );
        end;

        token.PRINT:
        begin
            reservedWord.thisWord := print;
            reservedWord.printId := id();
        end;
        
        token.GOTO_:
        begin
            reservedWord.thisWord = goto_;
            reservedWord.gotoConstant = constant();
        end;

        token.IF_:
        begin
            reservedWord.thisWord := if_;
            reservedWord.ifTuple = (
                booleanExpr := booleanExpr();
                gotoConstant := goto_();
            );
        end;

        token.END_:
            reservedWord.thisWord := end_;

        else
            stmtError();
            writeLn('Expected RESERVED WORD, got ', token.idToStr(curToken^.id));
            reservedWord := RESERVED_WORD_ERROR;
    end;

    curToken += 1;
end;

function id(): char;
begin
    if stmtError then
        exit(ID_ERROR);

    curToken += 1;

    if curToken^.id = token.ID then
    begin
        id := curToken^.value;
        // mark id as used in variables array
    end
    else
    begin
        stmtError();
        writeLn('Expected ID, got ', token.idToStr(curToken^.id));
    end;
end;

function  goto_(): integer;
function  algebraExpr(): TAlgebraExpr;
function  booleanExpr(): TBooleanExpr;
procedure lineFeed();

procedure stmtError();
begin
    stmtError := true;
    write('Error at (', curToken^.line, ', ', curToken^.column, '): ');
end;

procedure synchronize();
begin

end;

end.