{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit UBlaise;

interface

procedure RunBlaise();

implementation

uses
  System.SysUtils,
  Blaise.Compiler,
  Blaise.Utils;

var
  GCompiler: TCompiler;

procedure ShowBanner();
var
  LVersion: TVersionInfo;
begin
  TUtils.PrintLn(COLOR_CYAN + COLOR_BOLD);
  TUtils.PrintLn(' ___  _      _           ___                  _ ™');
  TUtils.PrintLn('| _ )| |__ _(_)___ ___  | _ \__ _ ___ __ __ _| |');
  TUtils.PrintLn('| _ \| / _` | (_-</ -_) |  _/ _` (_-</ _/ _` | |');
  TUtils.PrintLn('|___/|_\__,_|_/__/\___| |_| \__,_/__/\__\__,_|_|');
  TUtils.PrintLn(COLOR_WHITE + '        Think in Pascal. Compile to C++' + COLOR_RESET);
  TUtils.PrintLn('');
  
  if TUtils.GetVersionInfo(LVersion) then
    TUtils.PrintLn(COLOR_CYAN + 'Version ' + LVersion.VersionString + COLOR_RESET)
  else
    TUtils.PrintLn(COLOR_CYAN + 'Version unknown' + COLOR_RESET);
    
  TUtils.PrintLn('');
end;

procedure ShowHelp();
begin
  ShowBanner();

  TUtils.PrintLn(COLOR_BOLD + 'USAGE:' + COLOR_RESET);
  TUtils.PrintLn('  blaise ' + COLOR_CYAN + '<COMMAND>' + COLOR_RESET + ' [OPTIONS]');
  TUtils.PrintLn('');

  TUtils.PrintLn(COLOR_BOLD + 'COMMANDS:' + COLOR_RESET);
  TUtils.PrintLn('  ' + COLOR_GREEN + 'init' + COLOR_RESET + ' <name> [--template <type>]');
  TUtils.PrintLn('                   Create a new Blaise Pascal project');
  TUtils.PrintLn('                     Templates: program (default), library, unit');
  TUtils.PrintLn('  ' + COLOR_GREEN + 'build' + COLOR_RESET + '            Compile Pascal source to C++ and build executable');
  TUtils.PrintLn('  ' + COLOR_GREEN + 'run' + COLOR_RESET + '              Execute the compiled program');
  TUtils.PrintLn('  ' + COLOR_GREEN + 'clean' + COLOR_RESET + '            Remove all generated files');
  TUtils.PrintLn('  ' + COLOR_GREEN + 'zig' + COLOR_RESET + ' <args>       Pass arguments directly to Zig compiler');
  TUtils.PrintLn('  ' + COLOR_GREEN + 'version' + COLOR_RESET + '          Display version information');
  TUtils.PrintLn('  ' + COLOR_GREEN + 'help' + COLOR_RESET + '             Display this help message');
  TUtils.PrintLn('');

  TUtils.PrintLn(COLOR_BOLD + 'OPTIONS:' + COLOR_RESET);
  TUtils.PrintLn('  -h, --help       Print help information');
  TUtils.PrintLn('  --version        Print version information');
  TUtils.PrintLn('  -t, --template   Specify project template type');
  TUtils.PrintLn('');

  TUtils.PrintLn(COLOR_BOLD + 'TEMPLATE TYPES:' + COLOR_RESET);
  TUtils.PrintLn('  ' + COLOR_CYAN + 'program' + COLOR_RESET + '          Executable program (default)');
  TUtils.PrintLn('  ' + COLOR_CYAN + 'library' + COLOR_RESET + '          Shared library (.dll on Windows, .so on Linux)');
  TUtils.PrintLn('  ' + COLOR_CYAN + 'unit' + COLOR_RESET + '             Static library (.lib on Windows, .a on Linux)');
  TUtils.PrintLn('');

  TUtils.PrintLn(COLOR_BOLD + 'EXAMPLES:' + COLOR_RESET);
  TUtils.PrintLn('  ' + COLOR_CYAN + 'blaise init MyGame' + COLOR_RESET + '                   - Create a program project');
  TUtils.PrintLn('  ' + COLOR_CYAN + 'blaise init MyLib --template library' + COLOR_RESET + ' - Create a shared library project');
  TUtils.PrintLn('  ' + COLOR_CYAN + 'blaise build' + COLOR_RESET + '                         - Build the current project');
  TUtils.PrintLn('  ' + COLOR_CYAN + 'blaise run' + COLOR_RESET + '                           - Run the compiled executable');
  TUtils.PrintLn('  ' + COLOR_CYAN + 'blaise zig cc -c myfile.c' + COLOR_RESET + '            - Compile C file with Zig');
  TUtils.PrintLn('');

  TUtils.PrintLn('For more information, visit:');
  TUtils.PrintLn(COLOR_BLUE + '  https://github.com/tinyBigGAMES/BlaisePascal' + COLOR_RESET);
  TUtils.PrintLn('');
end;

procedure ShowVersion();
begin
  ShowBanner();
  TUtils.PrintLn('Copyright © 2025-present tinyBigGAMES™ LLC');
  TUtils.PrintLn('All Rights Reserved.');
  TUtils.PrintLn('');
  TUtils.PrintLn('Licensed under BSD 3-Clause License');
  TUtils.PrintLn('');
end;

procedure CommandInit();
var
  LProjectName: string;
  LBaseDir: string;
  LTemplate: TTemplateType;
  LTemplateStr: string;
  LIndex: Integer;
begin
  if ParamCount < 2 then
  begin
    TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + 'Project name required');
    TUtils.PrintLn('');
    TUtils.PrintLn('Usage: ' + COLOR_CYAN + 'blaise init <name> [--template <type>]' + COLOR_RESET);
    TUtils.PrintLn('');
    TUtils.PrintLn('Template Types:');
    TUtils.PrintLn('  program  - Executable program (default)');
    TUtils.PrintLn('  library  - Shared library (.dll/.so)');
    TUtils.PrintLn('  unit     - Static library (.lib/.a)');
    TUtils.PrintLn('');
    TUtils.PrintLn('Example:');
    TUtils.PrintLn('  blaise init MyGame');
    TUtils.PrintLn('  blaise init MyLib --template library');
    TUtils.PrintLn('');
    ExitCode := 2;
    Exit;
  end;

  LProjectName := ParamStr(2);
  LBaseDir := GetCurrentDir() + PathDelim;
  LTemplate := tpProgram; // Default
  
  // Parse optional --template parameter
  LIndex := 3;
  while LIndex <= ParamCount do
  begin
    if ((ParamStr(LIndex) = '--template') or (ParamStr(LIndex) = '-t')) and (LIndex < ParamCount) then
    begin
      Inc(LIndex);
      LTemplateStr := LowerCase(ParamStr(LIndex).Trim());
      
      if LTemplateStr = 'program' then
        LTemplate := tpProgram
      else if LTemplateStr = 'library' then
        LTemplate := tpLibrary
      else if LTemplateStr = 'unit' then
        LTemplate := tpUnit
      else
      begin
        TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + 'Invalid template type: ' + ParamStr(LIndex));
        TUtils.PrintLn('Valid types: program, library, unit');
        TUtils.PrintLn('');
        ExitCode := 2;
        Exit;
      end;
    end;
    Inc(LIndex);
  end;

  TUtils.PrintLn('');
  GCompiler.Init(LProjectName, LBaseDir, LTemplate);
  TUtils.PrintLn('');
  TUtils.PrintLn(COLOR_GREEN + '✓ Project created successfully!' + COLOR_RESET);
  TUtils.PrintLn('');
