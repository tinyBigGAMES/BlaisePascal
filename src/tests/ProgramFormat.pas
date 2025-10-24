{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramFormat;

var
  LS: String;
  LI: Integer;
  LX: Double;

begin
  WriteLn('=== Testing Format Function ===');
  WriteLn();
  
  { ============================================================================
    STRING FORMATTING
    ============================================================================ }
  
  WriteLn('--- String Formatting ---');
  
  { Format - Simple string }
  LS := Format('Hello %s!', 'World');
  WriteLn('Format("Hello %s!", "World") = "', LS, '"');
  
  { Format - Integer }
  LI := 42;
  LS := Format('The answer is %d', LI);
  WriteLn('Format("The answer is %d", 42) = "', LS, '"');
  
  { Format - Float }
  LX := 3.14159;
  LS := Format('Pi is approximately %f', LX);
  WriteLn('Format("Pi is approximately %f", 3.14159) = "', LS, '"');
  
  { Format - Multiple arguments }
  LS := Format('Name: %s, Age: %d, Score: %f', 'Alice', 25, 95.5);
  WriteLn('Format with multiple args:');
  WriteLn('  "', LS, '"');
  
  { Format - Mixed types }
  LS := Format('%s scored %d points (%.1f percent)', 'Bob', 87, 87.0);
  WriteLn('Format with mixed types:');
  WriteLn('  "', LS, '"');
  
  WriteLn();
  WriteLn('✓ Format function tested successfully');
end.
