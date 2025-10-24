{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramWriteWriteLn;

var
  GCounter: Integer;
  GValue: Integer;
  GName: String;

begin
  // Test 1: Simple string output
  WriteLn('=== Write/WriteLn Test Suite ===');
  WriteLn;
  
  // Test 2: WriteLn with single string
  WriteLn('Test 1: Simple string output');
  
  // Test 3: Write without newline
  Write('Test 2: Write without newline... ');
  WriteLn('Done!');
  
  // Test 4: Multiple Write calls on same line
  Write('Test 3: ');
  Write('Multiple ');
  Write('writes ');
  WriteLn('completed');
  
  // Test 5: WriteLn with variable
  GCounter := 42;
  WriteLn('Test 4: Variable output: ', GCounter);
  
  // Test 6: WriteLn with multiple arguments
  GValue := 100;
  GName := 'NitroPascal';
  WriteLn('Test 5: Multiple args - Name: ', GName, ', Value: ', GValue);
  
  // Test 7: WriteLn with expression
  WriteLn('Test 6: Expression result: ', GCounter + GValue);
  
  // Test 8: Empty WriteLn (just newline)
  WriteLn;
  WriteLn('Test 7: Empty WriteLn above this line');
  
  // Test 9: Loop with WriteLn
  WriteLn;
  WriteLn('Test 8: Loop output');
  for GCounter := 1 to 5 do
  begin
    Write('  Iteration ');
    WriteLn(GCounter);
  end;
  
  // Test 10: Conditional output
  WriteLn;
  WriteLn('Test 9: Conditional output');
  if GValue > 50 then
    WriteLn('  Value is greater than 50')
  else
    WriteLn('  Value is 50 or less');
  
  // Final output
  WriteLn;
  WriteLn('=== All Tests Complete ===');
end.
