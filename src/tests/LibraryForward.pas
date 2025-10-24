{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

library LibraryForward;

function Add(A, B: Integer): Integer; forward;
function Multiply(A, B: Integer): Integer; forward;

function Add(A, B: Integer): Integer;
begin
  Result := A + B;
end;

function Multiply(A, B: Integer): Integer;
begin
  Result := A * B;
end;

exports
  Add,
  Multiply;

end.