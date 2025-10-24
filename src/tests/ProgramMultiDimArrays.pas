{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramMultiDimArrays;
var
  Matrix: array[0..2, 0..2] of Integer;
  Cube: array[0..1, 0..1, 0..1] of Integer;
  I, J, K: Integer;
  Sum: Integer;
begin
  WriteLn('=== Testing Multi-Dimensional Arrays ===');
  
  WriteLn('--- 2D Array (3x3 Matrix) ---');
  for I := 0 to 2 do
    for J := 0 to 2 do
      Matrix[I, J] := I * 3 + J;
  
  for I := 0 to 2 do
  begin
    for J := 0 to 2 do
    begin
      WriteLn('Matrix[', I, ',', J, '] = ', Matrix[I, J]);
    end;
  end;
  
  WriteLn('--- 3D Array (2x2x2 Cube) ---');
  for I := 0 to 1 do
    for J := 0 to 1 do
      for K := 0 to 1 do
        Cube[I, J, K] := I * 4 + J * 2 + K;
  
  Sum := 0;
  for I := 0 to 1 do
    for J := 0 to 1 do
      for K := 0 to 1 do
      begin
        WriteLn('Cube[', I, ',', J, ',', K, '] = ', Cube[I, J, K]);
        Sum := Sum + Cube[I, J, K];
      end;
  
  WriteLn('Sum of all cube elements: ', Sum);
  WriteLn('✓ Multi-dimensional arrays tested');
end.
