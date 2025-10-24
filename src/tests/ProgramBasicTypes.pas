{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramBasicTypes;
var
  VInt32: Integer;
  VInt64: Int64;
  VCard: Cardinal;
  VByte: Byte;
  VWord: Word;
  VBool: Boolean;
  VDouble: Double;
  VSingle: Single;
  VChar: Char;
  VString: String;
  VPointer: Pointer;
begin
  WriteLn('=== Testing Basic Types ===');
  
  VInt32 := -2147483648;
  WriteLn('Integer: ', VInt32);
  
  VInt64 := 9223372036854775807;
  WriteLn('Int64: ', VInt64);
  
  VCard := 4294967295;
  WriteLn('Cardinal: ', VCard);
  
  VByte := 255;
  WriteLn('Byte: ', VByte);
  
  VWord := 65535;
  WriteLn('Word: ', VWord);
  
  VBool := True;
  WriteLn('Boolean: ', VBool);
  
  VDouble := 3.14159265358979;
  WriteLn('Double: ', VDouble);
  
  VSingle := 2.71828;
  WriteLn('Single: ', VSingle);
  
  VChar := 'A';
  WriteLn('Char: ', VChar);
  
  VString := 'Hello';
  WriteLn('String: ', VString);
  
  VPointer := nil;
  WriteLn('Pointer is nil: ', VPointer = nil);
  
  WriteLn('✓ All basic types tested');
end.
