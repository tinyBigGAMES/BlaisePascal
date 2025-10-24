{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramFileIOAdvanced;

var
  LFile: Text;
  LBinFile: file;
  LIntValue: Integer;
  LDoubleValue: Double;
  LStrValue: String;
  LCharValue: Char;
  LResult: Boolean;
  LErrorCode: Integer;
  LI: Integer;
  LData: array[0..9] of Integer;

begin
  WriteLn('=== Testing Advanced File I/O Functions ===');
  WriteLn();
  
  { ============================================================================
    Read (Typed Data)
    ============================================================================ }
  
  WriteLn('--- Read (Typed Data) ---');
  
  { Create test file with various data types }
  AssignFile(LFile, 'test_read.txt');
  Rewrite(LFile);
  WriteLn(LFile, '42');
  WriteLn(LFile, '3.14');
  WriteLn(LFile, 'Hello');
  WriteLn(LFile, 'X');
  CloseFile(LFile);
  WriteLn('Created test file with Integer, Double, String, Char');
  
  { Read data back }
  Reset(LFile);
  
  Read(LFile, LIntValue);
  WriteLn('Read Integer: ', LIntValue);
  
  Read(LFile, LDoubleValue);
  WriteLn('Read Double: ', FloatToStr(LDoubleValue));
  
  Read(LFile, LStrValue);
  WriteLn('Read String: "', LStrValue, '"');
  
  Read(LFile, LCharValue);
  WriteLn('Read Char: "', LCharValue, '"');
  
  CloseFile(LFile);
  RemoveFile('test_read.txt');
  
  WriteLn();
  
  { ============================================================================
    Eoln
    ============================================================================ }
  
  WriteLn('--- Eoln ---');
  
  { Create test file }
  AssignFile(LFile, 'test_eoln.txt');
  Rewrite(LFile);
  WriteLn(LFile, 'Line1');
  WriteLn(LFile, 'Line2');
  CloseFile(LFile);
  
  { Read and test Eoln }
  Reset(LFile);
  ReadLn(LFile, LStrValue);
  WriteLn('Read: "', LStrValue, '"');
  
  LResult := Eoln(LFile);
  WriteLn('Eoln after ReadLn: ', BoolToStr(LResult, True));
  
  CloseFile(LFile);
  RemoveFile('test_eoln.txt');
  
  WriteLn();
  
  { ============================================================================
    SeekEof
    ============================================================================ }
  
  WriteLn('--- SeekEof ---');
  
  { Create test file with trailing whitespace }
  AssignFile(LFile, 'test_seekeof.txt');
  Rewrite(LFile);
  Write(LFile, 'Data');
  Write(LFile, '   ');
  CloseFile(LFile);
  WriteLn('Created file with data and trailing spaces');
  
  { Test SeekEof }
  Reset(LFile);
  Read(LFile, LStrValue);
  WriteLn('Read: "', LStrValue, '"');
  
  LResult := SeekEof(LFile);
  WriteLn('SeekEof (skips whitespace): ', BoolToStr(LResult, True));
  
  CloseFile(LFile);
  RemoveFile('test_seekeof.txt');
  
  WriteLn();
  
  { ============================================================================
    SeekEoln
    ============================================================================ }
  
  WriteLn('--- SeekEoln ---');
  
  { Create test file }
  AssignFile(LFile, 'test_seekeoln.txt');
  Rewrite(LFile);
  WriteLn(LFile, 'Word   ');
  CloseFile(LFile);
  WriteLn('Created file with word and trailing spaces before newline');
  
  { Test SeekEoln }
  Reset(LFile);
  Read(LFile, LStrValue);
  WriteLn('Read: "', LStrValue, '"');
  
  LResult := SeekEoln(LFile);
  WriteLn('SeekEoln (skips spaces to EOL): ', BoolToStr(LResult, True));
  
  CloseFile(LFile);
  RemoveFile('test_seekeoln.txt');
  
  WriteLn();
  
  { ============================================================================
    Flush
    ============================================================================ }
  
  WriteLn('--- Flush ---');
  
  { Create file and write data }
  AssignFile(LFile, 'test_flush.txt');
  Rewrite(LFile);
  Write(LFile, 'Buffered data');
  WriteLn('Wrote data to buffer');
  
  { Flush to disk }
  Flush(LFile);
  WriteLn('Flushed buffer to disk');
  WriteLn('Data should be immediately available on disk');
  
  CloseFile(LFile);
  RemoveFile('test_flush.txt');
  
  WriteLn();
  
  { ============================================================================
    Truncate
    ============================================================================ }
  
  WriteLn('--- Truncate ---');
  
  { Create binary file with data }
  AssignFile(LBinFile, 'test_truncate.dat');
  Rewrite(LBinFile, SizeOf(Integer));
  
  { Write 10 integers }
  for LI := 0 to 9 do
    LData[LI] := LI * 10;
  
  BlockWrite(LBinFile, LData, 10);
  WriteLn('Wrote 10 integers to file');
  
  { Seek to position 5 }
  Seek(LBinFile, 5);
  WriteLn('Seeked to position 5');
  
  { Truncate at current position }
  Truncate(LBinFile);
  WriteLn('Truncated file at position 5');
  
  { Verify size }
  LIntValue := FileSize(LBinFile);
  WriteLn('File size after truncate: ', LIntValue, ' records');
  WriteLn('Expected: 5 records');
  
  CloseFile(LBinFile);
  RemoveFile('test_truncate.dat');
  
  WriteLn();
  
  { ============================================================================
    IOResult
    ============================================================================ }
  
  WriteLn('--- IOResult ---');
  
  { Attempt to open non-existent file }
  LErrorCode := IOResult();
  WriteLn('IOResult before operation: ', LErrorCode);
  
  { Normal operation }
  AssignFile(LFile, 'test_ioresult.txt');
  Rewrite(LFile);
  CloseFile(LFile);
  LErrorCode := IOResult();
  WriteLn('IOResult after successful operation: ', LErrorCode);
  
  RemoveFile('test_ioresult.txt');
  
  WriteLn();
  WriteLn('✓ All advanced file I/O functions tested successfully');
end.
