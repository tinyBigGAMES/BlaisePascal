{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramParameterPassing;

procedure ByValue(AValue: Integer);
begin
  WriteLn('  ByValue - received: ', AValue);
  AValue := AValue + 1;
  WriteLn('  ByValue - modified: ', AValue);
end;

procedure ByConst(const AValue: Integer);
var
  LTemp: Integer;
begin
  WriteLn('  ByConst - received: ', AValue);
  LTemp := AValue + 1;
  WriteLn('  ByConst - local calc: ', LTemp);
end;

procedure ByVar(var AValue: Integer);
begin
  WriteLn('  ByVar - received: ', AValue);
  AValue := AValue + 1;
  WriteLn('  ByVar - modified: ', AValue);
end;

procedure ByOut(out AValue: Integer);
begin
  AValue := 42;
  WriteLn('  ByOut - set to: ', AValue);
end;

var
  V: Integer;
begin
  WriteLn('=== Testing Parameter Passing ===');
  
  V := 10;
  WriteLn('Initial value: ', V);
  
  WriteLn('Calling ByValue:');
  ByValue(V);
  WriteLn('After ByValue: ', V);
  
  WriteLn('Calling ByConst:');
  ByConst(V);
  WriteLn('After ByConst: ', V);
  
  WriteLn('Calling ByVar:');
  ByVar(V);
  WriteLn('After ByVar: ', V);
  
  WriteLn('Calling ByOut:');
  ByOut(V);
  WriteLn('After ByOut: ', V);
  
  WriteLn('✓ All parameter passing modes tested');
end.
