{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramRuntimeIntrinsics;

var
  LI: Integer;
  LJ: Integer;
  LCh: Char;
  LCh2: Char;
  LS: String;
  LS2: String;
  LS3: String;
  LPtr: Pointer;
  LIntPtr: ^Integer;
  LArr: array[0..9] of Byte;
  LArr2: array[0..9] of Byte;

begin
  WriteLn('=== Testing NitroPascal Runtime Intrinsics ===');
  WriteLn();
  
  { ============================================================================
    ORDINAL FUNCTIONS
    ============================================================================ }
  
  WriteLn('--- Ordinal Functions ---');
  
  { Ord - Get ordinal value }
  LCh := 'A';
  LI := Ord(LCh);
  WriteLn('Ord(''A'') = ', LI);
  
  LCh := 'Z';
  LI := Ord(LCh);
  WriteLn('Ord(''Z'') = ', LI);
  
  { Chr - Get character from ordinal }
  LCh := Chr(65);
  WriteLn('Chr(65) = ', LCh);
  
  LCh := Chr(90);
  WriteLn('Chr(90) = ', LCh);
  
  { Succ - Successor }
  LCh := 'A';
  LCh2 := Succ(LCh);
  WriteLn('Succ(''A'') = ', LCh2);
  
  LI := 10;
  LJ := Succ(LI);
  WriteLn('Succ(10) = ', LJ);
  
  { Pred - Predecessor }
  LCh := 'B';
  LCh2 := Pred(LCh);
  WriteLn('Pred(''B'') = ', LCh2);
  
  LI := 10;
  LJ := Pred(LI);
  WriteLn('Pred(10) = ', LJ);
  
  { Inc - Increment }
  LI := 5;
  Inc(LI);
  WriteLn('Inc(5) = ', LI);
  
  LI := 5;
  Inc(LI, 3);
  WriteLn('Inc(5, 3) = ', LI);
  
  { Dec - Decrement }
  LI := 10;
  Dec(LI);
  WriteLn('Dec(10) = ', LI);
  
  LI := 10;
  Dec(LI, 3);
  WriteLn('Dec(10, 3) = ', LI);
  
  WriteLn();
  
  { ============================================================================
    STRING MANIPULATION FUNCTIONS
    ============================================================================ }
  
  WriteLn('--- String Manipulation ---');
  
  { TrimLeft - Remove leading whitespace }
  LS := '  Hello  ';
  LS2 := TrimLeft(LS);
  WriteLn('TrimLeft("  Hello  ") = "', LS2, '"');
  
  { TrimRight - Remove trailing whitespace }
  LS := '  Hello  ';
  LS2 := TrimRight(LS);
  WriteLn('TrimRight("  Hello  ") = "', LS2, '"');
  
  { Trim - Remove leading and trailing whitespace }
  LS := '  Hello  ';
  LS2 := Trim(LS);
  WriteLn('Trim("  Hello  ") = "', LS2, '"');
  
  { Insert - Insert substring }
  LS := 'Hello World';
  Insert('Beautiful ', LS, 7);
  WriteLn('Insert("Beautiful ", "Hello World", 7) = "', LS, '"');
  
  { Delete - Delete substring }
  LS := 'Hello Beautiful World';
  Delete(LS, 7, 10);
  WriteLn('Delete("Hello Beautiful World", 7, 10) = "', LS, '"');
  
  { Pos - Find substring position }
  LS := 'Hello World';
  LI := Pos('World', LS);
  WriteLn('Pos("World", "Hello World") = ', LI);
  
  LI := Pos('xyz', LS);
  WriteLn('Pos("xyz", "Hello World") = ', LI);
  
  { Copy - Extract substring }
  LS := 'Hello World';
  LS2 := Copy(LS, 1, 5);
  WriteLn('Copy("Hello World", 1, 5) = "', LS2, '"');
  
  LS2 := Copy(LS, 7, 5);
  WriteLn('Copy("Hello World", 7, 5) = "', LS2, '"');
  
  WriteLn();
  
  { ============================================================================
    TYPE INFORMATION FUNCTIONS
    ============================================================================ }
  
  WriteLn('--- Type Information ---');
  
  { Assigned - Check if pointer is not nil }
  LPtr := nil;
  if Assigned(LPtr) then
    WriteLn('Assigned(nil pointer) = true')
  else
    WriteLn('Assigned(nil pointer) = false');
  
  New(LIntPtr);
  if Assigned(LIntPtr) then
    WriteLn('Assigned(allocated pointer) = true')
  else
    WriteLn('Assigned(allocated pointer) = false');
  Dispose(LIntPtr);
  
  { Length - Get length }
  LS := 'Hello';
  LI := Length(LS);
  WriteLn('Length("Hello") = ', LI);
  
  { High/Low - Array bounds }
  LI := Low(LArr);
  WriteLn('Low(array[0..9]) = ', LI);
  
  LI := High(LArr);
  WriteLn('High(array[0..9]) = ', LI);
  
  WriteLn();
  
  { ============================================================================
    MEMORY MANAGEMENT FUNCTIONS
    ============================================================================ }
  
  WriteLn('--- Memory Management ---');
  
  { GetMem/FreeMem - Allocate/free raw memory }
  GetMem(LPtr, 100);
  if Assigned(LPtr) then
    WriteLn('GetMem(ptr, 100): Memory allocated successfully');
  FreeMem(LPtr);
  WriteLn('FreeMem(ptr): Memory freed');
  
  { FillChar - Fill memory with value }
  FillChar(LArr, 10, 42);
  WriteLn('FillChar(array, 10, 42): Filled array with value 42');
  WriteLn('LArr[0] = ', LArr[0]);
  WriteLn('LArr[5] = ', LArr[5]);
  WriteLn('LArr[9] = ', LArr[9]);
  
  { Move - Copy memory }
  LArr[0] := 1;
  LArr[1] := 2;
  LArr[2] := 3;
  LArr[3] := 4;
  LArr[4] := 5;
  
  FillChar(LArr2, 10, 0);
  Move(LArr, LArr2, 5);
  WriteLn('Move(source, dest, 5): Copied 5 bytes');
  WriteLn('LArr2[0] = ', LArr2[0]);
  WriteLn('LArr2[1] = ', LArr2[1]);
  WriteLn('LArr2[2] = ', LArr2[2]);
  WriteLn('LArr2[3] = ', LArr2[3]);
  WriteLn('LArr2[4] = ', LArr2[4]);
  
  WriteLn();
  
  { ============================================================================
    PROGRAM CONTROL
    ============================================================================ }
  
  WriteLn('--- Program Control ---');
  
  { Halt - Terminate program (conditional test) }
  LI := 1;
  if LI = 0 then
    Halt(1);
  WriteLn('Halt(1): Conditional test passed (not executed)');
  
  WriteLn();
  WriteLn('✓ All runtime intrinsics tested successfully');
end.
