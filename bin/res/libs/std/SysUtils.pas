{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit SysUtils;

interface

const
  PathDelim = '\';
  DriveDelim = ':';

function ExtractFilePath(const AFileName: String): String;
function ExtractFileDir(const AFileName: String): String;
function ExtractFileName(const AFileName: String): String;
function ExtractFileExt(const AFileName: String): String;
function ExtractFileDrive(const AFileName: String): String;
function ChangeFileExt(const AFileName: String; const AExtension: String): String;
function ExpandFileName(const AFileName: String): String;
function IncludeTrailingPathDelimiter(const APath: String): String;
function ExcludeTrailingPathDelimiter(const APath: String): String;
function IncludeTrailingBackslash(const APath: String): String;
function ExcludeTrailingBackslash(const APath: String): String;
function IsPathDelimiter(const APath: String; const AIndex: Integer): Boolean;
function LastDelimiter(const ADelimiters: String; const AText: String): Integer;
function AnsiLastChar(const AText: String): Char;
function AnsiStrLastChar(const AText: String): String;
function IsDelimiter(const ADelimiters: String; const AText: String; const AIndex: Integer): Boolean;

implementation

function LastDelimiter(const ADelimiters: String; const AText: String): Integer;
var
  LIndex: Integer;
  LDelimIndex: Integer;
begin
  Result := 0;
  for LIndex := Length(AText) downto 1 do
  begin
    for LDelimIndex := 1 to Length(ADelimiters) do
    begin
      if AText[LIndex] = ADelimiters[LDelimIndex] then
      begin
        Result := LIndex;
        Exit;
      end;
    end;
  end;
end;

function ExtractFilePath(const AFileName: String): String;
var
  LPos: Integer;
begin
  LPos := LastDelimiter('\/', AFileName);
  if LPos > 0 then
  begin
    Result := Copy(AFileName, 1, LPos);
  end
  else
  begin
    Result := '';
  end;
end;

function ExtractFileDir(const AFileName: String): String;
var
  LPos: Integer;
begin
  LPos := LastDelimiter('\/', AFileName);
  if LPos > 1 then
  begin
    Result := Copy(AFileName, 1, LPos - 1);
  end
  else
  begin
    Result := '';
  end;
end;

function ExtractFileName(const AFileName: String): String;
var
  LPos: Integer;
begin
  LPos := LastDelimiter('\/', AFileName);
  if LPos > 0 then
  begin
    Result := Copy(AFileName, LPos + 1, Length(AFileName));
  end
  else
  begin
    Result := AFileName;
  end;
end;

function ExtractFileExt(const AFileName: String): String;
var
  LDotPos: Integer;
  LPathPos: Integer;
begin
  LDotPos := 0;
  LPathPos := LastDelimiter('\/', AFileName);
  
  for LDotPos := Length(AFileName) downto 1 do
  begin
    if AFileName[LDotPos] = '.' then
    begin
      if LDotPos > LPathPos then
      begin
        Result := Copy(AFileName, LDotPos, Length(AFileName));
        Exit;
      end;
    end;
  end;
  
  Result := '';
end;

function ExtractFileDrive(const AFileName: String): String;
begin
  if (Length(AFileName) >= 2) and (AFileName[2] = DriveDelim) then
  begin
    Result := Copy(AFileName, 1, 2);
  end
  else
  begin
    Result := '';
  end;
end;

function ChangeFileExt(const AFileName: String; const AExtension: String): String;
var
  LDotPos: Integer;
  LPathPos: Integer;
  LFound: Boolean;
begin
  LFound := False;
  LPathPos := LastDelimiter('\/', AFileName);
  
  for LDotPos := Length(AFileName) downto 1 do
  begin
    if AFileName[LDotPos] = '.' then
    begin
      if LDotPos > LPathPos then
      begin
        Result := Copy(AFileName, 1, LDotPos - 1) + AExtension;
        LFound := True;
        Exit;
      end;
    end;
  end;
  
  if not LFound then
  begin
    Result := AFileName + AExtension;
  end;
end;

function ExpandFileName(const AFileName: String): String;
begin
  Result := AFileName;
end;

function IncludeTrailingPathDelimiter(const APath: String): String;
begin
  Result := APath;
  if (Length(Result) > 0) and (Result[Length(Result)] <> PathDelim) then
  begin
    Result := Result + PathDelim;
  end;
end;

function ExcludeTrailingPathDelimiter(const APath: String): String;
begin
  Result := APath;
  if (Length(Result) > 0) and (Result[Length(Result)] = PathDelim) then
  begin
    SetLength(Result, Length(Result) - 1);
  end;
end;

function IncludeTrailingBackslash(const APath: String): String;
begin
  Result := IncludeTrailingPathDelimiter(APath);
end;

function ExcludeTrailingBackslash(const APath: String): String;
begin
  Result := ExcludeTrailingPathDelimiter(APath);
end;

function IsPathDelimiter(const APath: String; const AIndex: Integer): Boolean;
begin
  Result := (AIndex > 0) and (AIndex <= Length(APath)) and 
            ((APath[AIndex] = PathDelim) or (APath[AIndex] = '/'));
end;

function IsDelimiter(const ADelimiters: String; const AText: String; const AIndex: Integer): Boolean;
var
  LDelimIndex: Integer;
begin
  Result := False;
  if (AIndex < 1) or (AIndex > Length(AText)) then
  begin
    Exit;
  end;
  
  for LDelimIndex := 1 to Length(ADelimiters) do
  begin
    if AText[AIndex] = ADelimiters[LDelimIndex] then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function AnsiLastChar(const AText: String): Char;
begin
  if Length(AText) > 0 then
  begin
    Result := AText[Length(AText)];
  end
  else
  begin
    Result := #0;
  end;
end;

function AnsiStrLastChar(const AText: String): String;
begin
  if Length(AText) > 0 then
  begin
    Result := Copy(AText, Length(AText), 1);
  end
  else
  begin
    Result := '';
  end;
end;

end.
