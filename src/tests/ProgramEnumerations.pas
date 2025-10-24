{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramEnumerations;
type
  TColor = (clRed, clGreen, clBlue);
  TSize = (szSmall = 10, szMedium = 20, szLarge = 30);
  TStatus = (stActive, stPaused = 100, stStopped);
  
var
  Color: TColor;
  Size: TSize;
  Status: TStatus;
  Value: Integer;
begin
  WriteLn('=== Testing Enumerations ===');
  
  WriteLn('--- Basic Enum (TColor) ---');
  Color := clRed;
  case Color of
    clRed: Value := 1;
    clGreen: Value := 2;
    clBlue: Value := 3;
  end;
  WriteLn('clRed -> ', Value);
  
  Color := clGreen;
  case Color of
    clRed: Value := 1;
    clGreen: Value := 2;
    clBlue: Value := 3;
  end;
  WriteLn('clGreen -> ', Value);
  
  WriteLn('--- Enum with Explicit Values (TSize) ---');
  Size := szSmall;
  case Size of
    szSmall: Value := 10;
    szMedium: Value := 20;
    szLarge: Value := 30;
  end;
  WriteLn('szSmall -> ', Value);
  
  Size := szMedium;
  case Size of
    szSmall: Value := 10;
    szMedium: Value := 20;
    szLarge: Value := 30;
  end;
  WriteLn('szMedium -> ', Value);
  
  WriteLn('--- Enum with Mixed Values (TStatus) ---');
  Status := stActive;
  case Status of
    stActive: Value := 1;
    stPaused: Value := 100;
    stStopped: Value := 101;
  end;
  WriteLn('stActive -> ', Value);
  
  Status := stPaused;
  case Status of
    stActive: Value := 1;
    stPaused: Value := 100;
    stStopped: Value := 101;
  end;
  WriteLn('stPaused -> ', Value);
  
  WriteLn('✓ Enumerations tested');
end.
