unit parser;

interface

uses
    token,
    statement;

function parse(var _tokens: TTokenList): TStatementList;

implementation

const
    STMT_ERROR: TStatement = (
        lineNumber: 0;
        reservedWord: (value: wordError)
    );

    CONSTANT_ERROR: integer = -1;

    RESERVED_WORD_ERROR: TReservedWord = (value: wordError);

    ID_ERROR: char = 'E';

    ALGEBRA_EXPR_ERROR: TAlgebraExpr = (
        leftOperand: (value: operandError);
        algebraExprOperator: algebraOperatorError;
        rightOperand: (value: operandError)
    );

    BOOLEAN_EXPR_ERROR: TBooleanExpr = (
        leftOperand: (value: operandError);
        booleanExprOperator: booleanOperatorError;
        rightOperand: (value: operandError)
    );

    //LET_ERROR: TLetTuple = (
    //    letId: 'E';
    //    letAssignment: (value: assignmentError);
    //);
    //
    //IF_ERROR: TIfTuple = (
    //    ifBooleanExpr: (
    //        leftOperand: (value: operandError);
    //        booleanOperator: booleanOperatorError;
    //        rightOperand: (value: operandError)
    //    );
    //    thenConstant: -1;
    //);

    OPERAND_ERROR: TOperand = (value: operandError);

    ALGEBRA_OPERATOR_ERROR: TAlgebraOperator = algebraOperatorError;

    BOOLEAN_OPERATOR_ERROR: TBooleanOperator = booleanOperatorError;

    ASSIGNMENT_ERROR: TAssignment = (
        value: assignmentError
    );

var
    tokens: TTokenList;
    curToken: ^TToken;
    statements: TStatementList;
    hadError: boolean;
    stmtError: boolean;

// Parser functions
procedure hadStmtError(); forward;
procedure synchronize(); forward;
function peek(): TToken; forward;
function peekNext(): TToken; forward;

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

    while curToken <> @tokens.start[tokens.count - 1] do
    begin
        newStmt := addStatement();
        
        if stmtError = false then
            statement.append(parser.statements, newStmt)
        else
            synchronize();
        

        stmtError := false;
    end;

    parse := parser.statements;
end;

function addStatement(): TStatement;
begin
    writeLn('----- NEW STATEMENT! -----');
    addStatement.lineNumber := constant();
    addStatement.reservedWord := reservedWord();
    lineFeed();

    if stmtError then
        exit(STMT_ERROR);

    exit(addStatement);
end;

function constant(): integer;
begin
    if stmtError then
        exit(CONSTANT_ERROR);
    writeLn('--- constant!');
    curToken += 1;

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
    writeLn('--- reserved word!');
    curToken += 1;

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
            //reservedWord.letTuple := (
            //    letId: id();
            //    assignment: assignment();
            //);
            reservedWord.letTuple.letId := id();
            reservedWord.letTuple.letAssignment := assignment();
        end;

        token.PRINT:
        begin
            reservedWord.value := print;
            reservedWord.printId := id();
        end;
        
        token.GOTO_:
        begin
            reservedWord.value := gotoWord;
            reservedWord.gotoConstant := constant();
        end;

        token.IF_:
        begin
            reservedWord.value := if_;
            //reservedWord.ifTuple = (
            //    ifBooleanExpr := booleanExpr();
            //    thenConstant := goto_();
            //);
            reservedWord.ifTuple.ifBooleanExpr := booleanExpr();
            reservedWord.ifTuple.thenConstant := goto_();
        end;

        token.END_:
            reservedWord.value := end_;

        else
            hadStmtError();
            writeLn('Expected RESERVED WORD, got ', token.idToStr(curToken^.id));
            reservedWord := RESERVED_WORD_ERROR;
    end;
end;

function id(): char;
begin
    if stmtError then
        exit(ID_ERROR);
    writeLn('--- id!');
    curToken += 1;

    if curToken^.id = token.ID then
    begin
        id := chr(curToken^.value);
        // mark id as used in variables array
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
    writeLn('--- assignment!');
    curToken += 1;

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
            assignment.value := leftConstant;
            assignment.c := constant();
        end;

        else
            hadStmtError();
            writeLn('Expected ASSIGNMENT EXPR, got ', token.idToStr(peekNext().id));
    end;
    
end;

function goto_(): integer;
begin
    if stmtError then
        exit(CONSTANT_ERROR);
    writeLn('--- goto!');
    curToken += 1;

    if curToken^.id = token.GOTO_ then
        exit(constant())
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
    writeLn('--- algebra expr!');
    algebraExpr.leftOperand := operand();
    algebraExpr.algebraExprOperator := algebraOperator();
    algebraExpr.rightOperand := operand();
end;

function booleanExpr(): TBooleanExpr;
begin
    if stmtError then
        exit(BOOLEAN_EXPR_ERROR);
    writeLn('--- boolean expr!');
    booleanExpr.leftOperand := operand();
    booleanExpr.booleanExprOperator := booleanOperator();
    booleanExpr.rightOperand := operand();
end;

function operand(): TOperand;
begin
    if stmtError then
        exit(OPERAND_ERROR);

    writeLn('--- operator!');
    curToken += 1;

    case curToken^.id of
        token.CONSTANT:
        begin
            operand.value := constantOperand;
            operand.n := curToken^.value;
        end;

        token.ID:
        begin
            operand.value := idOperand;
            operand.c := chr(curToken^.value);
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

    writeLn('--- algebra operator!');
    curToken += 1;

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

    writeLn('--- boolean operator!');
    curToken += 1;

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

    writeLn('--- line feed!');
    curToken += 1;

    if curToken^.id <> token.LF then
    begin
        hadStmtError();
        writeLn('Expected LF, got ', token.idToStr(curToken^.id));
    end
end;

procedure hadStmtError();
begin
    hadError := true;
    stmtError := true;
    write('Error at (', curToken^.line, ', ', curToken^.column, '): ');
end;

function peek(): TToken;
begin
    peek := (curToken + 1)^;
end;

function peekNext(): TToken;
begin
    peekNext := (curToken + 2)^;
end;

procedure synchronize();
begin
    while curToken^.id <> token.LF do
        curToken += 1;
end;

end.