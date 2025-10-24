{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramTestHalt;

{
  This test verifies that Halt properly terminates the program
  with the specified exit code.
  
  Expected behavior:
  - Program prints initial message
  - Halt(7) is called
  - Program terminates with exit code 7
  - Final message should NOT be printed
  
  Test runner should verify:
  - Exit code = 7
  - Program terminated cleanly (no error messages)
}

begin
  WriteLn('Testing Halt(7)...');
  WriteLn('Program should terminate cleanly with exit code 7.');
  
  Halt(7);
  
  { This line should never execute }
  WriteLn('ERROR: This message should never appear!');
end.
