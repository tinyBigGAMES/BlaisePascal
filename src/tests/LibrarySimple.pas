{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

library LibrarySimple;

type
  TMyTest = record
    Msg: string;
  end;

function LibAdd(A: Integer; B: integer): integer; stdcall;
begin
  Result := A + B;
  writeln('this is a test');
end;

function LibMultiply(A: integer; B: integer): integer; stdcall;
begin
  Result := A * B;
  writeln('this is a test');
end;

procedure Test(const ATest: TMyTest);
begin
  WriteLn(ATest.Msg);
end;

exports
  LibAdd,
  LibMultiply;

begin
  writeln('Lib initializaton');
end.
