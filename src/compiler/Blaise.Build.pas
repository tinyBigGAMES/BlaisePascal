{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.Build;

{$I Blaise.Defines.inc}

interface

uses
  WinApi.Windows,
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  Blaise.Errors,
  Blaise.Utils,
  Blaise.CodeGen,
  Blaise.Preprocessing;

type
  { TOptimizeMode }
  TOptimizeMode = (
    omDebug,
    omReleaseSafe,
    omReleaseFast,
    omReleaseSmall
  );

  { TTemplateType }
  TTemplateType = (
    tpProgram,
    tpLibrary,
    tpUnit
  );

  { TAppType }
  TAppType = (
    atConsole,
    atGUI
  );

  { TOutputCallback }
  TOutputCallback = reference to procedure(const AText: string; const AUserData: Pointer);

  { TBuild }
  TBuild = class
  private
    FProjectName: string;
    FProjectDir: string;
    FTemplateType: TTemplateType;
    FTarget: string;
    FOptimizeMode: TOptimizeMode;
    FEnableExceptions: Boolean;
    FStripSymbols: Boolean;
    FAppType: TAppType;
    FModulePaths: TDictionary<string, Boolean>;
    FIncludePaths: TDictionary<string, Boolean>;
    FSourcePaths: TDictionary<string, Boolean>;
    FLibraryPaths: TDictionary<string, Boolean>;
    FLinkLibraries: TDictionary<string, Boolean>;
    FIncludeHeaders: TDictionary<string, Boolean>;
    FSourceFiles: TDictionary<string, Boolean>;
    FOutputCallback: TCallback<TOutputCallback>;

    function IsValidIdentifier(const AValue: string): Boolean;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Print(const AText: string); overload;
    procedure Print(const AText: string; const AArgs: array of const); overload;
    procedure PrintLn(const AText: string); overload;
    procedure PrintLn(const AText: string; const AArgs: array of const); overload;

    procedure SetProjectName(const AValue: string);
    function GetProjectName(): string;
    procedure SetProjectDir(const AValue: string);
    function GetProjectDir(): string;
    procedure SetTemplateType(const AValue: TTemplateType);
    function GetTemplateType(): TTemplateType;

    procedure SetTarget(const ATarget: string);
    function GetTarget(): string;
    procedure SetOptimizeMode(const AMode: TOptimizeMode);
    function GetOptimizeMode(): TOptimizeMode;
    procedure SetEnableExceptions(const AEnable: Boolean);
    function GetEnableExceptions(): Boolean;
    procedure SetStripSymbols(const AStrip: Boolean);
    function GetStripSymbols(): Boolean;
    procedure SetAppType(const AAppType: TAppType);
    function GetAppType(): TAppType;

    procedure AddModulePath(const APath: string);
    procedure AddIncludePath(const APath: string);
    procedure AddSourcePath(const APath: string);
    procedure AddLibraryPath(const APath: string);
    procedure AddLinkLibrary(const ALibrary: string);
    procedure AddIncludeHeader(const AHeader: string);
    procedure AddSourceFile(const AFilename: string);

    procedure ClearModulePaths();
    procedure ClearIncludePaths();
    procedure ClearSourcePaths();
    procedure ClearLibraryPaths();
    procedure ClearLinkLibraries();
    procedure ClearIncludeHeaders();
    procedure ClearSourceFiles();

    function GetModulePaths(): TArray<string>;
    function GetIncludePaths(): TArray<string>;
    function GetSourcePaths(): TArray<string>;
    function GetLibraryPaths(): TArray<string>;
    function GetLinkLibraries(): TArray<string>;
    function GetIncludeHeaders(): TArray<string>;
    function GetSourceFiles(): TArray<string>;

    function NormalizePath(const APath: string): string;
    function MakeRelativePath(const ABasePath: string; const ATargetPath: string): string;
    function ValidateAndNormalizeTarget(const ATarget: string): string;
    procedure Reset();

    procedure SetOutputCallback(const ACallback: TOutputCallback; const AUserData: Pointer);

    function GenerateBuildZig(const APreprocessor: TPreprocessor; const ACodeGen: TCodeGen; const AErrors: TErrors): Boolean;
    function ExecuteBuild(const APreprocessor: TPreprocessor; const ACodeGen: TCodeGen; const AErrors: TErrors; var AExitCode: DWORD): Boolean;
    function Clean(const AErrors: TErrors): Boolean;
    function Run(const AErrors: TErrors; var AExitCode: DWORD): Boolean;
  end;

implementation

{ TBuild }

constructor TBuild.Create();
begin
  inherited Create();

  FProjectName := '';
  FProjectDir := '';
  FTemplateType := tpProgram;
  FTarget := '';
  FOptimizeMode := omDebug;
  FEnableExceptions := True;
  FStripSymbols := False;
  FAppType := atConsole;

  FModulePaths := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal);
  FIncludePaths := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal);
  FSourcePaths := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal);
  FLibraryPaths := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal);
  FLinkLibraries := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal);
  FIncludeHeaders := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal);
  FSourceFiles := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal);

  AddIncludePath('.\res\runtime');
  AddSourcePath('.\res\runtime');

  AddIncludePath('.\res\libs\raylib\inc');

