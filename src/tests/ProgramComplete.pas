{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramComplete;

type
  TNode = record
    Data: Integer;
    Next: PNode;
  end;
  
  PNode = ^TNode;

function CreateNode(const AValue: Integer): PNode;
var
  LNode: PNode;
begin
  New(LNode);
  LNode^.Data := AValue;
  LNode^.Next := nil;
  Result := LNode;
end;

procedure AddNode(var AHead: PNode; const AValue: Integer);
var
  LNewNode: PNode;
begin
  LNewNode := CreateNode(AValue);
  LNewNode^.Next := AHead;
  AHead := LNewNode;
end;

function CountNodes(const AHead: PNode): Integer;
var
  LCurrent: PNode;
  LCount: Integer;
begin
  LCount := 0;
  LCurrent := AHead;
  
  while LCurrent <> nil do
  begin
    LCount := LCount + 1;
    LCurrent := LCurrent^.Next;
  end;
  
  Result := LCount;
end;

var
  GHead: PNode;
  GCount: Integer;
  GIndex: Integer;

begin
  WriteLn('=== ProgramComplete ===');
  
  GHead := nil;
  
  for GIndex := 1 to 5 do
  begin
    AddNode(GHead, GIndex * 10);
    WriteLn('Added node with value: ', GIndex * 10);
  end;
  
  GCount := CountNodes(GHead);
  WriteLn('Total nodes: ', GCount);
  
  if GCount > 0 then
  begin
    GIndex := GCount;
    WriteLn('Final GIndex: ', GIndex);
  end;
end.
