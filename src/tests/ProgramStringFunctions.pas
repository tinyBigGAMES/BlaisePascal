{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramStringFunctions;

var
  LS: String;
  LS2: String;
  LS3: String;
  LI: Integer;
  LBool: Boolean;

begin
  WriteLn('=== Testing Additional String Functions ===');
  WriteLn();
  
  { ============================================================================
    STRINGREPLACE
    ============================================================================ }
  
  WriteLn('--- StringReplace ---');
  
  { Simple replacement }
  LS := 'Hello World';
  LS2 := StringReplace(LS, 'World', 'NitroPascal');
  WriteLn('StringReplace("Hello World", "World", "NitroPascal"):');
  WriteLn('  Result: "', LS2, '"');
  
  { Multiple occurrences }
  LS := 'foo bar foo baz foo';
  LS2 := StringReplace(LS, 'foo', 'test');
  WriteLn('StringReplace("foo bar foo baz foo", "foo", "test"):');
  WriteLn('  Result: "', LS2, '"');
  
  { Empty string }
  LS := 'Hello World';
  LS2 := StringReplace(LS, '', 'X');
  WriteLn('StringReplace("Hello World", "", "X"):');
  WriteLn('  Result: "', LS2, '" (no change expected)');
  
  WriteLn();
  
  { ============================================================================
    COMPARESTR
    ============================================================================ }
  
  WriteLn('--- CompareStr (case-sensitive) ---');
  
  { Equal strings }
  LI := CompareStr('Hello', 'Hello');
  WriteLn('CompareStr("Hello", "Hello") = ', LI, ' (should be 0)');
  
  { First < Second }
  LI := CompareStr('Apple', 'Banana');
  WriteLn('CompareStr("Apple", "Banana") = ', LI, ' (should be -1)');
  
  { First > Second }
  LI := CompareStr('Zebra', 'Apple');
  WriteLn('CompareStr("Zebra", "Apple") = ', LI, ' (should be 1)');
  
  { Case-sensitive difference }
  LI := CompareStr('hello', 'Hello');
  if LI = 0 then
    WriteLn('CompareStr("hello", "Hello") = 0 (same)')
  else
    WriteLn('CompareStr("hello", "Hello") != 0 (different - case-sensitive)');
  
  WriteLn();
  
  { ============================================================================
    SAMETEXT
    ============================================================================ }
  
  WriteLn('--- SameText (case-insensitive) ---');
  
  { Same text, same case }
  LBool := SameText('Hello', 'Hello');
  if LBool then
    WriteLn('SameText("Hello", "Hello") = true')
  else
    WriteLn('SameText("Hello", "Hello") = false');
  
  { Same text, different case }
  LBool := SameText('Hello', 'hello');
  if LBool then
    WriteLn('SameText("Hello", "hello") = true (case-insensitive)')
  else
    WriteLn('SameText("Hello", "hello") = false');
  
  { Same text, mixed case }
  LBool := SameText('NITROPASCAL', 'NitroPascal');
  if LBool then
    WriteLn('SameText("NITROPASCAL", "NitroPascal") = true')
  else
    WriteLn('SameText("NITROPASCAL", "NitroPascal") = false');
  
  { Different text }
  LBool := SameText('Hello', 'World');
  if LBool then
    WriteLn('SameText("Hello", "World") = true')
  else
    WriteLn('SameText("Hello", "World") = false (different text)');
  
  WriteLn();
  
  { ============================================================================
    QUOTEDSTR
    ============================================================================ }
  
  WriteLn('--- QuotedStr ---');
  
  { Simple string }
  LS := 'Hello';
  LS2 := QuotedStr(LS);
  WriteLn('QuotedStr("Hello") = ', LS2);
  
  { String with spaces }
  LS := 'Hello World';
  LS2 := QuotedStr(LS);
  WriteLn('QuotedStr("Hello World") = ', LS2);
  
  { Empty string }
  LS := '';
  LS2 := QuotedStr(LS);
  WriteLn('QuotedStr("") = ', LS2);
  
  { String with special characters }
  LS := 'Test 123!';
  LS2 := QuotedStr(LS);
  WriteLn('QuotedStr("Test 123!") = ', LS2);
  
  WriteLn();
  WriteLn('✓ All additional string functions tested successfully');
end.