end;

destructor TBuild.Destroy();
begin
  FreeAndNil(FModulePaths);
  FreeAndNil(FIncludePaths);
  FreeAndNil(FSourcePaths);
  FreeAndNil(FLibraryPaths);
  FreeAndNil(FLinkLibraries);
  FreeAndNil(FIncludeHeaders);
  FreeAndNil(FSourceFiles);

  inherited Destroy();
end;

function TBuild.IsValidIdentifier(const AValue: string): Boolean;
var
  LI: Integer;
  LC: Char;
begin
  Result := False;

  if AValue.IsEmpty then
    Exit;

  for LI := 1 to AValue.Length do
  begin
    LC := AValue[LI];
    if not CharInSet(LC, ['a'..'z', '0'..'9', '_']) then
      Exit;
  end;

  Result := True;
end;

procedure TBuild.Print(const AText: string);
begin
  if Assigned(FOutputCallback.Callback) then
    FOutputCallback.Callback(AText, FOutputCallback.UserData)
  else
    TUtils.Print(AText);
end;

procedure TBuild.Print(const AText: string; const AArgs: array of const);
begin
  Print(Format(AText, AArgs));
end;

procedure TBuild.PrintLn(const AText: string);
begin
  if Assigned(FOutputCallback.Callback) then
    FOutputCallback.Callback(AText + sLineBreak, FOutputCallback.UserData)
  else
    TUtils.PrintLn(AText);
end;

procedure TBuild.PrintLn(const AText: string; const AArgs: array of const);
begin
  PrintLn(Format(AText, AArgs));
end;

procedure TBuild.SetProjectName(const AValue: string);
begin
  FProjectName := AValue;
end;

function TBuild.GetProjectName(): string;
begin
  Result := FProjectName;
end;

procedure TBuild.SetProjectDir(const AValue: string);
begin
  FProjectDir := AValue;
end;

function TBuild.GetProjectDir(): string;
begin
  Result := FProjectDir;
end;

procedure TBuild.SetTemplateType(const AValue: TTemplateType);
begin
  FTemplateType := AValue;
end;

function TBuild.GetTemplateType(): TTemplateType;
begin
  Result := FTemplateType;
end;

procedure TBuild.SetTarget(const ATarget: string);
begin
  FTarget := ValidateAndNormalizeTarget(ATarget);
end;

function TBuild.GetTarget(): string;
begin
  Result := FTarget;
end;

procedure TBuild.SetOptimizeMode(const AMode: TOptimizeMode);
begin
  FOptimizeMode := AMode;
end;

function TBuild.GetOptimizeMode(): TOptimizeMode;
begin
  Result := FOptimizeMode;
end;

procedure TBuild.SetEnableExceptions(const AEnable: Boolean);
begin
  FEnableExceptions := AEnable;
end;

function TBuild.GetEnableExceptions(): Boolean;
begin
  Result := FEnableExceptions;
end;

procedure TBuild.SetStripSymbols(const AStrip: Boolean);
begin
  FStripSymbols := AStrip;
end;

function TBuild.GetStripSymbols(): Boolean;
begin
  Result := FStripSymbols;
end;

procedure TBuild.SetAppType(const AAppType: TAppType);
begin
  FAppType := AAppType;
end;

function TBuild.GetAppType(): TAppType;
begin
  Result := FAppType;
end;

procedure TBuild.AddModulePath(const APath: string);
begin
  if APath <> '' then
    FModulePaths.AddOrSetValue(APath, True);
end;

procedure TBuild.AddIncludePath(const APath: string);
begin
  if APath <> '' then
    FIncludePaths.AddOrSetValue(APath, True);
end;

procedure TBuild.AddSourcePath(const APath: string);
begin
  if APath <> '' then
    FSourcePaths.AddOrSetValue(APath, True);
end;

procedure TBuild.AddLibraryPath(const APath: string);
begin
  if APath <> '' then
    FLibraryPaths.AddOrSetValue(APath, True);
end;

