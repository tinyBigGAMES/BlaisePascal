{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramTestAbort;

{
  This test verifies that Abort properly terminates the program
  with abnormal termination.
  
  Expected behavior:
  - Program prints initial message
  - Abort() is called
  - Program terminates abnormally (typically with exit code 3 on Windows, varies by OS)
  - Final message should NOT be printed
  
  Test runner should verify:
  - Program terminated abnormally (non-zero exit code)
  - Program did not complete normally
}

begin
  WriteLn('Testing Abort()...');
  WriteLn('Program should terminate abnormally immediately.');
  
  Abort();
  
  { This line should never execute }
  WriteLn('ERROR: This message should never appear!');
end.
