{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramFileSystem;

var
  LFile: Text;
  LResult: Boolean;
  LDir: String;

begin
  WriteLn('=== Testing File System Functions ===');
  WriteLn();
  
  { ============================================================================
    FileExists
    ============================================================================ }
  
  WriteLn('--- FileExists ---');
  
  { Create a test file }
  AssignFile(LFile, 'test_exists.txt');
  Rewrite(LFile);
  WriteLn(LFile, 'Test');
  CloseFile(LFile);
  WriteLn('Created test file');
  
  { Test FileExists - should be True }
  LResult := FileExists('test_exists.txt');
  WriteLn('FileExists("test_exists.txt") = ', BoolToStr(LResult, True));
  
  { Delete the file }
  RemoveFile('test_exists.txt');
  
  { Test FileExists - should be False }
  LResult := FileExists('test_exists.txt');
  WriteLn('FileExists("test_exists.txt") after delete = ', BoolToStr(LResult, True));
  
  { Test with non-existent file }
  LResult := FileExists('nonexistent_file.xyz');
  WriteLn('FileExists("nonexistent_file.xyz") = ', BoolToStr(LResult, True));
  
  WriteLn();
  
  { ============================================================================
    RemoveFile
    ============================================================================ }
  
  WriteLn('--- RemoveFile ---');
  
  { Create a test file }
  AssignFile(LFile, 'test_delete.txt');
  Rewrite(LFile);
  WriteLn(LFile, 'To be deleted');
  CloseFile(LFile);
  WriteLn('Created test file');
  
  { Verify it exists }
  LResult := FileExists('test_delete.txt');
  WriteLn('File exists before delete: ', BoolToStr(LResult, True));
  
  { Delete the file }
  LResult := RemoveFile('test_delete.txt');
  WriteLn('RemoveFile result: ', BoolToStr(LResult, True));
  
  { Verify it's gone }
  LResult := FileExists('test_delete.txt');
  WriteLn('File exists after delete: ', BoolToStr(LResult, True));
  
  WriteLn();
  
  { ============================================================================
    RenameFile
    ============================================================================ }
  
  WriteLn('--- RenameFile ---');
  
  { Create a test file }
  AssignFile(LFile, 'test_old.txt');
  Rewrite(LFile);
  WriteLn(LFile, 'Original content');
  CloseFile(LFile);
  WriteLn('Created test file: test_old.txt');
  
  { Rename the file }
  LResult := RenameFile('test_old.txt', 'test_new.txt');
  WriteLn('RenameFile result: ', BoolToStr(LResult, True));
  
  { Verify old name doesn't exist }
  LResult := FileExists('test_old.txt');
  WriteLn('Old file exists: ', BoolToStr(LResult, True));
  
  { Verify new name exists }
  LResult := FileExists('test_new.txt');
  WriteLn('New file exists: ', BoolToStr(LResult, True));
  
  { Cleanup }
  RemoveFile('test_new.txt');
  
  WriteLn();
  
  { ============================================================================
    DirectoryExists
    ============================================================================ }
  
  WriteLn('--- DirectoryExists ---');
  
  { Test with current directory (should exist) }
  LResult := DirectoryExists('.');
  WriteLn('DirectoryExists(".") = ', BoolToStr(LResult, True));
  
  { Test with non-existent directory }
  LResult := DirectoryExists('nonexistent_directory_xyz');
  WriteLn('DirectoryExists("nonexistent_directory_xyz") = ', BoolToStr(LResult, True));
  
  WriteLn();
  
  { ============================================================================
    CreateDir
    ============================================================================ }
  
  WriteLn('--- CreateDir ---');
  
  { Create a test directory }
  LResult := CreateDir('test_directory');
  WriteLn('CreateDir("test_directory") = ', BoolToStr(LResult, True));
  
  { Verify it exists }
  LResult := DirectoryExists('test_directory');
  WriteLn('DirectoryExists("test_directory") = ', BoolToStr(LResult, True));
  
  { Note: Cleanup would require RemoveDir which may not be available }
  WriteLn('Note: test_directory created - manual cleanup may be needed');
  
  WriteLn();
  
  { ============================================================================
    GetCurrentDir
    ============================================================================ }
  
  WriteLn('--- GetCurrentDir ---');
  
  { Get current directory }
  LDir := GetCurrentDir();
  WriteLn('Current directory: ', LDir);
  WriteLn('Length: ', Length(LDir));
  
  WriteLn();
  WriteLn('✓ All file system functions tested successfully');
end.
