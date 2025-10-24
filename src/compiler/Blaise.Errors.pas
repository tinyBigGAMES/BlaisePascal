{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.Errors;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  Blaise.Utils;

type
  TErrorLevel = (
    elHint,
    elWarning,
    elError,
    elFatal
  );

  { TError }
  TError = record
    Level: TErrorLevel;
    SourceFile: string;
    Line: Integer;
    Column: Integer;
    Message: string;
  end;

  { TErrors }
  TErrors = class
  private
    FErrors: TArray<TError>;
    FWarnings: TArray<TError>;
    FHints: TArray<TError>;
    FHasErrors: Boolean;
    FHasFatal: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Clear();
    
    procedure AddError(const AFile: string; const ALine: Integer; 
      const AColumn: Integer; const AMessage: string; const AArgs: array of const);
    procedure AddWarning(const AFile: string; const ALine: Integer; 
      const AColumn: Integer; const AMessage: string; const AArgs: array of const);
    procedure AddHint(const AFile: string; const ALine: Integer; 
      const AColumn: Integer; const AMessage: string; const AArgs: array of const);
    procedure AddFatal(const AFile: string; const ALine: Integer; 
      const AColumn: Integer; const AMessage: string; const AArgs: array of const);
    
    procedure AddErrorSimple(const AMessage: string; const AArgs: array of const);
    procedure AddWarningSimple(const AMessage: string; const AArgs: array of const);
    procedure AddHintSimple(const AMessage: string; const AArgs: array of const);
    procedure AddFatalSimple(const AMessage: string; const AArgs: array of const);
    
    function HasErrors(): Boolean;
    function HasWarnings(): Boolean;
    function HasHints(): Boolean;
    function HasFatal(): Boolean;
    
    function GetErrorCount(): Integer;
    function GetWarningCount(): Integer;
    function GetHintCount(): Integer;
    
    function GetAllErrors(): TArray<TError>;
    function GetAllWarnings(): TArray<TError>;
    function GetAllHints(): TArray<TError>;
    function GetAll(): TArray<TError>;
    
    procedure PrintToConsole();
    procedure PrintErrors();
    procedure PrintWarnings();
    procedure PrintHints();
  end;

implementation

{ TErrors }

constructor TErrors.Create();
begin
  inherited Create();
  Clear();
end;

destructor TErrors.Destroy();
begin
  Clear();
  inherited Destroy();
end;

procedure TErrors.Clear();
begin
  SetLength(FErrors, 0);
  SetLength(FWarnings, 0);
  SetLength(FHints, 0);
  FHasErrors := False;
  FHasFatal := False;
end;

procedure TErrors.AddError(const AFile: string; const ALine: Integer;
  const AColumn: Integer; const AMessage: string; const AArgs: array of const);
var
  LError: TError;
  LLen: Integer;
  LFormattedMessage: string;
begin
  if Length(AArgs) > 0 then
    LFormattedMessage := Format(AMessage, AArgs)
  else
    LFormattedMessage := AMessage;

  LError.Level := elError;
  LError.SourceFile := AFile;
  LError.Line := ALine;
  LError.Column := AColumn;
  LError.Message := LFormattedMessage;
  
  LLen := Length(FErrors);
  SetLength(FErrors, LLen + 1);
  FErrors[LLen] := LError;
  
  FHasErrors := True;
end;

procedure TErrors.AddWarning(const AFile: string; const ALine: Integer;
  const AColumn: Integer; const AMessage: string; const AArgs: array of const);
var
  LWarning: TError;
  LLen: Integer;
  LFormattedMessage: string;
begin
  if Length(AArgs) > 0 then
    LFormattedMessage := Format(AMessage, AArgs)
  else
    LFormattedMessage := AMessage;

  LWarning.Level := elWarning;
  LWarning.SourceFile := AFile;
  LWarning.Line := ALine;
  LWarning.Column := AColumn;
  LWarning.Message := LFormattedMessage;
  
  LLen := Length(FWarnings);
  SetLength(FWarnings, LLen + 1);
  FWarnings[LLen] := LWarning;
end;

procedure TErrors.AddHint(const AFile: string; const ALine: Integer;
  const AColumn: Integer; const AMessage: string; const AArgs: array of const);
var
  LHint: TError;
  LLen: Integer;
  LFormattedMessage: string;
begin
  if Length(AArgs) > 0 then
    LFormattedMessage := Format(AMessage, AArgs)
  else
    LFormattedMessage := AMessage;

  LHint.Level := elHint;
  LHint.SourceFile := AFile;
  LHint.Line := ALine;
  LHint.Column := AColumn;
  LHint.Message := LFormattedMessage;
  
  LLen := Length(FHints);
  SetLength(FHints, LLen + 1);
  FHints[LLen] := LHint;
end;

procedure TErrors.AddFatal(const AFile: string; const ALine: Integer;
  const AColumn: Integer; const AMessage: string; const AArgs: array of const);
var
  LError: TError;
  LLen: Integer;
  LFormattedMessage: string;
begin
  if Length(AArgs) > 0 then
    LFormattedMessage := Format(AMessage, AArgs)
  else
    LFormattedMessage := AMessage;

  LError.Level := elFatal;
  LError.SourceFile := AFile;
  LError.Line := ALine;
  LError.Column := AColumn;
  LError.Message := LFormattedMessage;
  
  LLen := Length(FErrors);
  SetLength(FErrors, LLen + 1);
  FErrors[LLen] := LError;
  
  FHasErrors := True;
  FHasFatal := True;
end;

procedure TErrors.AddErrorSimple(const AMessage: string; const AArgs: array of const);
begin
  AddError('', 0, 0, AMessage, AArgs);
end;

procedure TErrors.AddWarningSimple(const AMessage: string; const AArgs: array of const);
begin
  AddWarning('', 0, 0, AMessage, AArgs);
end;

procedure TErrors.AddHintSimple(const AMessage: string; const AArgs: array of const);
begin
  AddHint('', 0, 0, AMessage, AArgs);
end;

procedure TErrors.AddFatalSimple(const AMessage: string; const AArgs: array of const);
begin
  AddFatal('', 0, 0, AMessage, AArgs);
end;

function TErrors.HasErrors(): Boolean;
begin
  Result := FHasErrors;
end;

function TErrors.HasWarnings(): Boolean;
begin
  Result := Length(FWarnings) > 0;
end;

function TErrors.HasHints(): Boolean;
begin
  Result := Length(FHints) > 0;
end;

function TErrors.HasFatal(): Boolean;
begin
  Result := FHasFatal;
end;

function TErrors.GetErrorCount(): Integer;
begin
  Result := Length(FErrors);
end;

function TErrors.GetWarningCount(): Integer;
begin
  Result := Length(FWarnings);
end;

function TErrors.GetHintCount(): Integer;
begin
  Result := Length(FHints);
end;

function TErrors.GetAllErrors(): TArray<TError>;
begin
  Result := Copy(FErrors, 0, Length(FErrors));
end;

function TErrors.GetAllWarnings(): TArray<TError>;
begin
  Result := Copy(FWarnings, 0, Length(FWarnings));
end;

function TErrors.GetAllHints(): TArray<TError>;
begin
  Result := Copy(FHints, 0, Length(FHints));
end;

function TErrors.GetAll(): TArray<TError>;
var
  LTotal: Integer;
  LIndex: Integer;
  LError: TError;
begin
  LTotal := Length(FErrors) + Length(FWarnings) + Length(FHints);
  SetLength(Result, LTotal);
  
  LIndex := 0;
  
  for LError in FErrors do
  begin
    Result[LIndex] := LError;
    Inc(LIndex);
  end;
  
  for LError in FWarnings do
  begin
    Result[LIndex] := LError;
    Inc(LIndex);
  end;
  
  for LError in FHints do
  begin
    Result[LIndex] := LError;
    Inc(LIndex);
  end;
end;

procedure TErrors.PrintToConsole();
begin
  PrintErrors();
  PrintWarnings();
  PrintHints();
end;

procedure TErrors.PrintErrors();
var
  LError: TError;
  LLevelStr: string;
begin
  if Length(FErrors) = 0 then
    Exit;
    
  TUtils.Println();
  TUtils.Println('=== Errors ===');
  
  for LError in FErrors do
  begin
    if LError.Level = elFatal then
      LLevelStr := 'FATAL'
    else
      LLevelStr := 'ERROR';
      
    if LError.SourceFile <> '' then
      TUtils.Println(Format('[%s] %s(%d:%d): %s', 
        [LLevelStr, LError.SourceFile, LError.Line, LError.Column, LError.Message]))
    else
      TUtils.Println(Format('[%s] %s', [LLevelStr, LError.Message]));
  end;
end;

procedure TErrors.PrintWarnings();
var
  LWarning: TError;
begin
  if Length(FWarnings) = 0 then
    Exit;
    
  TUtils.Println();
  TUtils.Println('=== Warnings ===');
  
  for LWarning in FWarnings do
  begin
    if LWarning.SourceFile <> '' then
      TUtils.Println(Format('[WARNING] %s(%d:%d): %s', 
        [LWarning.SourceFile, LWarning.Line, LWarning.Column, LWarning.Message]))
    else
      TUtils.Println(Format('[WARNING] %s', [LWarning.Message]));
  end;
end;

procedure TErrors.PrintHints();
var
  LHint: TError;
begin
  if Length(FHints) = 0 then
    Exit;
    
  TUtils.Println();
  TUtils.Println('=== Hints ===');
  
  for LHint in FHints do
  begin
    if LHint.SourceFile <> '' then
      TUtils.Println(Format('[HINT] %s(%d:%d): %s', 
        [LHint.SourceFile, LHint.Line, LHint.Column, LHint.Message]))
    else
      TUtils.Println(Format('[HINT] %s', [LHint.Message]));
  end;
end;

end.
