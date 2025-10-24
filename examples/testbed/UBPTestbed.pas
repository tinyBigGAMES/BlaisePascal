{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit UBPTestbed;

interface

uses
  System.SysUtils,
  Blaise.Utils,
  Blaise.Compiler;

procedure RunTestbed();

implementation

procedure Test01();
var
  LCompiler: TCompiler;
begin
  LCompiler := TCompiler.Create();
  try
    //LCompiler.Init('test01', 'testbed', tpProgram);
    LCompiler.SetProjectDir('testbed\test01');
    LCompiler.Build(False);
    LCompiler.Run();

  finally
    LCompiler.Free();
  end;
end;

procedure RunTestbed();
begin
  try
    Test01();
  except
    on E: Exception do
    begin
      TUtils.PrintLn(COLOR_RED + 'Error: %s' + COLOR_RESET , [E.Message]);
    end;
  end;

  TUtils.Pause();
end;

end.
