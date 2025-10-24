{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit UnitSimple;

interface

function Add(const A: Integer; const B: Integer): Integer;
function Multiply(const A: Integer; const B: Integer): Integer;

implementation

function Add(const A: Integer; const B: Integer): Integer;
begin
  Result := A + B;
end;

function Multiply(const A: Integer; const B: Integer): Integer;
begin
  Result := A * B;
end;

end.
