{===============================================================================
  NitroPascal - Modern Pascal • C Performance

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://nitropascal.org

  See LICENSE for license information
===============================================================================}

program BPBench_Delphi;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UBPBench in '..\..\bin\projects\BPBench\src\UBPBench.pas';

begin
  try
    RunBench();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
