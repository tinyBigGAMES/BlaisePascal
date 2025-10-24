{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramOrdinalAdvanced;

var
  LI: Integer;
  LResult: Boolean;
  LWord: Word;

begin
  WriteLn('=== Testing Advanced Ordinal Functions ===');
  WriteLn();
  
  { ============================================================================
    Odd
    ============================================================================ }
  
  WriteLn('--- Odd ---');
  
  { Test even numbers }
  LI := 0;
  LResult := Odd(LI);
  WriteLn('Odd(0) = ', BoolToStr(LResult, True));
  
  LI := 2;
  LResult := Odd(LI);
  WriteLn('Odd(2) = ', BoolToStr(LResult, True));
  
  LI := 4;
  LResult := Odd(LI);
  WriteLn('Odd(4) = ', BoolToStr(LResult, True));
  
  LI := -2;
  LResult := Odd(LI);
  WriteLn('Odd(-2) = ', BoolToStr(LResult, True));
  
  { Test odd numbers }
  LI := 1;
  LResult := Odd(LI);
  WriteLn('Odd(1) = ', BoolToStr(LResult, True));
  
  LI := 3;
  LResult := Odd(LI);
  WriteLn('Odd(3) = ', BoolToStr(LResult, True));
  
  LI := -1;
  LResult := Odd(LI);
  WriteLn('Odd(-1) = ', BoolToStr(LResult, True));
  
  WriteLn();
  
  { ============================================================================
    Swap
    ============================================================================ }
  
  WriteLn('--- Swap ---');
  
  { Test byte order swap }
  LWord := $1234;
  WriteLn('Original: $', IntToHex(LWord, 4));
  
  LWord := Swap(LWord);
  WriteLn('After Swap: $', IntToHex(LWord, 4));
  WriteLn('Expected: $3412');
  
  { Another test }
  LWord := $ABCD;
  WriteLn('Original: $', IntToHex(LWord, 4));
  
  LWord := Swap(LWord);
  WriteLn('After Swap: $', IntToHex(LWord, 4));
  WriteLn('Expected: $CDAB');
  
  { Verify swap is reversible }
  LWord := $1234;
  WriteLn('Original: $', IntToHex(LWord, 4));
  LWord := Swap(LWord);
  LWord := Swap(LWord);
  WriteLn('After double Swap: $', IntToHex(LWord, 4));
  WriteLn('Should match original: ', LWord = $1234);
  
  WriteLn();
  WriteLn('✓ All advanced ordinal functions tested successfully');
end.
