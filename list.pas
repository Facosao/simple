unit list;

interface

type
    TNode = record
        item: integer;
        next: ^TNode;
    end;

    TList = record
        head: ^TNode;
        tail: ^TNode;
    end;

    PList = ^TList;

function init(): TList;

implementation

function init(): TList;
begin   
    new.head := nil;
    new.tail := nil;
end;

procedure append(list: PList, element: integer);

var
    newNode: ^TNode;

begin
    newNode := GetMem(sizeof(TNode));

    newNode^.item := element;
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