procedure TBuild.AddLinkLibrary(const ALibrary: string);
begin
  if ALibrary <> '' then
    FLinkLibraries.AddOrSetValue(ALibrary, True);
end;

procedure TBuild.AddIncludeHeader(const AHeader: string);
begin
  if AHeader <> '' then
    FIncludeHeaders.AddOrSetValue(AHeader, True);
end;

procedure TBuild.AddSourceFile(const AFilename: string);
begin
  if AFilename <> '' then
    FSourceFiles.TryAdd(AFilename, True);
end;

procedure TBuild.ClearModulePaths();
begin
  FModulePaths.Clear();
end;

procedure TBuild.ClearIncludePaths();
begin
  FIncludePaths.Clear();
end;

procedure TBuild.ClearSourcePaths();
begin
  FSourcePaths.Clear();
end;

procedure TBuild.ClearLibraryPaths();
begin
  FLibraryPaths.Clear();
end;

procedure TBuild.ClearLinkLibraries();
begin
  FLinkLibraries.Clear();
end;

procedure TBuild.ClearIncludeHeaders();
begin
  FIncludeHeaders.Clear();
end;

procedure TBuild.ClearSourceFiles();
begin
  FSourceFiles.Clear();
end;

function TBuild.GetModulePaths(): TArray<string>;
begin
  Result := FModulePaths.Keys.ToArray();
end;

function TBuild.GetIncludePaths(): TArray<string>;
begin
  Result := FIncludePaths.Keys.ToArray();
end;

function TBuild.GetSourcePaths(): TArray<string>;
begin
  Result := FSourcePaths.Keys.ToArray();
end;

function TBuild.GetLibraryPaths(): TArray<string>;
begin
  Result := FLibraryPaths.Keys.ToArray();
end;

function TBuild.GetLinkLibraries(): TArray<string>;
begin
  Result := FLinkLibraries.Keys.ToArray();
end;

function TBuild.GetIncludeHeaders(): TArray<string>;
begin
  Result := FIncludeHeaders.Keys.ToArray();
end;

function TBuild.GetSourceFiles(): TArray<string>;
begin
  Result := FSourceFiles.Keys.ToArray();
end;

