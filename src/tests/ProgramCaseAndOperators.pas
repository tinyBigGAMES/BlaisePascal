{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramCaseAndOperators;

type
  TColor = (clRed, clGreen = 5, clBlue = 6, clYellow);

var
  GColor: TColor;
  GValue: Integer;
  GResult: Integer;
  GFlag: Boolean;

begin
  WriteLn('=== ProgramCaseAndOperators ===');
  
  GValue := 10;
  WriteLn('GValue: ', GValue);
  
  // Case statement with integer
  case GValue of
    1: GResult := 100;
    2, 3: GResult := 200;
    4..10: GResult := 300;
  else
    GResult := 0;
  end;
  WriteLn('Case result (4..10 range): ', GResult);
  
  // Case statement with enum
  GColor := clBlue;
  case GColor of
    clRed: GResult := 1;
    clGreen: GResult := 2;
    clBlue: GResult := 3;
    clYellow: GResult := 4;
  end;
  WriteLn('Case result (clBlue): ', GResult);
  
  // More operators
  GResult := GValue mod 3;
  WriteLn('10 mod 3 = ', GResult);
  
  GResult := GValue div 2;
  WriteLn('10 div 2 = ', GResult);
  
  GResult := GValue shl 1;
  WriteLn('10 shl 1 = ', GResult);
  
  GResult := GValue shr 1;
  WriteLn('10 shr 1 = ', GResult);
  
  // Boolean operators
  GFlag := (GValue > 5) and (GValue < 20);
  WriteLn('(10 > 5) and (10 < 20) = ', GFlag);
  
  GFlag := (GValue = 0) or (GValue = 10);
  WriteLn('(10 = 0) or (10 = 10) = ', GFlag);
  
  GFlag := not GFlag;
  WriteLn('not True = ', GFlag);
  
  GResult := GValue and $FF;
  WriteLn('10 and $FF = ', GResult);
  
  GResult := GValue or $100;
  WriteLn('10 or $100 = ', GResult);
  
  GResult := GValue xor $55;
  WriteLn('10 xor $55 = ', GResult);
end.
