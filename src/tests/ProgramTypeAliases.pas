{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramTypeAliases;
type
  TMyInt = Integer;
  TMyString = String;
  PInteger = ^Integer;
  PMyInt = ^TMyInt;
var
  V1: TMyInt;
  V2: TMyString;
  P1: PInteger;
  P2: PMyInt;
begin
  WriteLn('=== Testing Type Aliases ===');
  
  V1 := 42;
  WriteLn('TMyInt value: ', V1);
  
  V2 := 'Test';
  WriteLn('TMyString value: ', V2);
  
  New(P1);
  P1^ := 100;
  WriteLn('PInteger^ value: ', P1^);
  Dispose(P1);
  
  New(P2);
  P2^ := 200;
  WriteLn('PMyInt^ value: ', P2^);
  Dispose(P2);
  
  WriteLn('✓ All type aliases tested');
end.
