{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramControlFlow;

var
  GValue: Integer;
  GCounter: Integer;
  GSum: Integer;

begin
  WriteLn('=== ProgramControlFlow ===');
  
  GValue := 10;
  WriteLn('Initial GValue: ', GValue);
  
  if GValue > 0 then
    GValue := GValue + 1
  else
    GValue := 0;
  WriteLn('After if-then-else: ', GValue);
  
  GCounter := 0;
  while GCounter < 5 do
  begin
    GCounter := GCounter + 1;
  end;
  WriteLn('After while loop: ', GCounter);
  
  GSum := 0;
  for GCounter := 1 to 10 do
  begin
    GSum := GSum + GCounter;
  end;
  WriteLn('Sum 1 to 10: ', GSum);
end.
