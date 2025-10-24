{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}
unit StrUtils;

interface

function ReverseString(const AText: String): String;
function LeftStr(const AText: String; const ACount: Integer): String;
function RightStr(const AText: String; const ACount: Integer): String;
function MidStr(const AText: String; const AStart: Integer; const ACount: Integer): String;
function LeftBStr(const AText: String; const AByteCount: Integer): String;
function RightBStr(const AText: String; const AByteCount: Integer): String;
function ContainsStr(const AText: String; const ASubText: String): Boolean;
function StartsStr(const ASubText: String; const AText: String): Boolean;
function EndsStr(const ASubText: String; const AText: String): Boolean;
function ContainsText(const AText: String; const ASubText: String): Boolean;
function StartsText(const ASubText: String; const AText: String): Boolean;
function EndsText(const ASubText: String; const AText: String): Boolean;
function DupeString(const AText: String; const ACount: Integer): String;
function StuffString(const AText: String; const AStart: Integer; const ALength: Integer; const ASubText: String): String;
function ReplaceStr(const AText: String; const AFromText: String; const AToText: String): String;
function ReplaceText(const AText: String; const AFromText: String; const AToText: String): String;
function PadLeft(const AText: String; const AWidth: Integer): String;
function PadRight(const AText: String; const AWidth: Integer): String;

implementation

function ReverseString(const AText: String): String;
var
  LIndex: Integer;
  LLength: Integer;
  LTemp: String;
begin
  LLength := Length(AText);
  LTemp := '';
  for LIndex := LLength downto 1 do
  begin
    LTemp := LTemp + Copy(AText, LIndex, 1);
  end;
  Result := LTemp;
end;

function LeftStr(const AText: String; const ACount: Integer): String;
begin
  if ACount <= 0 then
  begin
    Result := '';
  end
  else if ACount >= Length(AText) then
  begin
    Result := AText;
  end
  else
  begin
    Result := Copy(AText, 1, ACount);
  end;
end;

function RightStr(const AText: String; const ACount: Integer): String;
var
  LLength: Integer;
begin
  LLength := Length(AText);
  if ACount <= 0 then
  begin
    Result := '';
  end
  else if ACount >= LLength then
  begin
    Result := AText;
  end
  else
  begin
    Result := Copy(AText, LLength - ACount + 1, ACount);
  end;
end;

function MidStr(const AText: String; const AStart: Integer; const ACount: Integer): String;
begin
  Result := Copy(AText, AStart, ACount);
end;

function LeftBStr(const AText: String; const AByteCount: Integer): String;
begin
  Result := LeftStr(AText, AByteCount);
end;

function RightBStr(const AText: String; const AByteCount: Integer): String;
begin
  Result := RightStr(AText, AByteCount);
end;

function ContainsStr(const AText: String; const ASubText: String): Boolean;
begin
  Result := Pos(ASubText, AText) > 0;
end;

function StartsStr(const ASubText: String; const AText: String): Boolean;
var
  LSubLen: Integer;
begin
  LSubLen := Length(ASubText);
  if LSubLen = 0 then
  begin
    Result := True;
  end
  else if LSubLen > Length(AText) then
  begin
    Result := False;
  end
  else
  begin
    Result := Copy(AText, 1, LSubLen) = ASubText;
  end;
end;

function EndsStr(const ASubText: String; const AText: String): Boolean;
var
  LSubLen: Integer;
  LTextLen: Integer;
begin
  LSubLen := Length(ASubText);
  LTextLen := Length(AText);
  if LSubLen = 0 then
  begin
    Result := True;
  end
  else if LSubLen > LTextLen then
  begin
    Result := False;
  end
  else
  begin
    Result := Copy(AText, LTextLen - LSubLen + 1, LSubLen) = ASubText;
  end;
end;

function ContainsText(const AText: String; const ASubText: String): Boolean;
begin
  Result := Pos(UpperCase(ASubText), UpperCase(AText)) > 0;
end;

function StartsText(const ASubText: String; const AText: String): Boolean;
begin
  Result := StartsStr(UpperCase(ASubText), UpperCase(AText));
end;

function EndsText(const ASubText: String; const AText: String): Boolean;
begin
  Result := EndsStr(UpperCase(ASubText), UpperCase(AText));
end;

function DupeString(const AText: String; const ACount: Integer): String;
var
  LIndex: Integer;
begin
  Result := '';
  if ACount > 0 then
  begin
    for LIndex := 1 to ACount do
    begin
      Result := Result + AText;
    end;
  end;
end;

function StuffString(const AText: String; const AStart: Integer; const ALength: Integer; const ASubText: String): String;
var
  LLeft: String;
  LRight: String;
begin
  LLeft := Copy(AText, 1, AStart - 1);
  LRight := Copy(AText, AStart + ALength, Length(AText));
  Result := LLeft + ASubText + LRight;
end;

function ReplaceStr(const AText: String; const AFromText: String; const AToText: String): String;
begin
  Result := StringReplace(AText, AFromText, AToText);
end;

function ReplaceText(const AText: String; const AFromText: String; const AToText: String): String;
begin
  Result := StringReplace(UpperCase(AText), UpperCase(AFromText), AToText);
end;

function PadLeft(const AText: String; const AWidth: Integer): String;
var
  LSpaces: Integer;
begin
  LSpaces := AWidth - Length(AText);
  if LSpaces > 0 then
  begin
    Result := StringOfChar(' ', LSpaces) + AText;
  end
  else
  begin
    Result := AText;
  end;
end;

function PadRight(const AText: String; const AWidth: Integer): String;
var
  LSpaces: Integer;
begin
  LSpaces := AWidth - Length(AText);
  if LSpaces > 0 then
  begin
    Result := AText + StringOfChar(' ', LSpaces);
  end
  else
  begin
    Result := AText;
  end;
end;

end.
