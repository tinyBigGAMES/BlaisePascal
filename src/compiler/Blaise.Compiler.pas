{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.Compiler;

{$I Blaise.Defines.inc}

interface

uses
  WinApi.Windows,
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  Blaise.Errors,
  Blaise.CodeGen,
  Blaise.Preprocessing,
  Blaise.Build,
  Blaise.Utils;

const
  tpProgram = Blaise.Build.tpProgram;
  tpLibrary = Blaise.Build.tpLibrary;
  tpUnit    = Blaise.Build.tpUnit;

type
  TTemplateType = Blaise.Build.TTemplateType;


  { TCompiler }
  TCompiler = class
  private
    FCodeGen: TCodeGen;
    FErrors: TErrors;
    FPreprocessor: TPreprocessor;
    FBuild: TBuild;

    procedure Reset();

  public
    constructor Create();
    destructor Destroy(); override;

    procedure SetProjectDir(const ADir: string);
    procedure SetProjectName(const AName: string);


    // Main API methods
    procedure Init(const AProjectName: string; const ABaseDir: string; const ATemplate: TTemplateType);
    procedure Build(const ACompileOnly: Boolean = False);
    procedure Run();
    procedure Clean();
    procedure Zig(const AArgs: string);

    // Build configuration methods - delegate to TBuild
    procedure SetTarget(const ATarget: string);
    procedure SetOptimizeMode(const AMode: TOptimizeMode);
    procedure SetEnableExceptions(const AEnable: Boolean);
    procedure SetStripSymbols(const AStrip: Boolean);
    procedure SetAppType(const AAppType: TAppType);

    procedure AddModulePath(const APath: string);
    procedure AddIncludePath(const APath: string);
    procedure AddLibraryPath(const APath: string);
    procedure AddLinkLibrary(const ALibrary: string);
    procedure AddIncludeHeader(const AHeader: string);

    procedure ClearModulePaths();
    procedure ClearIncludePaths();
    procedure ClearLibraryPaths();
    procedure ClearLinkLibraries();

    procedure ResetBuildSettings();

    // Access to component instances
    function GetCodeGen(): TCodeGen;
    function GetErrors(): TErrors;
    function GetPreprocessor(): TPreprocessor;
    function GetBuild(): TBuild;
  end;

implementation

const
  TEMPLATE_PROGRAM =
  '''
  program %s;
  begin
    WriteLn('Hello world, welcome to Blaise Pascal™!');
  end.
  ''';

  TEMPLATE_LIBRARY =
  '''
  library %s;

  function LibAdd(A: Integer; B: Integer): Integer; cdecl;
  begin
    Result := A + B;
  end;

  function LibMultiply(A: Integer; B: Integer): Integer; stdcall;
  begin
    Result := A * B;
  end;

  exports
    LibAdd,
    LibMultiply;

  begin
  end.
  ''';

  TEMPLATE_UNIT =
  '''
  unit %s;

  interface

  function LibAdd(A: Integer; B: Integer): Integer; cdecl;
  function LibMultiply(A: Integer; B: Integer): Integer; stdcall;

  implementation

  function LibAdd(A: Integer; B: Integer): Integer; cdecl;
  begin
    Result := A + B;
  end;

  function LibMultiply(A: Integer; B: Integer): Integer; stdcall;
  begin
    Result := A * B;
  end;

  end.
  ''';

{ TCompiler }

constructor TCompiler.Create();
begin
  inherited Create();

  FCodeGen := TCodeGen.Create();
  FErrors := TErrors.Create();
  FPreprocessor := TPreprocessor.Create();
  FBuild := TBuild.Create();
end;

destructor TCompiler.Destroy();
begin
  if Assigned(FCodeGen) then
    FCodeGen.Free();
  if Assigned(FErrors) then
    FErrors.Free();
  if Assigned(FPreprocessor) then
    FPreprocessor.Free();
  if Assigned(FBuild) then
    FBuild.Free();

  inherited Destroy();
end;

procedure TCompiler.Reset();
begin
  if Assigned(FCodeGen) then
    FCodeGen.Free();
  if Assigned(FErrors) then
    FErrors.Free();
  if Assigned(FPreprocessor) then
    FPreprocessor.Free();
  if Assigned(FBuild) then
    FBuild.Free();

  FCodeGen := TCodeGen.Create();
  FErrors := TErrors.Create();
  FPreprocessor := TPreprocessor.Create();
  FBuild := TBuild.Create();
end;

procedure TCompiler.SetProjectDir(const ADir: string);
begin
  FBuild.SetProjectDir(ADir);
end;

procedure TCompiler.SetProjectName(const AName: string);
begin
  FBuild.SetProjectName(AName);
end;

procedure TCompiler.Init(const AProjectName: string; const ABaseDir: string; const ATemplate: TTemplateType);
var
  LProjectDir: string;
  LSrcDir: string;
  LMainFile: string;
  LTemplateContent: string;
begin
  Reset();

  FBuild.PrintLn('Initializing new project: %s', [AProjectName]);
  FBuild.PrintLn('');

  LProjectDir := TPath.Combine(ABaseDir, AProjectName);
  LSrcDir := TPath.Combine(LProjectDir, 'src');

  if TDirectory.Exists(LProjectDir) then
  begin
    FErrors.AddErrorSimple('Project directory already exists: %s', [LProjectDir]);
    raise Exception.CreateFmt('Project directory already exists: %s', [LProjectDir]);
  end;

  TDirectory.CreateDirectory(LProjectDir);
  TDirectory.CreateDirectory(LSrcDir);
  TDirectory.CreateDirectory(TPath.Combine(LProjectDir, 'generated'));

  case ATemplate of
    tpProgram:
      LTemplateContent := Format(TEMPLATE_PROGRAM, [AProjectName]);
    tpLibrary:
      LTemplateContent := Format(TEMPLATE_LIBRARY, [AProjectName]);
    tpUnit:
      LTemplateContent := Format(TEMPLATE_UNIT, [AProjectName]);
  else
    LTemplateContent := Format(TEMPLATE_PROGRAM, [AProjectName]);
  end;

  LMainFile := TPath.Combine(LSrcDir, AProjectName + '.pas');
  TFile.WriteAllText(LMainFile, LTemplateContent, TEncoding.UTF8);

  FBuild.SetProjectName(AProjectName);
  FBuild.SetProjectDir(LProjectDir);
  FBuild.SetTemplateType(ATemplate);

  FBuild.PrintLn('✓ Created project structure');
  FBuild.PrintLn('✓ Created %s', [ExtractFileName(LMainFile)]);
  FBuild.PrintLn('');
  FBuild.PrintLn('Project initialized at: %s', [LProjectDir]);
end;

procedure TCompiler.Build(const ACompileOnly: Boolean);
var
  LProjectDir: string;
  LProjectName: string;
  LSrcDir: string;
  LMainPasPath: string;
  LEntryPointName: string;
  LOutputDir: string;
  LExitCode: DWORD;
begin
  LProjectDir := FBuild.GetProjectDir();
  LProjectName := FBuild.GetProjectName();

  if LProjectDir.IsEmpty then
    LProjectDir := GetCurrentDir();

  if LProjectName.IsEmpty then
    LProjectName := TPath.GetFileName(LProjectDir);

  FBuild.SetProjectDir(LProjectDir);
  FBuild.SetProjectName(LProjectName);

  LSrcDir := TPath.Combine(LProjectDir, 'src');
  LOutputDir := TPath.Combine(LProjectDir, 'generated');

  if not TDirectory.Exists(LSrcDir) then
    raise Exception.Create('Error: src/ directory not found');

  TUtils.CreateDirInPath(LOutputDir);

  LMainPasPath := TPath.Combine(LSrcDir, LProjectName + '.pas');

  if TFile.Exists(LMainPasPath) then
  begin
    LEntryPointName := LProjectName + '.pas';
  end
  else
  begin
    LMainPasPath := TPath.Combine(LSrcDir, 'main.pas');
    if TFile.Exists(LMainPasPath) then
    begin
      LEntryPointName := 'main.pas';
    end
    else
    begin
      raise Exception.Create('Error: No entry point found. Expected src/' + LProjectName + '.pas or src/main.pas');
    end;
  end;

  FBuild.PrintLn('Entry point: ' + LEntryPointName);
  FBuild.PrintLn('Compiling Blaise Pascal to C++...');

  if not FCodeGen.Process(LMainPasPath, LOutputDir, FPreprocessor, FErrors) then
  begin
    FErrors.PrintToConsole();
    raise Exception.Create('Transpilation failed');
  end;

  FBuild.PrintLn('✓ Transpilation complete');

  if ACompileOnly then
    Exit;

  if not FBuild.ExecuteBuild(FPreprocessor, FCodeGen, FErrors, LExitCode) then
  begin
    FErrors.PrintToConsole();
    raise Exception.Create('Build failed');
  end;
end;

procedure TCompiler.Run();
var
  LProjectDir: string;
  LProjectName: string;
  LExitCode: DWORD;
begin
  LProjectDir := FBuild.GetProjectDir();
  LProjectName := FBuild.GetProjectName();

  if LProjectDir.IsEmpty then
    LProjectDir := GetCurrentDir();

  if LProjectName.IsEmpty then
    LProjectName := TPath.GetFileName(LProjectDir);

  FBuild.SetProjectDir(LProjectDir);
  FBuild.SetProjectName(LProjectName);

  LExitCode := 0;
  if not FBuild.Run(FErrors, LExitCode) then
  begin
    if FErrors.HasErrors() then
      FErrors.PrintToConsole();
  end;
end;

procedure TCompiler.Clean();
var
  LProjectDir: string;
  LProjectName: string;
begin
  LProjectDir := FBuild.GetProjectDir();
  LProjectName := FBuild.GetProjectName();

  if LProjectDir.IsEmpty then
    LProjectDir := GetCurrentDir();

  if LProjectName.IsEmpty then
    LProjectName := TPath.GetFileName(LProjectDir);

  FBuild.SetProjectDir(LProjectDir);
  FBuild.SetProjectName(LProjectName);

  if not FBuild.Clean(FErrors) then
  begin
    if FErrors.HasErrors() then
      FErrors.PrintToConsole();
    raise Exception.Create('Clean failed');
  end;
end;

procedure TCompiler.Zig(const AArgs: string);
var
  LZigExe: string;
  LExitCode: DWORD;
  LWorkDir: string;
  LProjectDir: string;
begin
  LZigExe := TUtils.GetZigExePath();
  if not TFile.Exists(LZigExe) then
  begin
    FBuild.PrintLn('');
    FBuild.PrintLn('Error: Zig EXE was not found...');
    Exit;
  end;

  LProjectDir := FBuild.GetProjectDir();
  if not LProjectDir.IsEmpty then
    LWorkDir := LProjectDir
  else
    LWorkDir := GetCurrentDir();

  LExitCode := 0;

  TUtils.CaptureZigConsoleOutput(
    'Zig Command',
    PChar(LZigExe),
    PChar(AArgs),
    LWorkDir,
    LExitCode,
    nil,
    procedure(const ALine: string; const AUserData: Pointer)
    var
      LTrimmed: string;
    begin
      LTrimmed := ALine.Trim();
      if LTrimmed = '' then
        Exit;

      if (LTrimmed[1] = '[') then
      begin
        FBuild.Print(#13 + '  ' + LTrimmed + #27'[K');
      end
      else
      begin
        FBuild.PrintLn('  %s', [LTrimmed]);
      end;
    end
  );

  if LExitCode <> 0 then
    raise Exception.CreateFmt('Zig command failed with exit code %d', [LExitCode]);
end;

procedure TCompiler.SetTarget(const ATarget: string);
begin
  FBuild.SetTarget(ATarget);
end;

procedure TCompiler.SetOptimizeMode(const AMode: TOptimizeMode);
begin
  FBuild.SetOptimizeMode(AMode);
end;

procedure TCompiler.SetEnableExceptions(const AEnable: Boolean);
begin
  FBuild.SetEnableExceptions(AEnable);
end;

procedure TCompiler.SetStripSymbols(const AStrip: Boolean);
begin
  FBuild.SetStripSymbols(AStrip);
end;

procedure TCompiler.SetAppType(const AAppType: TAppType);
begin
  FBuild.SetAppType(AAppType);
end;

procedure TCompiler.AddModulePath(const APath: string);
begin
  FBuild.AddModulePath(APath);
end;

procedure TCompiler.AddIncludePath(const APath: string);
begin
  FBuild.AddIncludePath(APath);
end;

procedure TCompiler.AddLibraryPath(const APath: string);
begin
  FBuild.AddLibraryPath(APath);
end;

procedure TCompiler.AddLinkLibrary(const ALibrary: string);
begin
  FBuild.AddLinkLibrary(ALibrary);
end;

procedure TCompiler.AddIncludeHeader(const AHeader: string);
begin
  FBuild.AddIncludeHeader(AHeader);
end;

procedure TCompiler.ClearModulePaths();
begin
  FBuild.ClearModulePaths();
end;

procedure TCompiler.ClearIncludePaths();
begin
  FBuild.ClearIncludePaths();
end;

procedure TCompiler.ClearLibraryPaths();
begin
  FBuild.ClearLibraryPaths();
end;

procedure TCompiler.ClearLinkLibraries();
begin
  FBuild.ClearLinkLibraries();
end;

procedure TCompiler.ResetBuildSettings();
begin
  FBuild.Reset();
end;

function TCompiler.GetCodeGen(): TCodeGen;
begin
  Result := FCodeGen;
end;

function TCompiler.GetErrors(): TErrors;
begin
  Result := FErrors;
end;

function TCompiler.GetPreprocessor(): TPreprocessor;
begin
  Result := FPreprocessor;
end;

function TCompiler.GetBuild(): TBuild;
begin
  Result := FBuild;
end;

end.
