unit parser;

interface

uses
    token,
    statement,
    symbols;

var
    hadError: boolean;

function parse(var _tokens: TTokenList): TStatementList;

implementation

const
    RESERVED_WORD_ERROR: TReservedWord = (
        value: wordError;
        inputId: 'E';
    );

    ID_ERROR: char = 'E';

    CONSTANT_ERROR: integer = -1;

    ALGEBRA_EXPR_ERROR: TAlgebraExpr = (
        leftOperand: (value: operandError; n: 0);
        algebraExprOperator: algebraOperatorError;
        rightOperand: (value: operandError; n: 0)
    );

    BOOLEAN_EXPR_ERROR: TBooleanExpr = (
        leftOperand: (value: operandError; n: 0);
        booleanExprOperator: booleanOperatorError;
        rightOperand: (value: operandError; n: 0);
    );

    OPERAND_ERROR: TOperand = (value: operandError; n: 0);

    ALGEBRA_OPERATOR_ERROR: TAlgebraOperator = algebraOperatorError;

    BOOLEAN_OPERATOR_ERROR: TBooleanOperator = booleanOperatorError;

    ASSIGNMENT_ERROR: TAssignment = (
        value: assignmentError;
        o: (
            value: operandError;
            n: 0;
        );
    );

var
    tokens: TTokenList;
    curToken: ^TToken;
    statements: TStatementList;
    stmtError: boolean;

// Parser functions
procedure hadStmtError(); forward;
procedure synchronize(); forward;
procedure advance(); forward;
function isAtEnd(): boolean; forward; 
function peek(): TToken; forward;
function peekNext(): TToken; forward;
function currentLine(): integer; forward;

// AST functions
function addStatement(): TStatement; forward;
function constant(): integer; forward;
function id(): char; forward;
function reservedWord(): TReservedWord; forward;
function goto_(): integer; forward;
function assignment(): TAssignment; forward;
function algebraExpr(): TAlgebraExpr; forward;
function booleanExpr(): TBooleanExpr; forward;
function operand(): TOperand; forward;
function algebraOperator: TAlgebraOperator; forward;
function booleanOperator(): TBooleanOperator; forward;
procedure lineFeed(); forward;

// ---------- IMPLEMENTATIONS ----------
function parse(var _tokens: TTokenList): TStatementList;

var
    newStmt: TStatement;

begin
    tokens := _tokens;
    curToken := @tokens.start[0];
    statements := statement.newList();
    hadError := false;
    stmtError := false;

    repeat
        newStmt := addStatement();
        statement.append(statements, newStmt);
        
        if stmtError then
            synchronize();
        
        stmtError := false;
    until isAtEnd();

    parse := parser.statements;
end;

function addStatement(): TStatement;
begin
    //writeLn('----- NEW STATEMENT! -----');
    addStatement.lineNumber := constant();

    if stmtError then
        // Skip ascending order semantic analysis
        addStatement.lineNumber := 9999;

    addStatement.sourceLine := currentLine();
    addStatement.reservedWord := reservedWord();
    lineFeed();

    //exit(addStatement);
end;

function constant(): integer;
begin
    if stmtError then
        exit(CONSTANT_ERROR);
    //writeLn('--- constant!');
    advance();

    if curToken^.id = token.CONSTANT then
    begin
        constant := curToken^.value;
        // insert value into line number array
    end
    else
    begin
        hadStmtError();
        writeLn('Expected CONSTANT, got ', token.idToStr(curToken^.id));
        constant := CONSTANT_ERROR;
    end;
end;

function reservedWord(): TReservedWord;
begin
    if stmtError then
        exit(RESERVED_WORD_ERROR);
    //writeLn('--- reserved word!');
    advance();

    case curToken^.id of
        token.REM:
            reservedWord.value := rem;
        
        token.INPUT:
        begin
            reservedWord.value := input;
            reservedWord.inputId := id();
        end;

        token.LET:
        begin
            reservedWord.value := let;
            reservedWord.letId := id();
            reservedWord.letAssignment := assignment();
        end;

        token.PRINT:
        begin
            reservedWord.value := print;
            reservedWord.printId := id();
        end;
        
        token.GOTO_:
        begin
            reservedWord.value := gotoWord;
            reservedWord.gotoData.gotoConstant := constant();
            reservedWord.gotoData.gotoLine := curToken^.line;
            reservedWord.gotoData.gotoColumn := curToken^.column;
        end;

        token.IF_:
        begin
            reservedWord.value := if_;
            reservedWord.ifBooleanExpr := booleanExpr();
            reservedWord.thenData.gotoConstant := goto_();
            reservedWord.thenData.gotoLine := curToken^.line;
            reservedWord.thenData.gotoColumn := curToken^.column;
        end;

        token.END_:
            reservedWord.value := end_;

        else
            hadStmtError();
            writeLn('Expected RESERVED WORD, got ', token.idToStr(curToken^.id));
    end;

    if stmtError then
        exit(RESERVED_WORD_ERROR);
end;

function id(): char;
begin
    if stmtError then
        exit(ID_ERROR);
    //writeLn('--- id!');
    advance();

    if curToken^.id = token.ID then
    begin
        id := chr(curToken^.value);
        //symbols.variables[id] := true;
        //writeLn('---- DEBUG VALUE   : ', curToken^.value);
        //writeLn('---- DEBUG VARIABLE: ', chr(curToken^.value));
        include(symbols.variables, chr(curToken^.value));
        //symbols.variables += [id];
    end
    else
    begin
        hadStmtError();
        writeLn('Expected ID, got ', token.idToStr(curToken^.id));
        id := ID_ERROR;
    end;
