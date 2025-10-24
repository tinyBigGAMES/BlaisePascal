{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.CodeGen.Sections;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Consts,
  Blaise.CodeGen;

procedure EmitUnit(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitInterface(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitImplementation(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitUses(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitExports(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);

implementation

procedure EmitUnit(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
begin
  for LChild in ANode.ChildNodes do
    ACodeGen.WalkNode(LChild, AOutput, AIndent);
end;

procedure EmitInterface(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
begin
  ACodeGen.SetInInterfaceSection(True);
  
  for LChild in ANode.ChildNodes do
    ACodeGen.WalkNode(LChild, AOutput, AIndent);
end;

procedure EmitImplementation(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
begin
  ACodeGen.SetInInterfaceSection(False);
  
  for LChild in ANode.ChildNodes do
    ACodeGen.WalkNode(LChild, AOutput, AIndent);
end;

procedure EmitUses(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
  LUnitName: string;
begin
  for LChild in ANode.ChildNodes do
  begin
    if LChild.Typ = ntUnit then
    begin
      LUnitName := ACodeGen.GetNodeName(LChild);
      
      if LUnitName = '' then
        LUnitName := LChild.GetAttribute(anName);
      
      if LUnitName <> '' then
        AOutput.AppendLine('#include "' + LUnitName + '.h"');
    end;
  end;
end;

procedure EmitExports(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
  LName: string;
begin
  for LChild in ANode.ChildNodes do
  begin
    if LChild.Typ = ntElement then
    begin
      LName := ACodeGen.GetNodeName(LChild);
      if LName = '' then
        LName := LChild.GetAttribute(anName);
      
      if LName <> '' then
        ACodeGen.ExportedFunctions().Add(LName);
    end;
  end;
end;

end.
