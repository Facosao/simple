unit list;

interface

uses token;

type
    TNode = record
        token: TokenType;
        next: ^TNode;
    end;

    TList = record
        head: ^TNode;
        tail: ^TNode;
    end;

    PList = ^TList;

function init(): TList;
procedure append(list: PList; token: TokenType);

implementation

function init(): TList;
begin   
    init.head := nil;
    init.tail := nil;
end;

procedure append(list: PList; token: TokenType);

var
    newNode: ^TNode;

begin
    writeLn('--- insert: ', token.tokenId, '---');
    newNode := GetMem(sizeof(TNode));

    newNode^.token := token;
    newNode^.next := nil;

    if list^.head = nil then
    begin
        list^.head := newNode;
        list^.tail := newNode;
    end
    else
    begin
        list^.tail^.next := newNode;
        list^.tail := newNode;
    end;
end;

end.