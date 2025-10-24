{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramTestRunError;

{
  This test verifies that RunError properly terminates the program
  with the specified error code.
  
  Expected behavior:
  - Program prints initial message
  - RunError(42) is called
  - Program terminates with exit code 42
  - Final message should NOT be printed
  
  Test runner should verify:
  - Exit code = 42
  - Error message "Runtime error 42" appears on stderr
}

begin
  WriteLn('Testing RunError(42)...');
  WriteLn('Program should terminate immediately with error code 42.');
  
  RunError(42);
  
  { This line should never execute }
  WriteLn('ERROR: This message should never appear!');
end.