end;

procedure CommandBuild();
begin
  TUtils.PrintLn('');
  try
    GCompiler.Build();
    TUtils.PrintLn('');
    TUtils.PrintLn(COLOR_GREEN + COLOR_BOLD + '✓ Build completed successfully!' + COLOR_RESET);
  except
    on E: Exception do
    begin
      TUtils.PrintLn('');
      TUtils.PrintLn(COLOR_RED + COLOR_BOLD + '✗ Build failed!' + COLOR_RESET);
      
      // Build() already handled error printing if there were compiler errors
      // Only print the exception message if it's NOT a compilation error
      if not GCompiler.GetErrors().HasErrors() then
        TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + E.Message);
      
      TUtils.PrintLn('');
      ExitCode := 3;
    end;
  end;
end;

procedure CommandRun();
begin
  TUtils.PrintLn('');
  try
    GCompiler.Run();
    TUtils.PrintLn('');
  except
    on E: Exception do
    begin
      TUtils.PrintLn('');
      TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + E.Message);
      TUtils.PrintLn('');
      ExitCode := 1;
    end;
  end;
end;

procedure CommandClean();
begin
  TUtils.PrintLn('');
  try
    GCompiler.Clean();
    TUtils.PrintLn('');
    TUtils.PrintLn(COLOR_GREEN + '✓ Clean completed successfully!' + COLOR_RESET);
    TUtils.PrintLn('');
  except
    on E: Exception do
    begin
      TUtils.PrintLn('');
      TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + E.Message);
      TUtils.PrintLn('');
      ExitCode := 1;
    end;
  end;
