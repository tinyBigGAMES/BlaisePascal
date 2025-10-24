{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramArrays;

type
  TIntArray = array[0..4] of Integer;
  TMatrix = array[0..1, 0..2] of Integer;

var
  GArray: TIntArray;
  GMatrix: TMatrix;
  GDynamic: array of Integer;
  GIndex: Integer;
  GSum: Integer;

begin
  WriteLn('=== ProgramArrays Test ===');
  
  // Static array initialization
  GArray[0] := 10;
  GArray[1] := 20;
  GArray[2] := 30;
  WriteLn('Initial GArray[0]: ', GArray[0]);
  WriteLn('Initial GArray[1]: ', GArray[1]);
  WriteLn('Initial GArray[2]: ', GArray[2]);
  
  // Array access
  GSum := GArray[0] + GArray[1];
  WriteLn('Sum (GArray[0] + GArray[1]): ', GSum);
  
  // Multi-dimensional array
  GMatrix[0, 0] := 1;
  GMatrix[0, 1] := 2;
  GMatrix[1, 2] := 3;
  WriteLn('GMatrix[0, 0]: ', GMatrix[0, 0]);
  WriteLn('GMatrix[0, 1]: ', GMatrix[0, 1]);
  WriteLn('GMatrix[1, 2]: ', GMatrix[1, 2]);
  
  // Dynamic array
  SetLength(GDynamic, 5);
  GDynamic[0] := 100;
  WriteLn('GDynamic[0]: ', GDynamic[0]);
  WriteLn('GDynamic Length: ', Length(GDynamic));
  
  // Array in loop
  for GIndex := 0 to 4 do
  begin
    GArray[GIndex] := GIndex * 10;
  end;
  
  WriteLn('After loop:');
  for GIndex := 0 to 4 do
  begin
    WriteLn('  GArray[', GIndex, ']: ', GArray[GIndex]);
  end;
  
  WriteLn('✓ All array tests passed');
end.
