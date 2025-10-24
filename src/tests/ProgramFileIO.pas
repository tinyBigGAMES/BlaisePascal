{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramFileIO;

var
  LF: Text;
  LLine: String;
  LI: Integer;

begin
  WriteLn('=== Testing Text File I/O ===');
  WriteLn();
  
  { ============================================================================
    WRITING TO TEXT FILE
    ============================================================================ }
  
  WriteLn('--- Writing to Text File ---');
  
  { Create and write to file }
  AssignFile(LF, 'test_output.txt');
  Rewrite(LF);
  WriteLn(LF, 'Line 1: Hello from NitroPascal!');
  WriteLn(LF, 'Line 2: This is a test file.');
  WriteLn(LF, 'Line 3: Testing file I/O operations.');
  CloseFile(LF);
  WriteLn('✓ File written: test_output.txt');
  
  WriteLn();
  
  { ============================================================================
    READING FROM TEXT FILE
    ============================================================================ }
  
  WriteLn('--- Reading from Text File ---');
  
  { Read file line by line }
  AssignFile(LF, 'test_output.txt');
  Reset(LF);
  LI := 0;
  while not Eof(LF) do
  begin
    ReadLn(LF, LLine);
    Inc(LI);
    WriteLn('Read line ', LI, ': ', LLine);
  end;
  CloseFile(LF);
  
  WriteLn();
  
  { ============================================================================
    APPENDING TO TEXT FILE
    ============================================================================ }
  
  WriteLn('--- Appending to Text File ---');
  
  { Append more lines }
  AssignFile(LF, 'test_output.txt');
  Append(LF);
  WriteLn(LF, 'Line 4: This line was appended.');
  WriteLn(LF, 'Line 5: Another appended line.');
  CloseFile(LF);
  WriteLn('✓ Lines appended to file');
  
  { Read appended file }
  WriteLn('Reading updated file:');
  AssignFile(LF, 'test_output.txt');
  Reset(LF);
  LI := 0;
  while not Eof(LF) do
  begin
    ReadLn(LF, LLine);
    Inc(LI);
    WriteLn('  Line ', LI, ': ', LLine);
  end;
  CloseFile(LF);
  
  WriteLn();
  
  { ============================================================================
    FILE MANAGEMENT
    ============================================================================ }
  
  WriteLn('--- File Management ---');
  
  { FileExists }
  if FileExists('test_output.txt') then
    WriteLn('✓ FileExists("test_output.txt") = true')
  else
    WriteLn('✗ FileExists("test_output.txt") = false');
  
  { RemoveFile }
  if RemoveFile('test_output.txt') then
    WriteLn('✓ RemoveFile("test_output.txt") succeeded')
  else
    WriteLn('✗ RemoveFile("test_output.txt") failed');
  
  { Verify deletion }
  if FileExists('test_output.txt') then
    WriteLn('✗ File still exists after delete')
  else
    WriteLn('✓ File deleted successfully');
  
  WriteLn();
  
  { ============================================================================
    DIRECTORY OPERATIONS
    ============================================================================ }
  
  WriteLn('--- Directory Operations ---');
  
  { GetCurrentDir }
  LLine := GetCurrentDir();
  WriteLn('GetCurrentDir() = "', LLine, '"');
  
  { CreateDir }
  if not DirectoryExists('test_dir') then
  begin
    if CreateDir('test_dir') then
      WriteLn('✓ CreateDir("test_dir") succeeded')
    else
      WriteLn('✗ CreateDir("test_dir") failed');
  end;
  
  { DirectoryExists }
  if DirectoryExists('test_dir') then
    WriteLn('✓ DirectoryExists("test_dir") = true')
  else
    WriteLn('✗ DirectoryExists("test_dir") = false');
  
  WriteLn();
  WriteLn('✓ All text file I/O operations tested successfully');
end.
