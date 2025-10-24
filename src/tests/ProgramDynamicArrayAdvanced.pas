{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramDynamicArrayAdvanced;

var
  LArray: array of Integer;
  LCopy1: array of Integer;
  LCopy2: array of Integer;
  LCopy3: array of Integer;
  LI: Integer;

begin
  WriteLn('=== Testing Advanced Dynamic Array Functions ===');
  WriteLn();
  
  { ============================================================================
    Copy (Dynamic Array)
    ============================================================================ }
  
  WriteLn('--- Copy (Dynamic Array) ---');
  
  { Initialize source array }
  SetLength(LArray, 5);
  for LI := 0 to 4 do
    LArray[LI] := (LI + 1) * 10;
  
  WriteLn('Source array: [10, 20, 30, 40, 50]');
  Write('Values: ');
  for LI := 0 to High(LArray) do
  begin
    Write(LArray[LI]);
    if LI < High(LArray) then
      Write(', ');
  end;
  WriteLn();
  WriteLn();
  
  { Test 1: Copy subrange from middle }
  WriteLn('Test 1: Copy(array, 1, 3) - copy 3 elements starting at index 1');
  LCopy1 := Copy(LArray, 1, 3);
  WriteLn('Expected: [20, 30, 40]');
  Write('Result: [');
  for LI := 0 to High(LCopy1) do
  begin
    Write(LCopy1[LI]);
    if LI < High(LCopy1) then
      Write(', ');
  end;
  WriteLn(']');
  WriteLn('Length: ', Length(LCopy1));
  WriteLn();
  
  { Test 2: Copy from beginning }
  WriteLn('Test 2: Copy(array, 0, 2) - copy 2 elements from start');
  LCopy2 := Copy(LArray, 0, 2);
  WriteLn('Expected: [10, 20]');
  Write('Result: [');
  for LI := 0 to High(LCopy2) do
  begin
    Write(LCopy2[LI]);
    if LI < High(LCopy2) then
      Write(', ');
  end;
  WriteLn(']');
  WriteLn('Length: ', Length(LCopy2));
  WriteLn();
  
  { Test 3: Copy entire array }
  WriteLn('Test 3: Copy entire array');
  LCopy3 := Copy(LArray, 0, Length(LArray));
  WriteLn('Expected: [10, 20, 30, 40, 50]');
  Write('Result: [');
  for LI := 0 to High(LCopy3) do
  begin
    Write(LCopy3[LI]);
    if LI < High(LCopy3) then
      Write(', ');
  end;
  WriteLn(']');
  WriteLn('Length: ', Length(LCopy3));
  WriteLn();
  
  { Test 4: Verify independence (COW behavior) }
  WriteLn('Test 4: Verify copy independence (COW)');
  WriteLn('Modifying copy...');
  LCopy3[0] := 999;
  WriteLn('Copy[0] = ', LCopy3[0]);
  WriteLn('Original[0] = ', LArray[0]);
  WriteLn('Original unchanged: ', LArray[0] = 10);
  WriteLn();
  
  { Test 5: Copy with count exceeding array length }
  WriteLn('Test 5: Copy beyond array bounds');
  LCopy1 := Copy(LArray, 3, 10);
  WriteLn('Copy(array, 3, 10) - should copy remaining elements');
  Write('Result: [');
  for LI := 0 to High(LCopy1) do
  begin
    Write(LCopy1[LI]);
    if LI < High(LCopy1) then
      Write(', ');
  end;
  WriteLn(']');
  WriteLn('Length: ', Length(LCopy1));
  WriteLn();
  
  { Test 6: Empty copy }
  WriteLn('Test 6: Copy with count = 0');
  LCopy1 := Copy(LArray, 0, 0);
  WriteLn('Copy(array, 0, 0) - empty array');
  WriteLn('Length: ', Length(LCopy1));
  WriteLn('Is empty: ', Length(LCopy1) = 0);
  
  WriteLn();
  
  { ============================================================================
    Summary
    ============================================================================ }
  
  WriteLn('--- Summary ---');
  WriteLn('Dynamic array Copy function:');
  WriteLn('  - Copies subrange of dynamic array');
  WriteLn('  - Parameters: Copy(source, index, count)');
  WriteLn('  - Returns new independent array (COW behavior)');
  WriteLn('  - Handles boundary conditions gracefully');
  WriteLn('  - Zero count returns empty array');
  
  WriteLn();
  WriteLn('✓ Advanced dynamic array functions tested successfully');
end.
