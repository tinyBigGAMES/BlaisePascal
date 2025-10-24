{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.Preprocessing;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  System.Generics.Defaults;

type
  { TPreprocessor }
  TPreprocessor = class
  strict private
    FIncludeHeaders: TStringList;
    FUnitPaths: TStringList;
    FIncludePaths: TStringList;
    FLibraryPaths: TStringList;
    FLinkLibraries: TStringList;
    FSourceFile: string;
    FExportABI: string;
    FOptimization: string;
    FTarget: string;
    FAppType: string;
    FIsMainFile: Boolean;
    FSupportedDirectives: TDictionary<string, Boolean>;

    procedure InitializeSupportedDirectives();
    procedure ProcessLine(const ALine: string; const ALineNumber: Integer);
    function ExtractDirective(const ALine: string; out ADirectiveName: string; out AValue: string): Boolean;
    function DequoteValue(const AValue: string): string;
    function IsSupportedDirective(const ADirectiveName: string): Boolean;

  public
    constructor Create();
    destructor Destroy(); override;

    procedure ProcessFile(const AFilename: string; const AIsMainFile: Boolean = False);
    procedure Clear();

    function GetIncludeHeaders(): TArray<string>;
    function GetUnitPaths(): TArray<string>;
    function GetIncludePaths(): TArray<string>;
    function GetLibraryPaths(): TArray<string>;
    function GetLinkLibraries(): TArray<string>;
    function GetExportABI(): string;
    function GetOptimization(): string;
    function GetTarget(): string;
    function GetAppType(): string;

    property SourceFile: string read FSourceFile;
  end;

implementation

{ TPreprocessor }

constructor TPreprocessor.Create();
begin
  inherited Create();

  FIncludeHeaders := TStringList.Create();
  FIncludeHeaders.Duplicates := dupIgnore;
  FUnitPaths := TStringList.Create();
  FUnitPaths.Duplicates := dupIgnore;
  FIncludePaths := TStringList.Create();
  FIncludePaths.Duplicates := dupIgnore;
  FLibraryPaths := TStringList.Create();
  FLibraryPaths.Duplicates := dupIgnore;
  FLinkLibraries := TStringList.Create();
  FLinkLibraries.Duplicates := dupIgnore;
  FSourceFile := '';
  FExportABI := 'CPP';
  FOptimization := 'Debug';
  FTarget := 'native';
  FAppType := 'CONSOLE';

  FSupportedDirectives := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal());

  InitializeSupportedDirectives();
end;

destructor TPreprocessor.Destroy();
begin
  FIncludeHeaders.Free();
  FUnitPaths.Free();
  FIncludePaths.Free();
  FLibraryPaths.Free();
  FLinkLibraries.Free();
  FSupportedDirectives.Free();

  inherited Destroy();
end;

procedure TPreprocessor.Clear();
begin
  FIncludeHeaders.Clear();
  FUnitPaths.Clear();
  FIncludePaths.Clear();
  FLibraryPaths.Clear();
  FLinkLibraries.Clear();
  FSourceFile := '';
  FExportABI := 'CPP';
  FOptimization := 'Debug';
  FTarget := 'native';
  FAppType := 'CONSOLE';
end;

procedure TPreprocessor.InitializeSupportedDirectives();
begin
  FSupportedDirectives.Clear();
  
  // Add all supported compiler directives here
  // This makes it easy to add new directives in the future
  FSupportedDirectives.TryAdd('INCLUDE_HEADER', True);
  FSupportedDirectives.TryAdd('EXPORT_ABI', True);
  FSupportedDirectives.TryAdd('UNIT_PATH', True);
  FSupportedDirectives.TryAdd('LIBRARY_PATH', True);
  FSupportedDirectives.TryAdd('INCLUDE_PATH', True);
  FSupportedDirectives.TryAdd('LINK', True);
  FSupportedDirectives.TryAdd('OPTIMIZATION', True);
  FSupportedDirectives.TryAdd('TARGET', True);
  FSupportedDirectives.TryAdd('APPTYPE', True);

  // Future directives can be added here:
  // FSupportedDirectives.TryAdd('DEFINE', True);
