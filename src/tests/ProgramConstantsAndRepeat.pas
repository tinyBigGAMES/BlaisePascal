{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramConstantsAndRepeat;

const
  MAX_SIZE = 100;
  PI = 3.14159;
  APP_NAME = 'TestApp';
  FLAG = True;

type
  TPoint = record
    X: Integer;
    Y: Integer;
  end;

const
  ORIGIN: TPoint = (X: 0; Y: 0);
  DEFAULT_VALUES: array[0..2] of Integer = (10, 20, 30);

var
  GCounter: Integer;
  GSum: Integer;
  GValue: Integer;

begin
  WriteLn('=== ProgramConstantsAndRepeat ===');
  
  // Using constants
  GValue := MAX_SIZE;
  WriteLn('MAX_SIZE: ', GValue);
  WriteLn('PI: ', PI);
  WriteLn('APP_NAME: ', APP_NAME);
  
  GSum := 0;
  GCounter := 0;
  
  // Repeat-until loop
  repeat
    GSum := GSum + GCounter;
    GCounter := GCounter + 1;
  until GCounter >= 10;
  WriteLn('Sum after first repeat-until: ', GSum);
  WriteLn('Counter: ', GCounter);
  
  // Another repeat-until
  GValue := 1;
  repeat
    GValue := GValue * 2;
  until GValue > 100;
  WriteLn('Value after second repeat-until: ', GValue);
  
  WriteLn('ORIGIN: (', ORIGIN.X, ', ', ORIGIN.Y, ')');
  WriteLn('DEFAULT_VALUES[0]: ', DEFAULT_VALUES[0]);
  WriteLn('DEFAULT_VALUES[1]: ', DEFAULT_VALUES[1]);
  WriteLn('DEFAULT_VALUES[2]: ', DEFAULT_VALUES[2]);
end.
