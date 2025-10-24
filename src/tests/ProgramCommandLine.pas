{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramCommandLine;

var
  LI: Integer;
  LCount: Integer;

begin
  WriteLn('=== Testing Command Line Parameters ===');
  WriteLn();
  
  { ============================================================================
    PARAMCOUNT
    ============================================================================ }
  
  WriteLn('--- ParamCount ---');
  
  LCount := ParamCount();
  WriteLn('ParamCount() = ', LCount);
  WriteLn();
  
  { ============================================================================
    PARAMSTR
    ============================================================================ }
  
  WriteLn('--- ParamStr ---');
  
  { Program name (index 0) }
  WriteLn('ParamStr(0) = "', ParamStr(0), '" (program name)');
  WriteLn();
  
  { All parameters }
  if LCount > 0 then
  begin
    WriteLn('Command line parameters:');
    for LI := 1 to LCount do
    begin
      WriteLn('  ParamStr(', LI, ') = "', ParamStr(LI), '"');
    end;
  end
  else
  begin
    WriteLn('No command line parameters provided.');
    WriteLn();
    WriteLn('Usage: Run this program with arguments to test ParamStr:');
    WriteLn('  ProgramCommandLine arg1 arg2 arg3');
  end;
  
  WriteLn();
  WriteLn('✓ Command line parameter functions tested successfully');
end.
