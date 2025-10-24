{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit UnitWithTypes;

interface

type
  TPoint = record
    X: Integer;
    Y: Integer;
  end;
  
  PPoint = ^TPoint;

function CreatePoint(const AX, AY: Integer): TPoint;
procedure ModifyPoint(var APoint: TPoint; const ADelta: Integer);
function DistanceFromOrigin(const APoint: TPoint): Integer;

implementation

function CreatePoint(const AX, AY: Integer): TPoint;
begin
  Result.X := AX;
  Result.Y := AY;
end;

procedure ModifyPoint(var APoint: TPoint; const ADelta: Integer);
begin
  APoint.X := APoint.X + ADelta;
  APoint.Y := APoint.Y + ADelta;
end;

function DistanceFromOrigin(const APoint: TPoint): Integer;
begin
  Result := APoint.X * APoint.X + APoint.Y * APoint.Y;
end;

end.
