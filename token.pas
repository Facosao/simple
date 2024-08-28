unit token;

interface

const
    // Control characters
    LF = 10;
    EOF = 03;

    // Single character tokens
    PLUS = 21;
    MINUS = 22;
    PRODUCT = 23;
    DIVISION = 24;
    MODULO = 25;

    // One or two character tokens
    EQUAL = 11;
    EQUAL_EQUAL = 31;
    BANG = 30;
    BANG_EQUAL = 32;
    GREATER = 33;
    LESS = 34;
    GREATER_EQUAL = 35;
    LESS_EQUAL = 36;

    // Single letter identifier
    ID = 41;

    // Number (variable length)
    CONSTANT = 51;

    // Reserved words
    REM = 61;
    INPUT = 62;
    LET = 63;
    PRINT = 64;
    GOTO_ = 65;
    IF_ = 66;
    END_ = 67;