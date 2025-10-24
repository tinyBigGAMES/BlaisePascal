{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramSizeOf;

type
  TPoint = record
    X: Integer;
    Y: Integer;
  end;
  
  TMyRecord = record
    A: Integer;
    B: Double;
    C: Char;
  end;

var
  LI: Integer;
  LSize: Integer;

begin
  WriteLn('=== Testing SizeOf Operator ===');
  WriteLn();
  
  { ============================================================================
    BASIC TYPES
    ============================================================================ }
  
  WriteLn('--- Basic Types ---');
  
  { SizeOf - Integer types }
  LSize := SizeOf(Byte);
  WriteLn('SizeOf(Byte) = ', LSize);
  
  LSize := SizeOf(Word);
  WriteLn('SizeOf(Word) = ', LSize);
  
  LSize := SizeOf(Integer);
  WriteLn('SizeOf(Integer) = ', LSize);
  
  LSize := SizeOf(Cardinal);
  WriteLn('SizeOf(Cardinal) = ', LSize);
  
  LSize := SizeOf(Int64);
  WriteLn('SizeOf(Int64) = ', LSize);
  
  WriteLn();
  
  { SizeOf - Floating point types }
  LSize := SizeOf(Single);
  WriteLn('SizeOf(Single) = ', LSize);
  
  LSize := SizeOf(Double);
  WriteLn('SizeOf(Double) = ', LSize);
  
  WriteLn();
  
  { SizeOf - Character types }
  LSize := SizeOf(Char);
  WriteLn('SizeOf(Char) = ', LSize);
  
  WriteLn();
  
  { SizeOf - Boolean }
  LSize := SizeOf(Boolean);
  WriteLn('SizeOf(Boolean) = ', LSize);
  
  WriteLn();
  
  { ============================================================================
    RECORD TYPES
    ============================================================================ }
  
  WriteLn('--- Record Types ---');
  
  { SizeOf - Custom record types }
  LSize := SizeOf(TPoint);
  WriteLn('SizeOf(TPoint) = ', LSize, ' (2 Integers)');
  
  LSize := SizeOf(TMyRecord);
  WriteLn('SizeOf(TMyRecord) = ', LSize, ' (Integer + Double + Char)');
  
  WriteLn();
  WriteLn('✓ SizeOf operator tested successfully');
end.
