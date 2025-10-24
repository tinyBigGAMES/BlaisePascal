{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramArrayCopy;

var
  LArr: array of Integer;
  LResult: array of Integer;
  LI: Integer;

begin
  WriteLn('=== Testing Array Copy with Range ===');
  WriteLn();
  
  { ============================================================================
    SETUP TEST ARRAY
    ============================================================================ }
  
  WriteLn('--- Setup Test Array ---');
  
  { Create array with test data }
  SetLength(LArr, 10);
  for LI := 0 to 9 do
    LArr[LI] := LI * 10;
  
  WriteLn('Source array:');
  for LI := 0 to 9 do
    WriteLn('  LArr[', LI, '] = ', LArr[LI]);
  
  WriteLn();
  
  { ============================================================================
    COPY FROM START
    ============================================================================ }
  
  WriteLn('--- Copy from Start ---');
  
  { Copy first 5 elements }
  LResult := Copy(LArr, 0, 5);
  WriteLn('Copy(LArr, 0, 5):');
  WriteLn('  Length = ', Length(LResult));
  for LI := 0 to High(LResult) do
    WriteLn('  LResult[', LI, '] = ', LResult[LI]);
  
  WriteLn();
  
  { ============================================================================
    COPY FROM MIDDLE
    ============================================================================ }
  
  WriteLn('--- Copy from Middle ---');
  
  { Copy 3 elements starting at index 4 }
  LResult := Copy(LArr, 4, 3);
  WriteLn('Copy(LArr, 4, 3):');
  WriteLn('  Length = ', Length(LResult));
  for LI := 0 to High(LResult) do
    WriteLn('  LResult[', LI, '] = ', LResult[LI]);
  
  WriteLn();
  
  { ============================================================================
    COPY TO END
    ============================================================================ }
  
  WriteLn('--- Copy to End ---');
  
  { Copy from index 7 to end (should get 3 elements) }
  LResult := Copy(LArr, 7, 10);
  WriteLn('Copy(LArr, 7, 10):');
  WriteLn('  Length = ', Length(LResult), ' (limited by array size)');
  for LI := 0 to High(LResult) do
    WriteLn('  LResult[', LI, '] = ', LResult[LI]);
  
  WriteLn();
  
  { ============================================================================
    EDGE CASES
    ============================================================================ }
  
  WriteLn('--- Edge Cases ---');
  
  { Copy with count = 0 }
  LResult := Copy(LArr, 0, 0);
  WriteLn('Copy(LArr, 0, 0):');
  WriteLn('  Length = ', Length(LResult), ' (empty array expected)');
  
  { Copy beyond array bounds }
  LResult := Copy(LArr, 20, 5);
  WriteLn('Copy(LArr, 20, 5):');
  WriteLn('  Length = ', Length(LResult), ' (empty array - out of bounds)');
  
  { Copy entire array }
  LResult := Copy(LArr, 0, Length(LArr));
  WriteLn('Copy(LArr, 0, ', Length(LArr), '):');
  WriteLn('  Length = ', Length(LResult), ' (full copy)');
  WriteLn('  First element: ', LResult[0]);
  WriteLn('  Last element: ', LResult[High(LResult)]);
  
  WriteLn();
  WriteLn('✓ Array Copy with range tested successfully');
end.
