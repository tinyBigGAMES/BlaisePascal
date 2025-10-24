{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.CodeGen.Variables;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Consts,
  Blaise.CodeGen,
  Blaise.CodeGen.Types;

procedure EmitVariables(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitVariable(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitConstants(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitConstant(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);

implementation

procedure EmitVariables(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
begin
  for LChild in ANode.ChildNodes do
    ACodeGen.WalkNode(LChild, AOutput, AIndent);
end;

procedure EmitVariable(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LName: string;
  LTypeNode: TSyntaxNode;
  LTypeName: string;
  LIsPointer: Boolean;
  LIsArray: Boolean;
  LIsSet: Boolean;
  LIsStaticArray: Boolean;
  LPointeeType: TSyntaxNode;
  LElementType: TSyntaxNode;
  LElementTypeName: string;
  LBoundsNode: TSyntaxNode;
begin
  LName := ACodeGen.GetNodeName(ANode);
  
  LTypeNode := ANode.FindNode(ntType);
  
  if not Assigned(LTypeNode) or (LName = '') then
    Exit;
  
  // Check if this is a pointer type
  LIsPointer := SameText(LTypeNode.GetAttribute(anType), 'pointer');
  
  // Check if this is an array type (dynamic array uses anType="array")
  LIsArray := SameText(LTypeNode.GetAttribute(anType), 'array');
  
  // Check if this is a set type
  LIsSet := SameText(LTypeNode.GetAttribute(anType), 'set');
  
  // Check if array has bounds (static array)
  LIsStaticArray := False;
  if LIsArray then
  begin
    LBoundsNode := LTypeNode.FindNode(ntBounds);
    LIsStaticArray := Assigned(LBoundsNode) and LBoundsNode.HasChildren;
  end;
  
  if LIsPointer then
  begin
    // Get the pointee type (child TYPE node)
    LPointeeType := LTypeNode.FindNode(ntType);
    if Assigned(LPointeeType) then
    begin
      LTypeName := ACodeGen.GetNodeName(LPointeeType);
      if LTypeName = '' then
        LTypeName := LPointeeType.GetAttribute(anName);
    end
    else
      LTypeName := 'void';
  end
  else if LIsStaticArray then
  begin
    // Static array - will be emitted via EmitType
    LTypeName := ''; // Will be handled specially below
  end
  else if LIsArray then
  begin
    // Dynamic array - find element type
    LElementType := LTypeNode.FindNode(ntType);
    if Assigned(LElementType) then
    begin
      LElementTypeName := ACodeGen.GetNodeName(LElementType);
      if LElementTypeName = '' then
        LElementTypeName := LElementType.GetAttribute(anName);
      LTypeName := 'Array<' + ACodeGen.MapType(LElementTypeName) + '>';
    end
    else
      LTypeName := 'Array<int>';
  end
  else if LIsSet then
  begin
    // Set type - will be emitted directly via EmitType
    LTypeName := ''; // Will be handled specially below
  end
  else
  begin
    LTypeName := ACodeGen.GetNodeName(LTypeNode);
    if LTypeName = '' then
      LTypeName := LTypeNode.GetAttribute(anName);
    if LTypeName = '' then
      LTypeName := LTypeNode.GetAttribute(anType);
  end;
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  
  // In interface section (header), use extern for declarations
  if ACodeGen.InInterfaceSection() then
    AOutput.Append('extern ');
  
  // For sets and static arrays, emit the type directly using EmitType
  if LIsSet or LIsStaticArray then
  begin
    Blaise.CodeGen.Types.EmitType(ACodeGen, LTypeNode, AOutput, AIndent);
  end
  // For dynamic arrays, we already include bp:: in the Array<T> construction
  else if LIsArray then
    AOutput.Append('bp::' + LTypeName)
  else
    AOutput.Append(ACodeGen.MapType(LTypeName));
  
  if LIsPointer then
    AOutput.Append('*');
  
  AOutput.Append(' ' + ACodeGen.ResolveIdentifierName(LName));
  AOutput.AppendLine(';');
end;

procedure EmitConstants(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
begin
  for LChild in ANode.ChildNodes do
    ACodeGen.WalkNode(LChild, AOutput, AIndent);
end;

procedure EmitConstant(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LName: string;
  LValue: TSyntaxNode;
  LType: TSyntaxNode;
  LIsTypedConstant: Boolean;
  LIsStaticArray: Boolean;
  
  function IsStaticArrayType(const ATypeNode: TSyntaxNode): Boolean;
  var
    LTypeAttr: string;
    LBoundsNode: TSyntaxNode;
  begin
    Result := False;
    if not Assigned(ATypeNode) then
      Exit;
    
    LTypeAttr := ATypeNode.GetAttribute(anType);
    if SameText(LTypeAttr, 'array') then
    begin
      LBoundsNode := ATypeNode.FindNode(ntBounds);
      Result := Assigned(LBoundsNode) and LBoundsNode.HasChildren;
    end;
  end;
  
  procedure EmitInitializer(const AValueNode: TSyntaxNode; const AUseDoubleBraces: Boolean);
  var
    LChild: TSyntaxNode;
    LFirst: Boolean;
    LGrandChild: TSyntaxNode;
    //LExpressionsNode: TSyntaxNode;
  begin
    // For typed constants, emit C++ aggregate initialization syntax
    // StaticArray requires double braces because it inherits from std::array
    if AUseDoubleBraces then
      AOutput.Append('{{')
    else
      AOutput.Append('{');
    
    LFirst := True;
    
    // Walk through all children of the value node
    if Assigned(AValueNode) and AValueNode.HasChildren then
    begin
      for LChild in AValueNode.ChildNodes do
      begin
        // Check if this child is an EXPRESSIONS node (array initializer list)
        if LChild.Typ = ntExpressions then
        begin
          // Process each EXPRESSION within EXPRESSIONS
          for LGrandChild in LChild.ChildNodes do
          begin
            if not LFirst then
              AOutput.Append(', ');
            LFirst := False;
            
            // Emit the expression value
            ACodeGen.EmitExpression(LGrandChild, AOutput);
          end;
        end
        // Check if this child is an EXPRESSION node with children (nested structure)
        // This handles cases like: (X: 0; Y: 0)
        else if (LChild.Typ = ntExpression) and LChild.HasChildren then
        begin
          // Recursively process each element in the expression
          for LGrandChild in LChild.ChildNodes do
          begin
            if not LFirst then
              AOutput.Append(', ');
            LFirst := False;
            
            // Emit the value
            ACodeGen.EmitExpression(LGrandChild, AOutput);
          end;
        end
        else
        begin
          // Direct child - emit it
          if not LFirst then
            AOutput.Append(', ');
          LFirst := False;
          
          ACodeGen.EmitExpression(LChild, AOutput);
        end;
      end;
    end;
    
    if AUseDoubleBraces then
      AOutput.Append('}}')
    else
      AOutput.Append('}');
  end;
  
begin
  LName := ACodeGen.GetNodeName(ANode);
  LValue := ANode.FindNode(ntValue);
  LType := ANode.FindNode(ntType);
  
  if LName = '' then
    Exit;
  
  // Determine if this is a typed constant (has explicit type)
  LIsTypedConstant := Assigned(LType);
  
  // Check if this is a static array type (requires double braces)
  LIsStaticArray := IsStaticArrayType(LType);
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  
  if LIsTypedConstant then
  begin
    // Typed constant: emit explicit type
    AOutput.Append('const ');
    Blaise.CodeGen.Types.EmitType(ACodeGen, LType, AOutput, AIndent);
    AOutput.Append(' ' + ACodeGen.ResolveIdentifierName(LName) + ' = ');
    
    if Assigned(LValue) then
      EmitInitializer(LValue, LIsStaticArray)
    else
      AOutput.Append('{}');
  end
  else
  begin
    // Simple constant: use auto
    AOutput.Append('const auto ' + ACodeGen.ResolveIdentifierName(LName) + ' = ');
    
    if Assigned(LValue) then
      ACodeGen.EmitExpression(LValue, AOutput)
    else
      AOutput.Append('0');
  end;
  
  AOutput.AppendLine(';');
end;

end.
