{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramBinaryFileIO;

var
  LF: File;
  LData: array[0..9] of Integer;
  LReadData: array[0..9] of Integer;
  LI: Integer;
  LBytesRead: Integer;
  LBytesWritten: Integer;
  LFileSize: Integer;
  LFilePos: Integer;

begin
  WriteLn('=== Testing Binary File I/O ===');
  WriteLn();
  
  { ============================================================================
    WRITING BINARY DATA
    ============================================================================ }
  
  WriteLn('--- Writing Binary Data ---');
  
  { Prepare test data }
  for LI := 0 to 9 do
    LData[LI] := LI * 10;
  
  WriteLn('Test data prepared:');
  for LI := 0 to 9 do
    WriteLn('  LData[', LI, '] = ', LData[LI]);
  
  { Write to binary file }
  AssignFile(LF, 'test_binary.dat');
  Rewrite(LF, SizeOf(Integer));
  BlockWrite(LF, LData, 10, LBytesWritten);
  CloseFile(LF);
  WriteLn('✓ Written ', LBytesWritten, ' records to test_binary.dat');
  
  WriteLn();
  
  { ============================================================================
    READING BINARY DATA
    ============================================================================ }
  
  WriteLn('--- Reading Binary Data ---');
  
  { Clear read buffer }
  FillChar(LReadData, SizeOf(LReadData), 0);
  
  { Read from binary file }
  AssignFile(LF, 'test_binary.dat');
  Reset(LF, SizeOf(Integer));
  BlockRead(LF, LReadData, 10, LBytesRead);
  CloseFile(LF);
  WriteLn('✓ Read ', LBytesRead, ' records from test_binary.dat');
  
  { Verify data }
  WriteLn('Read data verification:');
  for LI := 0 to 9 do
    WriteLn('  LReadData[', LI, '] = ', LReadData[LI]);
  
  WriteLn();
  
  { ============================================================================
    FILE POSITIONING
    ============================================================================ }
  
  WriteLn('--- File Positioning ---');
  
  { Open file }
  AssignFile(LF, 'test_binary.dat');
  Reset(LF, SizeOf(Integer));
  
  { FileSize }
  LFileSize := FileSize(LF);
  WriteLn('FileSize(LF) = ', LFileSize, ' records');
  
  { FilePos at start }
  LFilePos := FilePos(LF);
  WriteLn('FilePos(LF) at start = ', LFilePos);
  
  { Seek to middle }
  Seek(LF, 5);
  LFilePos := FilePos(LF);
  WriteLn('FilePos(LF) after Seek(5) = ', LFilePos);
  
  { Read one record from middle }
  BlockRead(LF, LI, 1, LBytesRead);
  WriteLn('Read value at position 5: ', LI);
  
  { Check Eof }
  Seek(LF, LFileSize);
  if Eof(LF) then
    WriteLn('✓ Eof(LF) = true at end of file')
  else
    WriteLn('✗ Eof(LF) = false at end of file');
  
  CloseFile(LF);
  
  WriteLn();
  
  { ============================================================================
    CLEANUP
    ============================================================================ }
  
  WriteLn('--- Cleanup ---');
  
  { Delete test file }
  if RemoveFile('test_binary.dat') then
    WriteLn('✓ Test file deleted successfully')
  else
    WriteLn('✗ Failed to delete test file');
  
  WriteLn();
  WriteLn('✓ All binary file I/O operations tested successfully');
end.
