{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramArraySet;
var
  arr: array of Integer;
  s: set of 0..9;
  i: Integer;
begin
  // Test dynamic array
  SetLength(arr, 5);
  for i := 0 to 4 do
    arr[i] := i * 10;
  
  WriteLn('Array values:');
  for i := 0 to 4 do
    WriteLn('arr[', i, '] = ', arr[i]);
  
  WriteLn('Array length: ', Length(arr));
  WriteLn('Array high: ', High(arr));
  
  // Test set
  Include(s, 1);
  Include(s, 3);
  Include(s, 5);
  
  WriteLn('');
  WriteLn('Testing set membership:');
  WriteLn('1 in s: ', 1 in s);
  WriteLn('2 in s: ', 2 in s);
  WriteLn('3 in s: ', 3 in s);
  
  Exclude(s, 3);
  WriteLn('After Exclude(s, 3):');
  WriteLn('3 in s: ', 3 in s);
end.