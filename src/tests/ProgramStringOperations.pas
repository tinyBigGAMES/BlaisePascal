{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramStringOperations;
var
  S1, S2, S3: String;
  Len: Integer;
  Ch: Char;
begin
  WriteLn('=== Testing String Operations ===');
  
  S1 := 'Hello';
  S2 := 'World';
  
  WriteLn('S1: ', S1);
  WriteLn('S2: ', S2);
  
  WriteLn('--- Concatenation ---');
  S3 := S1 + ' ' + S2;
  WriteLn('S1 + " " + S2 = ', S3);
  
  WriteLn('--- Length ---');
  Len := Length(S1);
  WriteLn('Length(S1) = ', Len);
  Len := Length(S2);
  WriteLn('Length(S2) = ', Len);
  Len := Length(S3);
  WriteLn('Length(S3) = ', Len);
  
  WriteLn('--- Indexing (1-based) ---');
  Ch := S1[1];
  WriteLn('S1[1] = ', Ch);
  Ch := S1[5];
  WriteLn('S1[5] = ', Ch);
  Ch := S3[1];
  WriteLn('S3[1] = ', Ch);
  Ch := S3[7];
  WriteLn('S3[7] = ', Ch);
  
  WriteLn('✓ String operations tested');
end.