end;

function TPreprocessor.IsSupportedDirective(const ADirectiveName: string): Boolean;
begin
  Result := FSupportedDirectives.ContainsKey(ADirectiveName);
end;

function TPreprocessor.DequoteValue(const AValue: string): string;
var
  LTrimmed: string;
  LLen: Integer;
begin
  LTrimmed := AValue.Trim();
  LLen := LTrimmed.Length;
  
  // Check if surrounded by single quotes
  if (LLen >= 2) and (LTrimmed[1] = '''') and (LTrimmed[LLen] = '''') then
    Result := Copy(LTrimmed, 2, LLen - 2)
  // Check if surrounded by double quotes
  else if (LLen >= 2) and (LTrimmed[1] = '"') and (LTrimmed[LLen] = '"') then
    Result := Copy(LTrimmed, 2, LLen - 2)
  // Check if surrounded by angle brackets (for system headers)
  else if (LLen >= 2) and (LTrimmed[1] = '<') and (LTrimmed[LLen] = '>') then
    Result := LTrimmed  // Keep angle brackets for system headers
  else
    Result := LTrimmed;
end;

function TPreprocessor.ExtractDirective(const ALine: string; out ADirectiveName: string; out AValue: string): Boolean;
var
  LTrimmed: string;
  LEnd: Integer;
  LContent: string;
  LSpacePos: Integer;
begin
  Result := False;
  ADirectiveName := '';
  AValue := '';
  
  LTrimmed := ALine.Trim();
  
  // Check for compiler directive pattern: {$...}
  if not LTrimmed.StartsWith('{$') then
    Exit;
  
  LEnd := Pos('}', LTrimmed);
  if LEnd = 0 then
    Exit; // Malformed directive
  
  // Extract content between {$ and }
  LContent := Copy(LTrimmed, 3, LEnd - 3).Trim();
  
  // Split into directive and value at first whitespace
  LSpacePos := Pos(' ', LContent);
  if LSpacePos = 0 then
  begin
    // No space - directive only (like {$R+})
    ADirectiveName := LContent;
    AValue := '';
  end
  else
  begin
    ADirectiveName := Copy(LContent, 1, LSpacePos - 1).Trim();
    // Capture everything from first space to end, without trimming
    // Let DequoteValue() handle trimming and quote stripping
    AValue := Copy(LContent, LSpacePos + 1, Length(LContent) - LSpacePos);
  end;
  
  Result := not ADirectiveName.IsEmpty;
end;

procedure TPreprocessor.ProcessLine(const ALine: string; const ALineNumber: Integer);
var
  LDirectiveName: string;
  LValue: string;
  LHeader: string;
  LDequotedValue: string;
begin
  if not ExtractDirective(ALine, LDirectiveName, LValue) then
    Exit;
  
  // Check if this is a supported directive
  if not IsSupportedDirective(LDirectiveName) then
    Exit;
  
  // Process based on directive type
  if SameText(LDirectiveName, 'INCLUDE_HEADER') then
  begin
    LHeader := DequoteValue(LValue);
    if LHeader <> '' then
    begin
      // Add to list if not already present
      if FIncludeHeaders.IndexOf(LHeader) = -1 then
        FIncludeHeaders.Add(LHeader);
    end;
  end
  else if SameText(LDirectiveName, 'EXPORT_ABI') then
  begin
    // Set export ABI: 'C' or 'CPP'
    LDequotedValue := DequoteValue(LValue);
    if SameText(LDequotedValue, 'C') or SameText(LDequotedValue, 'CPP') then
      FExportABI := UpperCase(LDequotedValue)
    else
      FExportABI := 'CPP'; // Default to CPP for invalid values
  end
  else if SameText(LDirectiveName, 'UNIT_PATH') then
  begin
    LDequotedValue := DequoteValue(LValue);
    if (LDequotedValue <> '') and (FUnitPaths.IndexOf(LDequotedValue) = -1) then
      FUnitPaths.Add(LDequotedValue);
  end
  else if SameText(LDirectiveName, 'INCLUDE_PATH') then
  begin
    LDequotedValue := DequoteValue(LValue);
    if (LDequotedValue <> '') and (FIncludePaths.IndexOf(LDequotedValue) = -1) then
      FIncludePaths.Add(LDequotedValue);
  end
  else if SameText(LDirectiveName, 'LIBRARY_PATH') then
  begin
    LDequotedValue := DequoteValue(LValue);
    if (LDequotedValue <> '') and (FLibraryPaths.IndexOf(LDequotedValue) = -1) then
      FLibraryPaths.Add(LDequotedValue);
  end
  else if SameText(LDirectiveName, 'LINK') then
  begin
    LDequotedValue := DequoteValue(LValue);
    if (LDequotedValue <> '') and (FLinkLibraries.IndexOf(LDequotedValue) = -1) then
      FLinkLibraries.Add(LDequotedValue);
  end
  else if SameText(LDirectiveName, 'OPTIMIZATION') then
  begin
    // Only process build directives from main file
    if FIsMainFile then
    begin
      LDequotedValue := DequoteValue(LValue);
      // Validate: Debug, ReleaseSafe, ReleaseFast, ReleaseSmall
      if SameText(LDequotedValue, 'Debug') or
         SameText(LDequotedValue, 'ReleaseSafe') or
         SameText(LDequotedValue, 'ReleaseFast') or
         SameText(LDequotedValue, 'ReleaseSmall') then
        FOptimization := LDequotedValue
      else
        FOptimization := 'Debug'; // Default for invalid values
    end;
  end
  else if SameText(LDirectiveName, 'TARGET') then
  begin
    // Only process build directives from main file
    if FIsMainFile then
    begin
      LDequotedValue := DequoteValue(LValue);
      // Store as-is, validation will be done by TBuild.ValidateAndNormalizeTarget
      if LDequotedValue <> '' then
        FTarget := LDequotedValue;
    end;
  end
  else if SameText(LDirectiveName, 'APPTYPE') then
  begin
    // Only process build directives from main file
    if FIsMainFile then
    begin
      LDequotedValue := DequoteValue(LValue);
      // Validate: CONSOLE or GUI
      if SameText(LDequotedValue, 'CONSOLE') or SameText(LDequotedValue, 'GUI') then
        FAppType := UpperCase(LDequotedValue)
      else
        FAppType := 'CONSOLE'; // Default for invalid values
    end;
  end;
end;

procedure TPreprocessor.ProcessFile(const AFilename: string; const AIsMainFile: Boolean = False);
var
  LLines: TStringList;
  LI: Integer;
begin
  if not TFile.Exists(AFilename) then
    Exit;

  FSourceFile := AFilename;
  FIsMainFile := AIsMainFile;

  LLines := TStringList.Create();
  try
    LLines.LoadFromFile(AFilename);

    for LI := 0 to LLines.Count - 1 do
    begin
      ProcessLine(LLines[LI], LI + 1);
    end;
  finally
    LLines.Free();
  end;
end;

function TPreprocessor.GetIncludeHeaders(): TArray<string>;
begin
  Result := FIncludeHeaders.ToStringArray();
end;

function TPreprocessor.GetUnitPaths(): TArray<string>;
begin
  Result := FUnitPaths.ToStringArray();
end;

function TPreprocessor.GetIncludePaths(): TArray<string>;
begin
  Result := FIncludePaths.ToStringArray();
end;

function TPreprocessor.GetLibraryPaths(): TArray<string>;
begin
  Result := FLibraryPaths.ToStringArray();
end;

function TPreprocessor.GetLinkLibraries(): TArray<string>;
begin
  Result := FLinkLibraries.ToStringArray();
end;

function TPreprocessor.GetExportABI(): string;
begin
  Result := FExportABI;
end;

function TPreprocessor.GetOptimization(): string;
begin
  Result := FOptimization;
end;

function TPreprocessor.GetTarget(): string;
begin
  Result := FTarget;
end;

function TPreprocessor.GetAppType(): string;
begin
  Result := FAppType;
end;

end.