end;

procedure CommandZig();
var
  LArgs: string;
  LI: Integer;
begin
  // Collect all parameters after "zig" command
  LArgs := '';
  for LI := 2 to ParamCount do
  begin
    if LI > 2 then
      LArgs := LArgs + ' ';
    LArgs := LArgs + ParamStr(LI);
  end;

  if LArgs.Trim().IsEmpty then
  begin
    TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + 'Zig command requires arguments');
    TUtils.PrintLn('');
    TUtils.PrintLn('Usage: ' + COLOR_CYAN + 'blaise zig <zig-args>' + COLOR_RESET);
    TUtils.PrintLn('');
    TUtils.PrintLn('Examples:');
    TUtils.PrintLn('  blaise zig version');
    TUtils.PrintLn('  blaise zig build --help');
    TUtils.PrintLn('  blaise zig cc -c myfile.c -o myfile.o');
    TUtils.PrintLn('  blaise zig c++ -c myfile.cpp -o myfile.o');
    TUtils.PrintLn('');
    ExitCode := 2;
    Exit;
  end;

  TUtils.PrintLn('');
  try
    GCompiler.Zig(LArgs);
    TUtils.PrintLn('');
  except
    on E: Exception do
    begin
      TUtils.PrintLn('');
      TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + E.Message);
      TUtils.PrintLn('');
      ExitCode := 1;
    end;
  end;
end;

procedure ProcessCommand();
var
  LCommand: string;
begin
  if ParamCount = 0 then
  begin
    ShowHelp();
    Exit;
  end;

  LCommand := LowerCase(ParamStr(1));

  // Handle flags
  if (LCommand = '-h') or (LCommand = '--help') or (LCommand = 'help') then
  begin
    ShowHelp();
    Exit;
  end;

  if (LCommand = '--version') or (LCommand = 'version') then
  begin
    ShowVersion();
    Exit;
  end;

  // Handle commands
  if LCommand = 'init' then
    CommandInit()
  else if LCommand = 'build' then
    CommandBuild()
  else if LCommand = 'run' then
    CommandRun()
  else if LCommand = 'clean' then
    CommandClean()
  else if LCommand = 'zig' then
    CommandZig()
  else
  begin
    TUtils.PrintLn('');
    TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + 'Unknown command: ' + COLOR_YELLOW + LCommand + COLOR_RESET);
    TUtils.PrintLn('');
    TUtils.PrintLn('Run ' + COLOR_CYAN + 'blaise help' + COLOR_RESET + ' to see available commands');
    TUtils.PrintLn('');
    ExitCode := 2;
  end;
end;

procedure RunBlaise();
begin
  ExitCode := 0;
  GCompiler := nil;

  try
    GCompiler := TCompiler.Create();
    try
      ProcessCommand();
    finally
      FreeAndNil(GCompiler);
    end;
  except
    on E: Exception do
    begin
      TUtils.PrintLn('');
      TUtils.PrintLn(COLOR_RED + COLOR_BOLD + 'Fatal Error: ' + COLOR_RESET + E.Message);
      TUtils.PrintLn('');
      ExitCode := 1;
    end;
  end;
end;

end.
