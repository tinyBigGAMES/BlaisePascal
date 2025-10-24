program BPTester;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UTester in 'UTester.pas',
  Blaise.Build in '..\compiler\Blaise.Build.pas',
  Blaise.CodeGen.Expressions in '..\compiler\Blaise.CodeGen.Expressions.pas',
  Blaise.CodeGen.Generate in '..\compiler\Blaise.CodeGen.Generate.pas',
  Blaise.CodeGen.Methods in '..\compiler\Blaise.CodeGen.Methods.pas',
  Blaise.CodeGen in '..\compiler\Blaise.CodeGen.pas',
  Blaise.CodeGen.Sections in '..\compiler\Blaise.CodeGen.Sections.pas',
  Blaise.CodeGen.Setup in '..\compiler\Blaise.CodeGen.Setup.pas',
  Blaise.CodeGen.Statements in '..\compiler\Blaise.CodeGen.Statements.pas',
  Blaise.CodeGen.Types in '..\compiler\Blaise.CodeGen.Types.pas',
  Blaise.CodeGen.Variables in '..\compiler\Blaise.CodeGen.Variables.pas',
  Blaise.Errors in '..\compiler\Blaise.Errors.pas',
  Blaise.Preprocessing in '..\compiler\Blaise.Preprocessing.pas',
  Blaise.Utils in '..\compiler\Blaise.Utils.pas',
  Blaise.Tester in '..\compiler\Blaise.Tester.pas',
  Blaise.Compiler in '..\compiler\Blaise.Compiler.pas';

begin
  try
    RunTests();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
