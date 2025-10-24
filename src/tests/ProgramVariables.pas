{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramVariables;

var
  GValue: Integer;
  GName: string;
  GActive: Boolean;

begin
  GValue := 42;
  GName := 'Test';
  GActive := True;
  
  WriteLn('=== ProgramVariables ===');
  WriteLn('GValue: ', GValue);
  WriteLn('GName: ', GName);
  WriteLn('GActive: ', GActive);
end.
