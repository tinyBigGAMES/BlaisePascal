{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.Tester;

{$I Blaise.Defines.inc}

interface

uses
  WinApi.Windows,
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.Generics.Collections,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Writer,
  DelphiAST.ProjectIndexer,
  Blaise.Utils,
  Blaise.Errors,
  Blaise.CodeGen,
  Blaise.Preprocessing,
  Blaise.Build;

type
  { TTesterEntry }
  TTesterEntry = record
    Number: Integer;
    Filename: string;
    SourcePath: string;
    ExpectedExitCode: DWORD;
    Build: Boolean;
    Run: Boolean;
    Clean: Boolean;
  end;

  { TTester }
  TTester = class
  private
    // ANSI color constants

  private
    // Core instances
    FCodeGen: TCodeGen;
    FErrors: TErrors;
    FPreprocessor: TPreprocessor;
    FBuild: TBuild;

    // Configuration
    FProjectFolder: string;
    FTestSourceFolder: string;
    FShowPascal: Boolean;
    FShowXML: Boolean;
    FShowCPP: Boolean;

    // Test registry
    FTests: TList<TTesterEntry>;

    // CLI override flags
    FForceClean: Boolean;
    FForceBuild: Boolean;
    FForceRun: Boolean;
    FNoClean: Boolean;
    FNoBuild: Boolean;
    FNoRun: Boolean;

    // Statistics
    FPassedCount: Integer;
    FFailedCount: Integer;
    FTotalCount: Integer;
    FFailedTests: TList<string>;

    // Helper methods
    function  FindTest(const ANumber: Integer; out AEntry: TTesterEntry): Boolean;
    procedure ExecuteTest(const ATestNum: Integer);
    procedure ExecuteTestInternal(const AEntry: TTesterEntry);
    procedure CleanProjectFolder;
    procedure DisplayPascalSource(const APasFile: string);
    procedure DisplayXMLForUnit(const APasFile: string);
    procedure DisplayGeneratedFile(const AFilePath: string);
    procedure ShowBanner;
    procedure ShowSeparator;
    procedure ShowHelp;
    procedure ShowTestList;

    // CLI parsing
    procedure ParseCommandLine(out ACommand: string; out ATestNumbers: TArray<Integer>);
    function  ParseTestSpec(const ASpec: string): TArray<Integer>;
    function  ParseRange(const ARange: string): TArray<Integer>;
    
    // Reset compiler instances for clean state between tests
    procedure Reset();

  public
    constructor Create;
    destructor Destroy; override;

    // Configuration
    procedure SetProjectFolder(const APath: string);
    procedure SetTestSourceFolder(const APath: string);
    procedure SetShowPascal(const AShow: Boolean);
    procedure SetShowXML(const AShow: Boolean);
    procedure SetShowCPP(const AShow: Boolean);

    // Test management
    procedure AddTest(const ANumber: Integer; const AFilename: string;
      const AExpectedExitCode: DWORD = 0; const ABuild: Boolean = False;
      const ARun: Boolean = False; const AClean: Boolean = False);
    procedure ClearTests;

    // Execution methods
    procedure RunTest(const ANum: Integer); overload;
    procedure RunTests(const ANumbers: TArray<Integer>); overload;
    procedure Run; // CLI entry point
  end;

implementation

{ TTester }

constructor TTester.Create;
begin
  inherited Create;

  // Create collections
  FTests := TList<TTesterEntry>.Create();
  FFailedTests := TList<string>.Create();

  // Initialize configuration
  FProjectFolder := '';
  FTestSourceFolder := '';
  FShowPascal := True;
  FShowXML := True;
  FShowCPP := True;

  // Initialize CLI flags
  FForceClean := False;
  FForceBuild := False;
  FForceRun := False;
  FNoClean := False;
  FNoBuild := False;
  FNoRun := False;

  // Initialize statistics
  FPassedCount := 0;
  FFailedCount := 0;
  FTotalCount := 0;
  
  // Create fresh compiler instances
  Reset();
end;

destructor TTester.Destroy;
begin
  if Assigned(FCodeGen) then
    FCodeGen.Free();
  if Assigned(FErrors) then
    FErrors.Free();
  if Assigned(FPreprocessor) then
    FPreprocessor.Free();
  if Assigned(FBuild) then
    FBuild.Free();
  FTests.Free();
  FFailedTests.Free();

  inherited Destroy;
end;

procedure TTester.Reset();
begin
  // Free existing instances if they exist
  if Assigned(FCodeGen) then
    FCodeGen.Free();
  if Assigned(FErrors) then
    FErrors.Free();
  if Assigned(FPreprocessor) then
    FPreprocessor.Free();
  if Assigned(FBuild) then
    FBuild.Free();
  
  // Create fresh instances
  FCodeGen := TCodeGen.Create();
  FErrors := TErrors.Create();
  FPreprocessor := TPreprocessor.Create();
  FBuild := TBuild.Create();
end;

procedure TTester.SetProjectFolder(const APath: string);
begin
  FProjectFolder := APath;
end;

procedure TTester.SetTestSourceFolder(const APath: string);
begin
  FTestSourceFolder := APath;
end;

procedure TTester.SetShowPascal(const AShow: Boolean);
begin
  FShowPascal := AShow;
end;

procedure TTester.SetShowXML(const AShow: Boolean);
begin
  FShowXML := AShow;
end;

procedure TTester.SetShowCPP(const AShow: Boolean);
begin
  FShowCPP := AShow;
end;

procedure TTester.AddTest(const ANumber: Integer; const AFilename: string;
  const AExpectedExitCode: DWORD; const ABuild: Boolean;
  const ARun: Boolean; const AClean: Boolean);
var
  LEntry: TTesterEntry;
begin
  LEntry.Number := ANumber;
  LEntry.Filename := AFilename;
  LEntry.SourcePath := FTestSourceFolder;
  LEntry.ExpectedExitCode := AExpectedExitCode;
  LEntry.Build := ABuild;
  LEntry.Run := ARun;
  LEntry.Clean := AClean;

  FTests.Add(LEntry);
end;

procedure TTester.ClearTests;
begin
  FTests.Clear();
end;

function TTester.FindTest(const ANumber: Integer; out AEntry: TTesterEntry): Boolean;
var
  LEntry: TTesterEntry;
begin
  Result := False;

  for LEntry in FTests do
  begin
    if LEntry.Number = ANumber then
    begin
      AEntry := LEntry;
      Exit(True);
    end;
  end;
end;

procedure TTester.ShowBanner;
begin
  TUtils.PrintLn(COLOR_CYAN + COLOR_BOLD);
  TUtils.PrintLn(' ___ ___ _____ ___ ___ _____ ___ ___  ');
  TUtils.PrintLn('| _ ) _ \_   _| __/ __|_   _| __| _ \ ');
  TUtils.PrintLn('| _ \  _/ | | | _|\__ \ | | | _||   / ');
  TUtils.PrintLn('|___/_|   |_| |___|___/ |_| |___|_|_\ ');
  TUtils.PrintLn(COLOR_WHITE + '       Blaise Pascal Test Suite' + COLOR_RESET);
  TUtils.PrintLn('');
end;

procedure TTester.ShowSeparator;
begin
  TUtils.PrintLn(COLOR_CYAN + '────────────────────────────────────────────────────────────────' + COLOR_RESET);
end;

procedure TTester.ShowHelp;
begin
  ShowBanner();

  TUtils.PrintLn(COLOR_BOLD + 'USAGE:' + COLOR_RESET);
  TUtils.PrintLn('  tester ' + COLOR_CYAN + '<command>' + COLOR_RESET + ' [options]');
  TUtils.PrintLn('');

  TUtils.PrintLn(COLOR_BOLD + 'COMMANDS:' + COLOR_RESET);
  TUtils.PrintLn('  ' + COLOR_GREEN + 'run <tests>' + COLOR_RESET + '    Run specified tests');
  TUtils.PrintLn('                 Examples:');
  TUtils.PrintLn('                   tester run 1              # Run test 1');
  TUtils.PrintLn('                   tester run 1-10           # Run tests 1 through 10');
  TUtils.PrintLn('                   tester run 1,5,8          # Run tests 1, 5, and 8');
  TUtils.PrintLn('                   tester run 1-5,10,15-20   # Mixed ranges');
  TUtils.PrintLn('                   tester run all            # Run all tests');
  TUtils.PrintLn('');
  TUtils.PrintLn('  ' + COLOR_GREEN + 'list' + COLOR_RESET + '           List all available tests');
  TUtils.PrintLn('  ' + COLOR_GREEN + 'help' + COLOR_RESET + '           Show this help message');
  TUtils.PrintLn('  ' + COLOR_GREEN + 'version' + COLOR_RESET + '        Show version information');
  TUtils.PrintLn('');

  TUtils.PrintLn(COLOR_BOLD + 'OPTIONS:' + COLOR_RESET);
  TUtils.PrintLn('  ' + COLOR_YELLOW + '--build, -b' + COLOR_RESET + '     Force build for all tests');
  TUtils.PrintLn('  ' + COLOR_YELLOW + '--run, -r' + COLOR_RESET + '       Force run for all tests');
  TUtils.PrintLn('  ' + COLOR_YELLOW + '--clean, -c' + COLOR_RESET + '     Force clean for all tests');
  TUtils.PrintLn('  ' + COLOR_YELLOW + '--no-build' + COLOR_RESET + '      Disable build for all tests');
  TUtils.PrintLn('  ' + COLOR_YELLOW + '--no-run' + COLOR_RESET + '        Disable run for all tests');
  TUtils.PrintLn('  ' + COLOR_YELLOW + '--no-clean' + COLOR_RESET + '      Disable clean for all tests');
  TUtils.PrintLn('');

  TUtils.PrintLn(COLOR_BOLD + 'EXAMPLES:' + COLOR_RESET);
  TUtils.PrintLn('  tester run 1                    # Run test 1 with default settings');
  TUtils.PrintLn('  tester run 1-10 --build --run   # Build and run tests 1-10');
  TUtils.PrintLn('  tester run all --clean          # Run all tests with clean');
  TUtils.PrintLn('  tester list                     # List all tests');
  TUtils.PrintLn('');
end;

procedure TTester.ShowTestList;
var
  LEntry: TTesterEntry;
  LBuildStr: string;
  LRunStr: string;
  LCleanStr: string;
begin
  ShowBanner();

  if FTests.Count = 0 then
  begin
    TUtils.PrintLn(COLOR_YELLOW + 'No tests registered' + COLOR_RESET);
    TUtils.PrintLn('');
    Exit;
  end;

  TUtils.PrintLn(COLOR_BOLD + 'Available Tests (%d total):' + COLOR_RESET, [FTests.Count]);
  TUtils.PrintLn('');

  for LEntry in FTests do
  begin
    LBuildStr := '';
    LRunStr := '';
    LCleanStr := '';

    if LEntry.Build then
      LBuildStr := COLOR_GREEN + '[B]' + COLOR_RESET
    else
      LBuildStr := COLOR_RESET + '[ ]' + COLOR_RESET;

    if LEntry.Run then
      LRunStr := COLOR_GREEN + '[R]' + COLOR_RESET
    else
      LRunStr := COLOR_RESET + '[ ]' + COLOR_RESET;

    if LEntry.Clean then
      LCleanStr := COLOR_GREEN + '[C]' + COLOR_RESET
    else
      LCleanStr := COLOR_RESET + '[ ]' + COLOR_RESET;

    TUtils.PrintLn('  %s%3d%s  %s %s %s  %s (exit: %d)',
      [COLOR_CYAN, LEntry.Number, COLOR_RESET,
       LBuildStr, LRunStr, LCleanStr,
       LEntry.Filename, LEntry.ExpectedExitCode]);
  end;

  TUtils.PrintLn('');
  TUtils.PrintLn('Legend: [B]=Build [R]=Run [C]=Clean');
  TUtils.PrintLn('');
end;

procedure TTester.ParseCommandLine(out ACommand: string; out ATestNumbers: TArray<Integer>);
var
  LI: Integer;
  LParam: string;
  LTestSpec: string;
begin
  ACommand := '';
  SetLength(ATestNumbers, 0);

  // No parameters - show help
  if ParamCount = 0 then
    Exit;

  // First parameter is the command
  ACommand := LowerCase(ParamStr(1));

  // Parse remaining parameters
  LI := 2;
  while LI <= ParamCount do
  begin
    LParam := LowerCase(ParamStr(LI));

    // Check for flags
    if (LParam = '--build') or (LParam = '-b') then
      FForceBuild := True
    else if (LParam = '--run') or (LParam = '-r') then
      FForceRun := True
    else if (LParam = '--clean') or (LParam = '-c') then
      FForceClean := True
    else if LParam = '--no-build' then
      FNoBuild := True
    else if LParam = '--no-run' then
      FNoRun := True
    else if LParam = '--no-clean' then
      FNoClean := True
    else
    begin
      // It's a test specification
      LTestSpec := ParamStr(LI);
      ATestNumbers := ParseTestSpec(LTestSpec);
    end;

    Inc(LI);
  end;
end;

function TTester.ParseTestSpec(const ASpec: string): TArray<Integer>;
var
  LParts: TArray<string>;
  LPart: string;
  LRangeNumbers: TArray<Integer>;
  LAllNumbers: TList<Integer>;
  LNum: Integer;
  LEntry: TTesterEntry;
  LPartItem: string;
begin
  LAllNumbers := TList<Integer>.Create();
  try
    // Handle "all" keyword
    if LowerCase(ASpec) = 'all' then
    begin
      for LEntry in FTests do
        LAllNumbers.Add(LEntry.Number);
    end
    else
    begin
      // Split by comma
      LParts := ASpec.Split([',']);

      for LPartItem in LParts do
      begin
        LPart := Trim(LPartItem);

        // Check if it's a range (contains '-')
        if Pos('-', LPart) > 0 then
        begin
          LRangeNumbers := ParseRange(LPart);
          for LNum in LRangeNumbers do
            LAllNumbers.Add(LNum);
        end
        else
        begin
          // Single number
          if TryStrToInt(LPart, LNum) then
            LAllNumbers.Add(LNum);
        end;
      end;
    end;

    Result := LAllNumbers.ToArray();
  finally
    LAllNumbers.Free();
  end;
end;

function TTester.ParseRange(const ARange: string): TArray<Integer>;
var
  LParts: TArray<string>;
  LStart: Integer;
  LEnd: Integer;
  LI: Integer;
  LList: TList<Integer>;
begin
  SetLength(Result, 0);

  LParts := ARange.Split(['-']);
  if Length(LParts) <> 2 then
    Exit;

  if not TryStrToInt(Trim(LParts[0]), LStart) then
    Exit;

  if not TryStrToInt(Trim(LParts[1]), LEnd) then
    Exit;

  if LStart > LEnd then
    Exit;

  LList := TList<Integer>.Create();
  try
    for LI := LStart to LEnd do
      LList.Add(LI);

    Result := LList.ToArray();
  finally
    LList.Free();
  end;
end;

procedure TTester.CleanProjectFolder;
begin
  if TDirectory.Exists(FProjectFolder) then
  begin
    TUtils.PrintLn();
    TUtils.PrintLn('=== CLEANING PROJECT ===');
    TDirectory.Delete(FProjectFolder, True);
    TUtils.PrintLn('✓ Removed project folder');
    TUtils.PrintLn('');
  end;
end;

procedure TTester.DisplayPascalSource(const APasFile: string);
var
  LContent: string;
  LTitle: string;
begin
  LTitle := ExtractFileName(APasFile);

  if TFile.Exists(APasFile) then
  begin
    TUtils.PrintLn();
    TUtils.PrintLn('=== PASCAL SOURCE: %s ===', [LTitle]);
    TUtils.PrintLn();
    LContent := TFile.ReadAllText(APasFile, TEncoding.UTF8);
    TUtils.PrintLn(LContent);
    TUtils.PrintLn();
  end
  else
  begin
    TUtils.PrintLn();
    TUtils.PrintLn('=== PASCAL SOURCE: %s ===', [LTitle]);
    TUtils.PrintLn('File not found: %s', [APasFile]);
    TUtils.PrintLn();
  end;
end;

procedure TTester.DisplayXMLForUnit(const APasFile: string);
var
  LBuilder: TPasSyntaxTreeBuilder;
  LTree: TSyntaxNode;
  LXml: string;
  LTitle: string;
begin
  LTitle := ExtractFileName(APasFile);

  TUtils.PrintLn();
  TUtils.PrintLn('=== XML AST OUTPUT: %s ===', [LTitle]);
  TUtils.PrintLn();

  LBuilder := TPasSyntaxTreeBuilder.Create();
  try
    LTree := LBuilder.Run(APasFile);
    try
      if Assigned(LTree) then
      begin
        LXml := TSyntaxTreeWriter.ToXML(LTree, True);
        TUtils.PrintLn(LXml);
      end
      else
        TUtils.PrintLn('Failed to parse for XML output');
    finally
      LTree.Free();
    end;
  finally
    LBuilder.Free();
  end;

  TUtils.PrintLn();
end;

procedure TTester.DisplayGeneratedFile(const AFilePath: string);
var
  LContent: string;
  LTitle: string;
begin
  LTitle := ExtractFileName(AFilePath);

  if TFile.Exists(AFilePath) then
  begin
    TUtils.PrintLn();
    TUtils.PrintLn('=== %s ===', [LTitle]);
    TUtils.PrintLn();
    LContent := TFile.ReadAllText(AFilePath, TEncoding.UTF8);
    TUtils.PrintLn(LContent);
    TUtils.PrintLn();
  end
  else
  begin
    TUtils.PrintLn();
    TUtils.PrintLn('=== %s ===', [LTitle]);
    TUtils.PrintLn('File not found: %s', [AFilePath]);
    TUtils.PrintLn();
  end;
end;

procedure TTester.ExecuteTest(const ATestNum: Integer);
var
  LEntry: TTesterEntry;
begin
  if not FindTest(ATestNum, LEntry) then
  begin
    TUtils.PrintLn('%sError: Test %d not found%s', [COLOR_RED, ATestNum, COLOR_RESET]);
    Exit;
  end;

  ExecuteTestInternal(LEntry);
end;

procedure TTester.ExecuteTestInternal(const AEntry: TTesterEntry);
var
  LSourceFile: string;
  LOutputDir: string;
  LProjectName: string;
  LProjectDir: string;
  LFilePath: string;
  LUnitInfo: TProjectIndexer.TUnitInfo;
  LStartTime: TDateTime;
  LElapsed: Double;
  LExitCode: DWORD;
  LBuild: Boolean;
  LRun: Boolean;
  LClean: Boolean;
begin
  // Reset compiler instances for clean state
  Reset();
  
  // Apply test defaults
  LBuild := AEntry.Build;
  LRun := AEntry.Run;
  LClean := AEntry.Clean;

  // Apply CLI overrides
  if FNoBuild then
    LBuild := False;
  if FNoRun then
    LRun := False;
  if FNoClean then
    LClean := False;
  if FForceBuild then
    LBuild := True;
  if FForceRun then
    LRun := True;
  if FForceClean then
    LClean := True;

  // Construct paths
  LSourceFile := TPath.Combine(AEntry.SourcePath, AEntry.Filename);
  LOutputDir := TPath.Combine(FProjectFolder, 'generated');
  LProjectName := ChangeFileExt(ExtractFileName(AEntry.Filename), '');
  LProjectDir := FProjectFolder;

  // Show test header
  TUtils.PrintLn('');
  TUtils.PrintLn(COLOR_BOLD + '[%s] %s' + COLOR_RESET, [Format('%.3d', [AEntry.Number]), AEntry.Filename]);

  LStartTime := Now;

  try
    TUtils.PrintLn('Blaise Pascal Transpiler');
    TUtils.PrintLn('========================');
    TUtils.PrintLn();

    TUtils.PrintLn('Processing: %s', [LSourceFile]);
    TUtils.PrintLn('Output to: %s', [LOutputDir]);
    TUtils.PrintLn();

    // Clear previous errors
    FErrors.Clear();

    // Process the file
    if FCodeGen.Process(LSourceFile, LOutputDir, FPreprocessor, FErrors) then
    begin
      // Display Pascal source if requested
      if FShowPascal then
      begin
        for LUnitInfo in FCodeGen.GetParsedUnits() do
        begin
          DisplayPascalSource(LUnitInfo.Path);
        end;
      end;

      // Display XML if requested
      if FShowXML then
      begin
        DisplayXMLForUnit(LSourceFile);
      end;

      TUtils.PrintLn('✓ Code generation successful');
      TUtils.PrintLn();

      // Display generated C++ files if requested
      if FShowCPP then
      begin
        TUtils.PrintLn('Generated files in: %s', [LOutputDir]);
        TUtils.PrintLn();

        for LFilePath in FCodeGen.GetGeneratedFiles() do
        begin
          DisplayGeneratedFile(LFilePath);
        end;
      end;

      // Build if requested
      if LBuild then
      begin
        FBuild.SetProjectName(LProjectName);
        FBuild.SetProjectDir(LProjectDir);
        FBuild.SetOptimizeMode(omDebug);

        TUtils.PrintLn('Building project...');
        TUtils.PrintLn();

        if FBuild.ExecuteBuild(FPreprocessor, FCodeGen, FErrors, LExitCode) then
        begin
          TUtils.PrintLn();
          TUtils.PrintLn('✓ Build successful');
          TUtils.PrintLn();

          // Run if requested
          if LRun then
          begin
            TUtils.PrintLn('Running executable...');
            TUtils.PrintLn();

            LExitCode := 0;
            FBuild.Run(FErrors, LExitCode);

            TUtils.PrintLn();
            TUtils.PrintLn('Exit code: %d (expected: %d)', [LExitCode, AEntry.ExpectedExitCode]);

            // Validate exit code
            if LExitCode <> AEntry.ExpectedExitCode then
            begin
              raise Exception.CreateFmt('Exit code mismatch: expected %d, got %d',
                [AEntry.ExpectedExitCode, LExitCode]);
            end;
          end;
        end
        else
        begin
          TUtils.PrintLn('✗ Build failed');
          TUtils.PrintLn();
          FErrors.PrintToConsole();
          raise Exception.Create('Build failed');
        end;
      end;

      // Clean if requested
      if LClean then
        CleanProjectFolder();

    end
    else
    begin
      TUtils.PrintLn('✗ Code generation failed');
      TUtils.PrintLn();
      FErrors.PrintToConsole();
      raise Exception.Create('Code generation failed');
    end;

    // Display any remaining errors
    if FErrors.HasErrors() then
    begin
      TUtils.PrintLn();
      FErrors.PrintToConsole();
    end;

    // Calculate elapsed time
    LElapsed := (Now - LStartTime) * 86400;

    // Show success
    TUtils.PrintLn('      %s✓ PASSED%s (%.1fs)', [COLOR_GREEN, COLOR_RESET, LElapsed]);
    Inc(FPassedCount);

  except
    on E: Exception do
    begin
      // Calculate elapsed time
      LElapsed := (Now - LStartTime) * 86400;

      // Show failure
      TUtils.PrintLn('      %s✗ FAILED%s (%.1fs)', [COLOR_RED, COLOR_RESET, LElapsed]);
      TUtils.PrintLn('      Error: %s', [E.Message]);
      Inc(FFailedCount);
      FFailedTests.Add(Format('[%.3d] %s', [AEntry.Number, AEntry.Filename]));
    end;
  end;

  Inc(FTotalCount);
end;

procedure TTester.RunTest(const ANum: Integer);
begin
  FPassedCount := 0;
  FFailedCount := 0;
  FTotalCount := 0;
  FFailedTests.Clear();

  ExecuteTest(ANum);
end;

procedure TTester.RunTests(const ANumbers: TArray<Integer>);
var
  LNum: Integer;
  LFailedTest: string;
begin
  FPassedCount := 0;
  FFailedCount := 0;
  FTotalCount := 0;
  FFailedTests.Clear();

  if Length(ANumbers) = 0 then
    Exit;

  ShowBanner();
  TUtils.PrintLn('Running %d tests', [Length(ANumbers)]);
  ShowSeparator();

  for LNum in ANumbers do
    ExecuteTest(LNum);

  ShowSeparator();
  TUtils.PrintLn('');
  TUtils.PrintLn(COLOR_BOLD + 'Results: ' + COLOR_RESET +
    COLOR_GREEN + '%d passed' + COLOR_RESET + ', ' +
    COLOR_RED + '%d failed' + COLOR_RESET + ', ' +
    '%d total',
    [FPassedCount, FFailedCount, FTotalCount]);
  TUtils.PrintLn('');

  if FFailedCount > 0 then
  begin
    TUtils.PrintLn(COLOR_RED + COLOR_BOLD + 'FAILED TESTS:' + COLOR_RESET);
    for LFailedTest in FFailedTests do
      TUtils.PrintLn('  %s', [LFailedTest]);
    TUtils.PrintLn('');
  end;
end;

procedure TTester.Run;
var
  LCommand: string;
  LTestNumbers: TArray<Integer>;
  LVersion: TVersionInfo;
begin
  ParseCommandLine(LCommand, LTestNumbers);

  // Handle commands
  if (LCommand = 'help') or (LCommand = '-h') or (LCommand = '--help') then
  begin
    ShowHelp();
    Exit;
  end;

  if (LCommand = 'version') or (LCommand = '--version') then
  begin
    ShowBanner();
    if TUtils.GetVersionInfo(LVersion) then
      TUtils.PrintLn('Version: %s', [LVersion.VersionString])
    else
      TUtils.PrintLn('Version: Unknown');
    TUtils.PrintLn('');
    TUtils.PrintLn('Copyright © 2025-present tinyBigGAMES™ LLC');
    TUtils.PrintLn('All Rights Reserved.');
    TUtils.PrintLn('');
    Exit;
  end;

  if LCommand = 'list' then
  begin
    ShowTestList();
    Exit;
  end;

  if LCommand = 'run' then
  begin
    if Length(LTestNumbers) = 0 then
    begin
      TUtils.PrintLn('');
      TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + 'No tests specified');
      TUtils.PrintLn('');
      TUtils.PrintLn('Usage: tester run <tests>');
      TUtils.PrintLn('Example: tester run 1-10');
      TUtils.PrintLn('');
      Exit;
    end;

    RunTests(LTestNumbers);
    Exit;
  end;

  // Unknown command or no command - show help
  if LCommand <> '' then
  begin
    TUtils.PrintLn('');
    TUtils.PrintLn(COLOR_RED + 'Error: ' + COLOR_RESET + 'Unknown command: ' + COLOR_YELLOW + LCommand + COLOR_RESET);
    TUtils.PrintLn('');
  end;

  ShowHelp();
end;

end.
