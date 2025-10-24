{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Types;

interface

type
  { TPoint }
  TPoint = record
    X: Integer;
    Y: Integer;
  end;

  { TRect }
  TRect = record
    Left: Integer;
    Top: Integer;
    Right: Integer;
    Bottom: Integer;
  end;

  { TSize }
  TSize = record
    CX: Integer;
    CY: Integer;
  end;

function Point(const AX: Integer; const AY: Integer): TPoint;
function Rect(const ALeft: Integer; const ATop: Integer; const ARight: Integer; const ABottom: Integer): TRect;
function Bounds(const ALeft: Integer; const ATop: Integer; const AWidth: Integer; const AHeight: Integer): TRect;
function Size(const ACX: Integer; const ACY: Integer): TSize;
function PtInRect(const ARect: TRect; const APoint: TPoint): Boolean;
function RectWidth(const ARect: TRect): Integer;
function RectHeight(const ARect: TRect): Integer;
function OffsetRect(var ARect: TRect; const ADX: Integer; const ADY: Integer): Boolean;
function InflateRect(var ARect: TRect; const ADX: Integer; const ADY: Integer): Boolean;
function IsRectEmpty(const ARect: TRect): Boolean;
function EqualRect(const ARect1: TRect; const ARect2: TRect): Boolean;

implementation

function Point(const AX: Integer; const AY: Integer): TPoint;
begin
  Result.X := AX;
  Result.Y := AY;
end;

function Rect(const ALeft: Integer; const ATop: Integer; const ARight: Integer; const ABottom: Integer): TRect;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ARight;
  Result.Bottom := ABottom;
end;

function Bounds(const ALeft: Integer; const ATop: Integer; const AWidth: Integer; const AHeight: Integer): TRect;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ALeft + AWidth;
  Result.Bottom := ATop + AHeight;
end;

function Size(const ACX: Integer; const ACY: Integer): TSize;
begin
  Result.CX := ACX;
  Result.CY := ACY;
end;

function PtInRect(const ARect: TRect; const APoint: TPoint): Boolean;
begin
  Result := (APoint.X >= ARect.Left) and (APoint.X < ARect.Right) and
            (APoint.Y >= ARect.Top) and (APoint.Y < ARect.Bottom);
end;

function RectWidth(const ARect: TRect): Integer;
begin
  Result := ARect.Right - ARect.Left;
end;

function RectHeight(const ARect: TRect): Integer;
begin
  Result := ARect.Bottom - ARect.Top;
end;

function OffsetRect(var ARect: TRect; const ADX: Integer; const ADY: Integer): Boolean;
begin
  ARect.Left := ARect.Left + ADX;
  ARect.Top := ARect.Top + ADY;
  ARect.Right := ARect.Right + ADX;
  ARect.Bottom := ARect.Bottom + ADY;
  Result := True;
end;

function InflateRect(var ARect: TRect; const ADX: Integer; const ADY: Integer): Boolean;
begin
  ARect.Left := ARect.Left - ADX;
  ARect.Top := ARect.Top - ADY;
  ARect.Right := ARect.Right + ADX;
  ARect.Bottom := ARect.Bottom + ADY;
  Result := True;
end;

function IsRectEmpty(const ARect: TRect): Boolean;
begin
  Result := (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top);
end;

function EqualRect(const ARect1: TRect; const ARect2: TRect): Boolean;
begin
  Result := (ARect1.Left = ARect2.Left) and (ARect1.Top = ARect2.Top) and
            (ARect1.Right = ARect2.Right) and (ARect1.Bottom = ARect2.Bottom);
end;

end.
