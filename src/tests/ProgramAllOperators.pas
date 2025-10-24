{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramAllOperators;
var
  A, B, R: Integer;
  F1, F2, FR: Double;
  S1, S2, SR: String;
  B1, B2, BR: Boolean;
  P: ^Integer;
  V: Integer;
begin
  WriteLn('=== Testing All Operators ===');
  
  A := 10;
  B := 3;
  
  WriteLn('--- Arithmetic Operators ---');
  R := A + B;
  WriteLn('10 + 3 = ', R);
  R := A - B;
  WriteLn('10 - 3 = ', R);
  R := A * B;
  WriteLn('10 * 3 = ', R);
  R := A div B;
  WriteLn('10 div 3 = ', R);
  R := A mod B;
  WriteLn('10 mod 3 = ', R);
  
  F1 := 10.0;
  F2 := 3.0;
  FR := F1 / F2;
  WriteLn('10.0 / 3.0 = ', FR);
  
  WriteLn('--- Comparison Operators ---');
  BR := A = B;
  WriteLn('10 = 3: ', BR);
  BR := A <> B;
  WriteLn('10 <> 3: ', BR);
  BR := A < B;
  WriteLn('10 < 3: ', BR);
  BR := A > B;
  WriteLn('10 > 3: ', BR);
  BR := A <= B;
  WriteLn('10 <= 3: ', BR);
  BR := A >= B;
  WriteLn('10 >= 3: ', BR);
  
  WriteLn('--- Logical Operators ---');
  B1 := True;
  B2 := False;
  BR := B1 and B2;
  WriteLn('True and False: ', BR);
  BR := B1 or B2;
  WriteLn('True or False: ', BR);
  BR := B1 xor B2;
  WriteLn('True xor False: ', BR);
  BR := not B1;
  WriteLn('not True: ', BR);
  
  WriteLn('--- Bitwise Operators ---');
  R := A and B;
  WriteLn('10 and 3 = ', R);
  R := A or B;
  WriteLn('10 or 3 = ', R);
  R := A xor B;
  WriteLn('10 xor 3 = ', R);
  R := not A;
  WriteLn('not 10 = ', R);
  R := A shl 2;
  WriteLn('10 shl 2 = ', R);
  R := A shr 2;
  WriteLn('10 shr 2 = ', R);
  
  WriteLn('--- String Operators ---');
  S1 := 'Hello';
  S2 := 'World';
  SR := S1 + ' ' + S2;
  WriteLn('String concat: ', SR);
  
  WriteLn('--- Pointer Operators ---');
  New(P);
  P^ := 100;
  WriteLn('Pointer dereference: ', P^);
  V := P^;
  WriteLn('Value from pointer: ', V);
  Dispose(P);
  
  V := 42;
  P := @V;
  WriteLn('Address-of value: ', P^);
  
  WriteLn('✓ All operators tested');
end.