function TBuild.NormalizePath(const APath: string): string;
begin
  Result := StringReplace(APath, '\', '/', [rfReplaceAll]);
end;

function TBuild.MakeRelativePath(const ABasePath: string; const ATargetPath: string): string;
var
  LBase: string;
  LTarget: string;
  LBaseParts: TArray<string>;
  LTargetParts: TArray<string>;
  LCommonCount: Integer;
  LI: Integer;
  LRelativeParts: TList<string>;
begin
  // Normalize both paths to use forward slashes
  LBase := NormalizePath(TPath.GetFullPath(ABasePath));
  LTarget := NormalizePath(TPath.GetFullPath(ATargetPath));

  // If paths are the same, return current directory
  if SameText(LBase, LTarget) then
    Exit('.');

  // Split paths into parts
  LBaseParts := LBase.Split(['/']);
  LTargetParts := LTarget.Split(['/']);

  // Find common prefix
  LCommonCount := 0;
  while (LCommonCount < Length(LBaseParts)) and
        (LCommonCount < Length(LTargetParts)) and
        SameText(LBaseParts[LCommonCount], LTargetParts[LCommonCount]) do
    Inc(LCommonCount);

  // Build relative path
  LRelativeParts := TList<string>.Create();
  try
    // Add .. for each directory to go up
    for LI := LCommonCount to High(LBaseParts) do
      LRelativeParts.Add('..');

    // Add remaining target path parts
    for LI := LCommonCount to High(LTargetParts) do
      LRelativeParts.Add(LTargetParts[LI]);

    Result := string.Join('/', LRelativeParts.ToArray());
  finally
    FreeAndNil(LRelativeParts);
  end;
end;

function TBuild.ValidateAndNormalizeTarget(const ATarget: string): string;
var
  LTrimmed: string;
  LParts: TArray<string>;
  LI: Integer;
  LPart: string;
begin
  LTrimmed := ATarget.Trim().ToLower();

  if (LTrimmed = '') or (LTrimmed = 'native') then
    Exit('native');

  LParts := LTrimmed.Split(['-']);

  if (Length(LParts) < 2) or (Length(LParts) > 3) then
    raise Exception.CreateFmt(
      'Invalid target format: "%s"' + sLineBreak +
      'Expected format: arch-os or arch-os-abi' + sLineBreak +
      'Examples: x86_64-linux, aarch64-macos, wasm32-wasi',
      [ATarget]
    );

  for LI := 0 to High(LParts) do
  begin
    LPart := LParts[LI].Trim();

    if Pos(' ', LPart) > 0 then
    begin
      LPart := LPart.Split([' '])[High(LPart.Split([' ']))];
    end;

    if not IsValidIdentifier(LPart) then
      raise Exception.CreateFmt(
        'Invalid component "%s" in target "%s"' + sLineBreak +
        'Components must be alphanumeric (a-z, 0-9, _)',
        [LPart, ATarget]
      );

    LParts[LI] := LPart;
  end;

  Result := string.Join('-', LParts);
end;

procedure TBuild.Reset();
begin
  FTarget := '';
  FOptimizeMode := omDebug;
  FEnableExceptions := False;
  FStripSymbols := False;
  FAppType := atConsole;

  FModulePaths.Clear();
  FIncludePaths.Clear();
  FSourcePaths.Clear();
  FLibraryPaths.Clear();
  FLinkLibraries.Clear();
  FIncludeHeaders.Clear();
  FSourceFiles.Clear();
end;

procedure TBuild.SetOutputCallback(const ACallback: TOutputCallback; const AUserData: Pointer);
begin
  FOutputCallback.Callback := ACallback;
  FOutputCallback.UserData := AUserData;
end;

function TBuild.GenerateBuildZig(const APreprocessor: TPreprocessor; const ACodeGen: TCodeGen; const AErrors: TErrors): Boolean;
var
  LBuildZigPath: string;
  LBuilder: TStringBuilder;
  LPath: string;
  LLibrary: string;
  LOptimizeMode: string;
  LTargetParts: TArray<string>;
  LArch: string;
  LOS: string;
  LABI: string;
  LFiles: TArray<string>;
  LFile: string;
  //LGeneratedDir: string;
  LLibraryPathsArray: TArray<string>;
  LLibName: string;
  LGeneratedFiles: TArray<string>;
  LSourceFile: string;
  LFileContent: TArray<string>;
  LLine: string;
  LTrimmedLine: string;
  LTemplateTypeFound: Boolean;
  LExeDir: string;
  LExpandedPath: string;
begin
  Result := False;

  if FProjectDir.IsEmpty then
  begin
    AErrors.AddErrorSimple('Project directory not set', []);
    Exit;
  end;

  if FProjectName.IsEmpty then
  begin
    AErrors.AddErrorSimple('Project name not set', []);
    Exit;
  end;

  // Clear previous source files and add generated files from CodeGen
  ClearSourceFiles();
  if Assigned(ACodeGen) then
  begin
    LGeneratedFiles := ACodeGen.GetGeneratedFiles();
    for LFile in LGeneratedFiles do
    begin
      // Only add .cpp files
      if LFile.EndsWith('.cpp', True) then
        AddSourceFile(LFile);
    end;
  end;

  // Check if any C++ source files were added
  if FSourceFiles.Count = 0 then
  begin
    AErrors.AddErrorSimple('No C++ source files to compile', []);
    Exit;
  end;

  // Determine template type by scanning the main source file
  if Assigned(ACodeGen) then
  begin
    // Get the main source file path from CodeGen
    LSourceFile := ACodeGen.GetMainSourceFilePath();

    if not LSourceFile.IsEmpty and TFile.Exists(LSourceFile) then
    begin
      LTemplateTypeFound := False;
      LFileContent := TFile.ReadAllLines(LSourceFile);
      for LLine in LFileContent do
      begin
        LTrimmedLine := LLine.Trim().ToLower();
        if LTrimmedLine.StartsWith('program ') then
        begin
          FTemplateType := tpProgram;
          LTemplateTypeFound := True;
          Break;
        end
        else if LTrimmedLine.StartsWith('library ') then
        begin
          FTemplateType := tpLibrary;
          LTemplateTypeFound := True;
          Break;
        end
        else if LTrimmedLine.StartsWith('unit ') then
        begin
          FTemplateType := tpUnit;
          LTemplateTypeFound := True;
          Break;
        end;
      end;

      if not LTemplateTypeFound then
      begin
        AErrors.AddErrorSimple('Could not determine template type (program, library, or unit) from source file', []);
        Exit;
      end;
    end
    else
    begin
      AErrors.AddErrorSimple('Could not find source file to determine template type', []);
      Exit;
    end;
  end
  else
  begin
    AErrors.AddErrorSimple('CodeGen instance not provided', []);
    Exit;
  end;

  // Get executable directory for relative path expansion
  LExeDir := TPath.GetDirectoryName(ParamStr(0));

  LBuilder := TStringBuilder.Create();
  try
    case FOptimizeMode of
      omDebug:        LOptimizeMode := 'Debug';
      omReleaseSafe:  LOptimizeMode := 'ReleaseSafe';
      omReleaseFast:  LOptimizeMode := 'ReleaseFast';
      omReleaseSmall: LOptimizeMode := 'ReleaseSmall';
    end;

    LLibraryPathsArray := GetLibraryPaths();

    LBuilder.AppendLine('const std = @import("std");');
    LBuilder.AppendLine('');
    LBuilder.AppendLine('pub fn build(b: *std.Build) void {');

    if FTarget.IsEmpty() or (FTarget.ToLower() = 'native') then
    begin
      LBuilder.AppendLine('    const target = b.standardTargetOptions(.{});');
    end
    else
    begin
      LTargetParts := FTarget.Split(['-']);

      LArch := LTargetParts[0];
      LOS := '';
      LABI := '';

      if Length(LTargetParts) >= 2 then
        LOS := LTargetParts[1];
      if Length(LTargetParts) >= 3 then
        LABI := LTargetParts[2];

      LBuilder.AppendLine('    const target = b.resolveTargetQuery(.{');
      LBuilder.AppendLine('        .cpu_arch = .' + LArch + ',');
      if not LOS.IsEmpty then
        LBuilder.AppendLine('        .os_tag = .' + LOS + ',');
      if not LABI.IsEmpty then
        LBuilder.AppendLine('        .abi = .' + LABI + ',');
      LBuilder.AppendLine('    });');
    end;

    LBuilder.AppendLine('    const optimize = .' + LOptimizeMode + ';');
    LBuilder.AppendLine('');

    LBuilder.AppendLine('    // Create module for C++ sources');
    LBuilder.AppendLine('    const module = b.addModule("' + FProjectName + '", .{');
    LBuilder.AppendLine('        .target = target,');
    LBuilder.AppendLine('        .optimize = optimize,');
    LBuilder.AppendLine('        .link_libc = true,');
    LBuilder.AppendLine('    });');
    LBuilder.AppendLine('');

    LBuilder.AppendLine('    // C++ compiler flags');
    LBuilder.AppendLine('    const cpp_flags = [_][]const u8{');
    LBuilder.AppendLine('        "-std=c++23",');
    if not FEnableExceptions then
      LBuilder.AppendLine('        "-fno-exceptions",');
    LBuilder.AppendLine('    };');
    LBuilder.AppendLine('');

    LBuilder.AppendLine('    // Add runtime source');
    for LPath in GetSourcePaths() do
    begin
      // Expand relative paths to absolute before using
      if not TPath.IsPathRooted(LPath) then
        LExpandedPath := TPath.GetFullPath(TPath.Combine(LExeDir, LPath))
      else
        LExpandedPath := LPath;
      
      LBuilder.AppendLine('    module.addCSourceFile(.{');
      LBuilder.AppendLine('        .file = b.path("' + MakeRelativePath(FProjectDir, TPath.Combine(LExpandedPath, 'runtime.cpp')) + '"),');
      LBuilder.AppendLine('        .flags = &cpp_flags,');
      LBuilder.AppendLine('    });');
    end;
    LBuilder.AppendLine('');

    // Add source files from the source files list
    LFiles := GetSourceFiles();
    if Length(LFiles) > 0 then
    begin
      LBuilder.AppendLine('    // Add registered C++ source files');
      for LFile in LFiles do
      begin
        LBuilder.AppendLine('    module.addCSourceFile(.{');
        LBuilder.AppendLine('        .file = b.path("' + MakeRelativePath(FProjectDir, LFile) + '"),');
        LBuilder.AppendLine('        .flags = &cpp_flags,');
        LBuilder.AppendLine('    });');
      end;
      LBuilder.AppendLine('');
    end;

    for LPath in GetIncludePaths() do
    begin
      // Expand relative paths to absolute before using
      if not TPath.IsPathRooted(LPath) then
        LExpandedPath := TPath.GetFullPath(TPath.Combine(LExeDir, LPath))
      else
        LExpandedPath := LPath;
      
      LBuilder.AppendLine('    module.addIncludePath(b.path("' +
        MakeRelativePath(FProjectDir, LExpandedPath) + '"));');
    end;
    if Length(GetIncludePaths()) > 0 then
      LBuilder.AppendLine('');

    case FTemplateType of
      tpProgram:
        begin
          LBuilder.AppendLine('    // Create executable');
          LBuilder.AppendLine('    const exe = b.addExecutable(.{');
          LBuilder.AppendLine('        .name = "' + FProjectName + '",');
          LBuilder.AppendLine('        .root_module = module,');
          LBuilder.AppendLine('    });');

          if FAppType = atGUI then
          begin
            LBuilder.AppendLine('');
            LBuilder.AppendLine('    // Set GUI subsystem (no console window)');
            LBuilder.AppendLine('    if (target.result.os.tag == .windows) {');
            LBuilder.AppendLine('        exe.subsystem = .Windows;');
            LBuilder.AppendLine('    }');
          end;
        end;

      tpLibrary:
        begin
          LBuilder.AppendLine('    // Create shared library');
          LBuilder.AppendLine('    const lib = b.addLibrary(.{');
          LBuilder.AppendLine('        .linkage = .dynamic,');
          LBuilder.AppendLine('        .name = "' + FProjectName + '",');
          LBuilder.AppendLine('        .root_module = module,');
          LBuilder.AppendLine('    });');
        end;

      tpUnit:
        begin
          LBuilder.AppendLine('    // Create static library');
          LBuilder.AppendLine('    const lib = b.addLibrary(.{');
          LBuilder.AppendLine('        .linkage = .static,');
          LBuilder.AppendLine('        .name = "' + FProjectName + '",');
          LBuilder.AppendLine('        .root_module = module,');
          LBuilder.AppendLine('    });');
        end;
    end;
    LBuilder.AppendLine('');

    case FTemplateType of
      tpProgram:
        begin
          LBuilder.AppendLine('    // Link C++ standard library');
          LBuilder.AppendLine('    exe.linkLibCpp();');
        end;
      tpLibrary, tpUnit:
        begin
          LBuilder.AppendLine('    // Link C++ standard library');
          LBuilder.AppendLine('    lib.linkLibCpp();');
        end;
    end;
    LBuilder.AppendLine('');

    case FTemplateType of
      tpProgram:
        begin
          for LPath in LLibraryPathsArray do
          begin
            // Expand relative paths to absolute before using
            if not TPath.IsPathRooted(LPath) then
              LExpandedPath := TPath.GetFullPath(TPath.Combine(LExeDir, LPath))
            else
              LExpandedPath := LPath;
            
            LBuilder.AppendLine('    exe.addLibraryPath(b.path("' +
              MakeRelativePath(FProjectDir, LExpandedPath) + '"));');
          end;
        end;
      tpLibrary, tpUnit:
        begin
          for LPath in LLibraryPathsArray do
          begin
            // Expand relative paths to absolute before using
            if not TPath.IsPathRooted(LPath) then
              LExpandedPath := TPath.GetFullPath(TPath.Combine(LExeDir, LPath))
            else
              LExpandedPath := LPath;
            
            LBuilder.AppendLine('    lib.addLibraryPath(b.path("' +
              MakeRelativePath(FProjectDir, LExpandedPath) + '"));');
          end;
        end;
    end;
    if Length(LLibraryPathsArray) > 0 then
      LBuilder.AppendLine('');

    case FTemplateType of
      tpProgram:
        begin
          (*
          for LLibrary in GetLinkLibraries() do
          begin
            if LLibrary.EndsWith('.lib', True) or LLibrary.EndsWith('.a', True) then
            begin
              LLibName := TPath.GetFileNameWithoutExtension(LLibrary);
              if LLibName.StartsWith('lib', True) then
                LLibName := LLibName.Substring(3);
              LBuilder.AppendLine('    exe.linkSystemLibrary("' + LLibName + '");');
            end
            else
            begin
              LBuilder.AppendLine('    exe.linkSystemLibrary("' + LLibrary + '");');
            end;
          end;
          *)

          for LLibrary in GetLinkLibraries() do
          begin
            if LLibrary.EndsWith('.lib', True) or LLibrary.EndsWith('.a', True) then
            begin
              // Libraries with explicit extensions are object files, not system libraries
              // Find the full path by checking library paths (relative to exe dir)
              LLibName := '';
              for LPath in LLibraryPathsArray do
              begin
                // Library paths are relative to exe directory
                if not TPath.IsPathRooted(LPath) then
                  LExpandedPath := TPath.GetFullPath(TPath.Combine(LExeDir, LPath))
                else
                  LExpandedPath := LPath;

                if TFile.Exists(TPath.Combine(LExpandedPath, LLibrary)) then
                begin
                  LLibName := MakeRelativePath(FProjectDir, TPath.Combine(LExpandedPath, LLibrary));
                  Break;
                end;
              end;

              // If not found in library paths, use as-is (might be relative to project)
              if LLibName.IsEmpty then
                LLibName := LLibrary;

              LBuilder.AppendLine('    exe.addObjectFile(b.path("' + LLibName + '"));');
            end
            else
            begin
              LBuilder.AppendLine('    exe.linkSystemLibrary("' + LLibrary + '");');
            end;
          end;

        end;
      tpLibrary, tpUnit:
        begin
          (*
          for LLibrary in GetLinkLibraries() do
          begin
            if LLibrary.EndsWith('.lib', True) or LLibrary.EndsWith('.a', True) then
            begin
              LLibName := TPath.GetFileNameWithoutExtension(LLibrary);
              if LLibName.StartsWith('lib', True) then
                LLibName := LLibName.Substring(3);
              LBuilder.AppendLine('    lib.linkSystemLibrary("' + LLibName + '");');
            end
            else
            begin
              LBuilder.AppendLine('    lib.linkSystemLibrary("' + LLibrary + '");');
            end;
          end;
          *)

          for LLibrary in GetLinkLibraries() do
          begin
            if LLibrary.EndsWith('.lib', True) or LLibrary.EndsWith('.a', True) then
            begin
              // Libraries with explicit extensions are object files, not system libraries
              // Find the full path by checking library paths (relative to exe dir)
              LLibName := '';
              for LPath in LLibraryPathsArray do
              begin
                // Library paths are relative to exe directory
                if not TPath.IsPathRooted(LPath) then
                  LExpandedPath := TPath.GetFullPath(TPath.Combine(LExeDir, LPath))
                else
                  LExpandedPath := LPath;

                if TFile.Exists(TPath.Combine(LExpandedPath, LLibrary)) then
                begin
                  LLibName := MakeRelativePath(FProjectDir, TPath.Combine(LExpandedPath, LLibrary));
                  Break;
                end;
              end;

              // If not found in library paths, use as-is (might be relative to project)
              if LLibName.IsEmpty then
                LLibName := LLibrary;

              LBuilder.AppendLine('    exe.addObjectFile(b.path("' + LLibName + '"));');
            end
            else
            begin
              LBuilder.AppendLine('    exe.linkSystemLibrary("' + LLibrary + '");');
            end;
          end;

        end;
    end;
    if Length(GetLinkLibraries()) > 0 then
      LBuilder.AppendLine('');

    case FTemplateType of
      tpProgram:
        LBuilder.AppendLine('    b.installArtifact(exe);');
      tpLibrary, tpUnit:
        LBuilder.AppendLine('    b.installArtifact(lib);');
    end;
    LBuilder.AppendLine('}');

    LBuildZigPath := TPath.Combine(FProjectDir, 'build.zig');
    TFile.WriteAllText(LBuildZigPath, LBuilder.ToString());

    Result := True;

  finally
    FreeAndNil(LBuilder);
  end;
end;

function TBuild.ExecuteBuild(const APreprocessor: TPreprocessor; const ACodeGen: TCodeGen; const AErrors: TErrors; var AExitCode: DWORD): Boolean;
var
  LZigExe: string;
  LUnitPaths: TArray<string>;
  LIncludePaths: TArray<string>;
  LLibraryPaths: TArray<string>;
  LLinkLibs: TArray<string>;
  LPath: string;
  LLib: string;
  LOptimizationStr: string;
  LTargetStr: string;
  LAppTypeStr: string;
begin
  Result := False;

  if FProjectDir.IsEmpty then
  begin
    AErrors.AddErrorSimple('Project directory not set', []);
    Exit;
  end;

  // Check preprocessor for build-related defines and apply them
  if Assigned(APreprocessor) then
  begin
    LUnitPaths := APreprocessor.GetUnitPaths();
    for LPath in LUnitPaths do
      AddModulePath(LPath);

    LIncludePaths := APreprocessor.GetIncludePaths();
    for LPath in LIncludePaths do
      AddIncludePath(LPath);

    LLibraryPaths := APreprocessor.GetLibraryPaths();
    for LPath in LLibraryPaths do
      AddLibraryPath(LPath);

    LLinkLibs := APreprocessor.GetLinkLibraries();
    for LLib in LLinkLibs do
      AddLinkLibrary(LLib);

    // Set optimization mode
    LOptimizationStr := APreprocessor.GetOptimization();
    if SameText(LOptimizationStr, 'Debug') then
      SetOptimizeMode(omDebug)
    else if SameText(LOptimizationStr, 'ReleaseSafe') then
      SetOptimizeMode(omReleaseSafe)
    else if SameText(LOptimizationStr, 'ReleaseFast') then
      SetOptimizeMode(omReleaseFast)
    else if SameText(LOptimizationStr, 'ReleaseSmall') then
      SetOptimizeMode(omReleaseSmall);

    // Set target
    LTargetStr := APreprocessor.GetTarget();
    if LTargetStr <> '' then
      SetTarget(LTargetStr);

    // Set app type
    LAppTypeStr := APreprocessor.GetAppType();
    if SameText(LAppTypeStr, 'CONSOLE') then
      SetAppType(atConsole)
    else if SameText(LAppTypeStr, 'GUI') then
      SetAppType(atGUI);
  end;

  if not GenerateBuildZig(APreprocessor, ACodeGen, AErrors) then
    Exit;

  PrintLn('Building with Zig...');

  LZigExe := TUtils.GetZigExePath();
  if not TFile.Exists(LZigExe) then
  begin
    AErrors.AddErrorSimple('Zig executable not found: %s', [LZigExe]);
    Exit;
  end;

  AExitCode := 0;

  TUtils.CaptureZigConsoleOutput(
    'Building ' + FProjectName,
    PChar(LZigExe),
    'build --color off --summary all --prominent-compile-errors',
    FProjectDir,
    AExitCode,
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
        Print(#13 + '  ' + LTrimmed + #27'[K');
      end
      else
      begin
        if LTrimmed.StartsWith('Build Summary:') then
          PrintLn('');
        if LTrimmed.StartsWith('+- ') then
          LTrimmed := LTrimmed.Replace('+- ', '');
        PrintLn('  %s', [LTrimmed]);
      end;
    end
  );

  if AExitCode <> 0 then
  begin
    AErrors.AddErrorSimple('Zig build failed with exit code %d', [AExitCode]);
    Exit;
  end;

  Result := True;
end;

function TBuild.Clean(const AErrors: TErrors): Boolean;
var
  LGeneratedDir: string;
  LZigCacheDir: string;
  LZigOutDir: string;
begin
  Result := False;

  if FProjectDir.IsEmpty then
  begin
    AErrors.AddErrorSimple('Project directory not set', []);
    Exit;
  end;

  PrintLn('Cleaning project...');
  PrintLn('');

  LGeneratedDir := TPath.Combine(FProjectDir, 'generated');
  LZigCacheDir := TPath.Combine(FProjectDir, '.zig-cache');
  LZigOutDir := TPath.Combine(FProjectDir, 'zig-out');

  if TDirectory.Exists(LGeneratedDir) then
  begin
    TDirectory.Delete(LGeneratedDir, True);
    PrintLn('✓ Removed generated/');
  end;

  if TDirectory.Exists(LZigCacheDir) then
  begin
    TDirectory.Delete(LZigCacheDir, True);
    PrintLn('✓ Removed zig-cache/');
  end;

  if TDirectory.Exists(LZigOutDir) then
  begin
    TDirectory.Delete(LZigOutDir, True);
    PrintLn('✓ Removed zig-out/');
  end;

  TDirectory.CreateDirectory(LGeneratedDir);

  Result := True;
end;

function TBuild.Run(const AErrors: TErrors; var AExitCode: DWORD): Boolean;
var
  LExePath: string;
begin
  Result := False;

  if FProjectDir.IsEmpty then
  begin
    AErrors.AddErrorSimple('Project directory not set', []);
    Exit;
  end;

  if FProjectName.IsEmpty then
  begin
    AErrors.AddErrorSimple('Project name not set', []);
    Exit;
  end;

  if FTemplateType <> tpProgram then
  begin
    AErrors.AddWarningSimple('Cannot run library or unit projects. Only programs are executable.', []);
    Exit;
  end;

  if not FTarget.IsEmpty() and (FTarget.ToLower() <> 'native') then
  begin
    if not FTarget.ToLower().StartsWith('x86_64-windows') then
    begin
      AErrors.AddWarningSimple('Skipping run: Target "%s" is not Win64. Only Win64 targets can be executed directly.', [FTarget]);
      Exit;
    end;
  end;

  LExePath := TPath.Combine(FProjectDir, 'zig-out' + PathDelim + 'bin' + PathDelim + FProjectName);

  {$IFDEF MSWINDOWS}
  LExePath := LExePath + '.exe';
  {$ENDIF}

  if not TFile.Exists(LExePath) then
  begin
    AErrors.AddErrorSimple('Executable not found. Did you run build first?', []);
    Exit;
  end;

  PrintLn('Running ' + FProjectName + '...');

  AExitCode := TUtils.RunExe(
    LExePath,
    '',
    FProjectDir,
    True,
    SW_SHOW
  );

  if AExitCode <> 0 then
    PrintLn('Program exited with code: %d', [AExitCode]);

  Result := True;
end;

end.
