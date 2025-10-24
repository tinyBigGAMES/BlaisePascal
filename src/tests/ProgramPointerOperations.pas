{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramPointerOperations;
type
  TData = record
    Value: Integer;
    Next: PData;
  end;
  
  PData = ^TData;

var
  P1, P2, P3: PData;
  V: Integer;
  Count: Integer;
begin
  WriteLn('=== Testing Pointer Operations ===');
  
  WriteLn('Allocating nodes...');
  New(P1);
  New(P2);
  
  WriteLn('Initializing linked list...');
  P1^.Value := 100;
  P1^.Next := P2;
  WriteLn('Node 1 value: ', P1^.Value);
  
  P2^.Value := 200;
  P2^.Next := nil;
  WriteLn('Node 2 value: ', P2^.Value);
  
  WriteLn('Traversing list...');
  P3 := P1;
  Count := 0;
  while P3 <> nil do
  begin
    Count := Count + 1;
    V := P3^.Value;
    WriteLn('Node ', Count, ': ', V);
    P3 := P3^.Next;
  end;
  WriteLn('Total nodes: ', Count);
  
  WriteLn('Deallocating...');
  Dispose(P2);
  Dispose(P1);
  
  P1 := nil;
  WriteLn('Pointer set to nil: ', P1 = nil);
  
  WriteLn('✓ Pointer operations tested');
end.