end;

function assignment(): TAssignment;
begin
    if stmtError then
        exit(ASSIGNMENT_ERROR);
    //writeLn('--- assignment!');
    advance();

    if curToken^.id <> token.EQUAL then
    begin
        hadStmtError();
        writeLn('Expected EQUALS, got ', token.idToStr(curToken^.id));
        exit(ASSIGNMENT_ERROR);
    end;

    case peekNext().id of
        token.PLUS, token.MINUS,
        token.PRODUCT, token.DIVISION, token.MODULO:
        begin
            assignment.value := assignmentAlgebraExpr;
            assignment.expr := algebraExpr();
        end;

        token.LF:
        begin
            assignment.value := assignmentOperand;
            assignment.o := operand();
        end;

        else
            hadStmtError();
            writeLn('Expected ASSIGNMENT EXPR, got ', token.idToStr(peekNext().id));
    end;
    
end;

function goto_(): integer;

var
    c: integer;

begin
    if stmtError then
        exit(CONSTANT_ERROR);
    //writeLn('--- goto!');
    advance();

    if curToken^.id = token.GOTO_ then
    begin
        c := constant();
        exit(c);
    end
    else
    begin
        hadStmtError();
        writeLn('Expected GOTO, got ', token.idToStr(curToken^.id));
        exit(CONSTANT_ERROR);
    end;
end;

function algebraExpr(): TAlgebraExpr;
begin
    if stmtError then
        exit(ALGEBRA_EXPR_ERROR);
    //writeLn('--- algebra expr!');
    algebraExpr.leftOperand := operand();
    algebraExpr.algebraExprOperator := algebraOperator();
    algebraExpr.rightOperand := operand();
end;

function booleanExpr(): TBooleanExpr;
begin
    if stmtError then
        exit(BOOLEAN_EXPR_ERROR);
    //writeLn('--- boolean expr!');
    booleanExpr.leftOperand := operand();
    booleanExpr.booleanExprOperator := booleanOperator();
    booleanExpr.rightOperand := operand();
end;

function operand(): TOperand;
begin
    if stmtError then
        exit(OPERAND_ERROR);

    //writeLn('--- operator!');
    advance();

    case curToken^.id of
        token.CONSTANT:
        begin
            operand.value := constantOperand;
            operand.n := curToken^.value;
            symbols.appendConstant(operand.n);
        end;

        token.ID:
        begin
            operand.value := idOperand;
            operand.c := chr(curToken^.value);
            //symbols.variables[operand.c] := true;
            include(symbols.variables, operand.c);
        end;

        else
            hadStmtError();
            writeLn('Expected OPERAND, got ', token.idToStr(curToken^.id));
            operand := OPERAND_ERROR;
    end;
end;

function algebraOperator(): TAlgebraOperator;
begin
    if stmtError then
        exit(ALGEBRA_OPERATOR_ERROR);

    //writeLn('--- algebra operator!');
    advance();

    case curToken^.id of
        token.PLUS:
            algebraOperator := plus;

        token.MINUS:
            algebraOperator := minus;

        token.PRODUCT:
            algebraOperator := product;

        token.DIVISION:
            algebraOperator := division;

        else
            hadStmtError();
            writeLn('Expected ALGEBRA OPERATOR, got ', token.idToStr(curToken^.id));
            exit(ALGEBRA_OPERATOR_ERROR);
    end;
end;

function booleanOperator(): TBooleanOperator;
begin
    if stmtError then
        exit(BOOLEAN_OPERATOR_ERROR);

    //writeLn('--- boolean operator!');
    advance();

    case curToken^.id of
        token.EQUAL_EQUAL:
            booleanOperator := equality;

        token.BANG_EQUAL:
            booleanOperator := inequality;

        token.GREATER:
            booleanOperator := greater;

        token.LESS:
            booleanOperator := less;

        token.GREATER_EQUAL:
            booleanOperator := greaterEqual;

        token.LESS_EQUAL:
            booleanOperator := lessEqual;

        else
            hadStmtError();
            writeLn('Expected BOOLEAN OPERATOR, got ', token.idToStr(curToken^.id));
            booleanOperator := BOOLEAN_OPERATOR_ERROR;
    end;
end;

procedure lineFeed();
begin
    if stmtError then
        exit();

    //writeLn('--- line feed!');
    advance();

    if (curToken^.id <> token.LF) and (not isAtEnd()) then
    begin
        hadStmtError();
        writeLn('Expected LF, got ', token.idToStr(curToken^.id));
    end
end;

procedure advance();
begin
    if isAtEnd() = false then
        curToken += 1;
end;

function isAtEnd(): boolean;
begin
    if curToken = @tokens.start[tokens.count - 1] then
        isAtEnd := true
    else
        isAtEnd := false;
end; 

procedure hadStmtError();
begin
    hadError := true;
    stmtError := true;
    write('Error at (', curToken^.line, ', ', curToken^.column, '): ');
end;

function peek(): TToken;
begin
    if (curToken + 1) >= @tokens.start[tokens.count - 1] then
        peek := curToken^
    else
        peek := (curToken + 1)^
    
end;

function peekNext(): TToken;
begin
    if (curToken + 2) >= @tokens.start[tokens.count - 1] then
        peekNext := curToken^
    else
        peekNext := (curToken + 2)^
end;

procedure synchronize();
begin
    while (curToken^.id <> token.LF) and (not isAtEnd()) do
        advance();
end;

function currentLine(): integer;
begin
    currentLine := curToken^.line;
end;

end.