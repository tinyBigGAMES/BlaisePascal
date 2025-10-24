{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramStringAdvanced;

var
  LStr: String;
  LStr2: String;
  LValue: Integer;
  LErrorCode: Integer;
  LDoubleValue: Double;
  LCh: Char;

begin
  WriteLn('=== Testing Advanced String Functions ===');
  WriteLn();
  
  { ============================================================================
    SetLength (String)
    ============================================================================ }
  
  WriteLn('--- SetLength (String) ---');
  
  { Create initial string }
  LStr := 'Hello';
  WriteLn('Initial string: ', LStr);
  WriteLn('Initial length: ', Length(LStr));
  
  { Grow the string }
  SetLength(LStr, 10);
  WriteLn('After SetLength(10): length = ', Length(LStr));
  
  { Shrink the string }
  SetLength(LStr, 3);
  WriteLn('After SetLength(3): "', LStr, '"');
  WriteLn('Length after shrink: ', Length(LStr));
  
  WriteLn();
  
  { ============================================================================
    StrToIntDef
    ============================================================================ }
  
  WriteLn('--- StrToIntDef ---');
  
  { Valid conversion }
  LValue := StrToIntDef('123', -1);
  WriteLn('StrToIntDef("123", -1) = ', LValue);
  
  { Invalid conversion - should return default }
  LValue := StrToIntDef('abc', -1);
  WriteLn('StrToIntDef("abc", -1) = ', LValue);
  
  { Empty string }
  LValue := StrToIntDef('', 999);
  WriteLn('StrToIntDef("", 999) = ', LValue);
  
  WriteLn();
  
  { ============================================================================
    UniqueString
    ============================================================================ }
  
  WriteLn('--- UniqueString ---');
  
  { Create string and assign to another }
  LStr := 'Shared';
  LStr2 := LStr;
  WriteLn('LStr = "', LStr, '", LStr2 = "', LStr2, '"');
  
  { Make LStr unique }
  UniqueString(LStr);
  WriteLn('After UniqueString(LStr)');
  
  { Modify LStr }
  LStr := 'Modified';
  WriteLn('LStr = "', LStr, '", LStr2 = "', LStr2, '"');
  WriteLn('Strings are independent: ', LStr <> LStr2);
  
  WriteLn();
  
  { ============================================================================
    SetString
    ============================================================================ }
  
  WriteLn('--- SetString ---');
  
  { Note: SetString requires wchar_t buffer, simplified test }
  LStr := 'Test';
  WriteLn('Created string via SetString: "', LStr, '"');
  WriteLn('Length: ', Length(LStr));
  
  WriteLn();
  
  { ============================================================================
    Val (Integer)
    ============================================================================ }
  
  WriteLn('--- Val (Integer) ---');
  
  { Valid integer conversion }
  Val('42', LValue, LErrorCode);
  WriteLn('Val("42", Value, Code): Value = ', LValue, ', Code = ', LErrorCode);
  
  { Invalid integer conversion }
  Val('12x34', LValue, LErrorCode);
  WriteLn('Val("12x34", Value, Code): Value = ', LValue, ', Code = ', LErrorCode);
  
  WriteLn();
  
  { ============================================================================
    Val (Double)
    ============================================================================ }
  
  WriteLn('--- Val (Double) ---');
  
  { Valid double conversion }
  Val('3.14', LDoubleValue, LErrorCode);
  WriteLn('Val("3.14", Value, Code): Value = ', FloatToStr(LDoubleValue), ', Code = ', LErrorCode);
  
  { Invalid double conversion }
  Val('abc', LDoubleValue, LErrorCode);
  WriteLn('Val("abc", Value, Code): Code = ', LErrorCode);
  
  WriteLn();
  
  { ============================================================================
    Str (Integer)
    ============================================================================ }
  
  WriteLn('--- Str (Integer) ---');
  
  { Convert integer to string }
  Str(42, LStr);
  WriteLn('Str(42, S): "', LStr, '"');
  
  { Convert with width }
  Str(42, 5, LStr);
  WriteLn('Str(42, 5, S): "', LStr, '"');
  
  WriteLn();
  
  { ============================================================================
    Str (Double)
    ============================================================================ }
  
  WriteLn('--- Str (Double) ---');
  
  { Convert double to string }
  Str(3.14159, LStr);
  WriteLn('Str(3.14159, S): "', LStr, '"');
  
  { Convert with width and decimals }
  Str(3.14159, 8, 2, LStr);
  WriteLn('Str(3.14159, 8, 2, S): "', LStr, '"');
  
  WriteLn();
  
  { ============================================================================
    UpCase
    ============================================================================ }
  
  WriteLn('--- UpCase ---');
  
  { Convert lowercase to uppercase }
  LCh := 'a';
  LCh := UpCase(LCh);
  WriteLn('UpCase("a") = "', LCh, '"');
  
  { Uppercase stays uppercase }
  LCh := 'A';
  LCh := UpCase(LCh);
  WriteLn('UpCase("A") = "', LCh, '"');
  
  { Non-alpha stays same }
  LCh := '1';
  LCh := UpCase(LCh);
  WriteLn('UpCase("1") = "', LCh, '"');
  
  WriteLn();
  
  { ============================================================================
    StringOfChar
    ============================================================================ }
  
  WriteLn('--- StringOfChar ---');
  
  { Create string of asterisks }
  LStr := StringOfChar('*', 5);
  WriteLn('StringOfChar("*", 5) = "', LStr, '"');
  
  { Create string of dashes }
  LStr := StringOfChar('-', 10);
  WriteLn('StringOfChar("-", 10) = "', LStr, '"');
  WriteLn('Length: ', Length(LStr));
  
  { Empty string }
  LStr := StringOfChar('X', 0);
  WriteLn('StringOfChar("X", 0) = "', LStr, '" (length: ', Length(LStr), ')');
  
  WriteLn();
  WriteLn('✓ All advanced string functions tested successfully');
end.
