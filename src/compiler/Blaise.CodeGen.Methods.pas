{===============================================================================
  Blaise Pascal� - Think in Pascal. Compile to C++

  Copyright � 2025-present tinyBigGAMES� LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.CodeGen.Methods;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Consts,
  Blaise.CodeGen;

procedure EmitMethod(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitMethodForwardDeclaration(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitParameters(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIsExternal: Boolean = False);
procedure EmitReturnType(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIsExternal: Boolean = False);

implementation

procedure EmitMethod(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LName: string;
  LKind: string;
  LReturnType: TSyntaxNode;
  LParams: TSyntaxNode;
  LStatements: TSyntaxNode;
  LIsExported: Boolean;
  LInHeader: Boolean;
  LAlreadyDeclaredInHeader: Boolean;
  LIsExternal: Boolean;
begin
  LReturnType := nil;

  LName := ACodeGen.GetNodeName(ANode);
  if LName = '' then
    LName := ANode.GetAttribute(anName);
  
  LKind := ANode.GetAttribute(anKind);
  
  if LName = '' then
    Exit;
  
  LStatements := ANode.FindNode(ntStatements);
  LInHeader := ACodeGen.InInterfaceSection();
  LAlreadyDeclaredInHeader := ACodeGen.EmittedMethodsInHeader().ContainsKey(LName);
  
  // Check if this is an external function
  LIsExternal := ANode.FindNode(ntExternal) <> nil;
  
  // FIX #2: Skip ALL external functions - they must be declared in included headers
  // Whether DLL or static library, external functions should not be declared in our generated files
  // The user is responsible for including the appropriate header via {$INCLUDE_HEADER}
  if LIsExternal then
    Exit;
  
  // FIX #2 & #1B: Skip forward declarations in implementation (.cpp) file
  // Forward declarations should only appear in header (.h) file
  if (not LInHeader) and (not Assigned(LStatements)) then
    Exit; // Skip forward declarations in .cpp
  
  // FIX #1B: Skip declaration-only emission if already in header and we're in .cpp
  // When in .cpp and method was declared in .h, only emit the body (not the declaration)
  if (not LInHeader) and LAlreadyDeclaredInHeader and (not Assigned(LStatements)) then
    Exit; // Already declared in header, no body to emit
  
  LIsExported := ACodeGen.IsLibrary() and (ACodeGen.ExportedFunctions().IndexOf(LName) >= 0);
  
  // Emit function signature (for header declarations or implementation bodies)
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  
  if LIsExported and LInHeader then
    AOutput.Append('BP_EXPORT ');
  
  if SameText(LKind, 'function') then
  begin
    LReturnType := ANode.FindNode(ntReturnType);
    if Assigned(LReturnType) then
      EmitReturnType(ACodeGen, LReturnType, AOutput, LIsExternal)
    else
      AOutput.Append('void');
  end
  else
    AOutput.Append('void');
  
  AOutput.Append(' ' + LName);
  
  AOutput.Append('(');
  LParams := ANode.FindNode(ntParameters);
  if Assigned(LParams) then
    EmitParameters(ACodeGen, LParams, AOutput, LIsExternal);
  AOutput.Append(')');
  
  // Decide: declaration with semicolon, or body with braces?
  if LInHeader or not Assigned(LStatements) or LIsExternal then
  begin
    // In header OR forward declaration OR external: emit semicolon
    AOutput.AppendLine(';');
  end
  else
  begin
    // In implementation with body: emit the body
    
    // Set routine context for exit handling
    if SameText(LKind, 'function') and Assigned(LReturnType) then
    begin
      ACodeGen.SetRoutineContext('FUNCTION', ACodeGen.MapType(ACodeGen.GetNodeName(LReturnType.FindNode(ntType))));
    end
    else
    begin
      ACodeGen.SetRoutineContext('PROCEDURE', '');
    end;
    
    // NEW: Set current method node for local variable lookup
    ACodeGen.SetCurrentMethodNode(ANode);
    
    try
      AOutput.AppendLine(' {');
      
      // Emit local variables from var section
      for var LChild in ANode.ChildNodes do
      begin
        if LChild.Typ = ntVariables then
        begin
          ACodeGen.EmitVariables(LChild, AOutput, AIndent + 1);
        end;
      end;
      
      // If this is a function, declare Result variable
      if SameText(LKind, 'function') and Assigned(LReturnType) then
      begin
        AOutput.Append(ACodeGen.GetIndent(AIndent + 1));
        EmitReturnType(ACodeGen, LReturnType, AOutput);
        AOutput.AppendLine(' Result;');
      end;
      
      ACodeGen.EmitStatements(LStatements, AOutput, AIndent + 1);
      
      // Add return statement for functions
      if SameText(LKind, 'function') and Assigned(LReturnType) then
      begin
        AOutput.Append(ACodeGen.GetIndent(AIndent + 1));
        AOutput.AppendLine('return Result;');
      end;
      
      AOutput.Append(ACodeGen.GetIndent(AIndent));
      AOutput.AppendLine('}');
      AOutput.AppendLine();
    finally
      // NEW: Clear current method node
      ACodeGen.ClearCurrentMethodNode();
      ACodeGen.ClearRoutineContext();
    end;
  end;
end;

procedure EmitMethodForwardDeclaration(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LName: string;
  LKind: string;
  LReturnType: TSyntaxNode;
  LParams: TSyntaxNode;
  LIsExternal: Boolean;
begin
  //LReturnType := nil;

  LName := ACodeGen.GetNodeName(ANode);
  if LName = '' then
    LName := ANode.GetAttribute(anName);
  
  LKind := ANode.GetAttribute(anKind);
  
  if LName = '' then
    Exit;
  
  // Check if this is an external function
  LIsExternal := ANode.FindNode(ntExternal) <> nil;
  
  // Skip external functions - they should not be forward declared
  if LIsExternal then
    Exit;
  
  // Emit function signature as forward declaration
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  
  if SameText(LKind, 'function') then
  begin
    LReturnType := ANode.FindNode(ntReturnType);
    if Assigned(LReturnType) then
      EmitReturnType(ACodeGen, LReturnType, AOutput, LIsExternal)
    else
      AOutput.Append('void');
  end
  else
    AOutput.Append('void');
  
  AOutput.Append(' ' + LName);
  
  AOutput.Append('(');
  LParams := ANode.FindNode(ntParameters);
  if Assigned(LParams) then
    EmitParameters(ACodeGen, LParams, AOutput, LIsExternal);
  AOutput.Append(')');
  
  // Forward declaration: emit semicolon
  AOutput.AppendLine(';');
end;

function MapTypeForExternal(const ACodeGen: TCodeGen; const ATypeName: string): string;
begin
  // For external functions, use raw C++ types without bp:: namespace
  if SameText(ATypeName, 'Integer') then
    Result := 'int'
  else if SameText(ATypeName, 'Cardinal') then
    Result := 'unsigned int'
  else if SameText(ATypeName, 'PChar') then
    Result := 'const wchar_t*'
  else if SameText(ATypeName, 'PAnsiChar') then
    Result := 'const char*'
  else if SameText(ATypeName, 'PInteger') then
    Result := 'int*'
  else if SameText(ATypeName, 'PByte') then
    Result := 'unsigned char*'
  else if SameText(ATypeName, 'Boolean') then
    Result := 'bool'
  else if SameText(ATypeName, 'String') then
    Result := 'const wchar_t*'
  else if SameText(ATypeName, 'Byte') then
    Result := 'unsigned char'
  else if SameText(ATypeName, 'Word') then
    Result := 'unsigned short'
  else if SameText(ATypeName, 'Int64') then
    Result := 'long long'
  else if SameText(ATypeName, 'Single') then
    Result := 'float'
  else if SameText(ATypeName, 'Double') then
    Result := 'double'
  else if SameText(ATypeName, 'Pointer') then
    Result := 'void*'
  else
    Result := ATypeName; // Use as-is for unknown types
end;

procedure EmitParameters(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIsExternal: Boolean = False);
var
  LChild: TSyntaxNode;
  LFirst: Boolean;
  LName: string;
  LType: TSyntaxNode;
  LTypeName: string;
  LModifier: string;
  LMappedType: string;
begin
  LFirst := True;
  
  for LChild in ANode.ChildNodes do
  begin
    if LChild.Typ = ntParameter then
    begin
      if not LFirst then
        AOutput.Append(', ');
      LFirst := False;
      
      LName := ACodeGen.GetNodeName(LChild);
      
      LType := LChild.FindNode(ntType);
      
      LModifier := LChild.GetAttribute(anKind);
      
      if Assigned(LType) then
      begin
        LTypeName := ACodeGen.GetNodeName(LType);
        if LTypeName = '' then
          LTypeName := LType.GetAttribute(anName);
        
        // Use raw C++ types for external functions, bp:: types for internal
        if AIsExternal then
          LMappedType := MapTypeForExternal(ACodeGen, LTypeName)
        else
          LMappedType := ACodeGen.MapType(LTypeName);
        
        if SameText(LModifier, 'var') or SameText(LModifier, 'out') then
        begin
          AOutput.Append(LMappedType + '& ');
        end
        else if SameText(LModifier, 'const') then
        begin
          // FIX #1: Check if type already contains 'const' to avoid duplication
          if LMappedType.StartsWith('const ') then
            AOutput.Append(LMappedType + ' ')
          else
            AOutput.Append('const ' + LMappedType + ' ');
        end
        else
        begin
          // By-value parameter: no const modifier (allows modification of local copy)
          AOutput.Append(LMappedType + ' ');
        end;
        
        AOutput.Append(ACodeGen.ResolveIdentifierName(LName));
      end;
    end;
  end;
end;

procedure EmitReturnType(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIsExternal: Boolean = False);
var
  LTypeName: string;
  LTypeNode: TSyntaxNode;
begin
  LTypeNode := ANode.FindNode(ntType);
  if Assigned(LTypeNode) then
  begin
    LTypeName := ACodeGen.GetNodeName(LTypeNode);
    if LTypeName = '' then
      LTypeName := LTypeNode.GetAttribute(anName);
  end
  else
  begin
    LTypeName := ACodeGen.GetNodeName(ANode);
    if LTypeName = '' then
      LTypeName := ANode.GetAttribute(anName);
  end;
  
  if LTypeName <> '' then
  begin
    // Use raw C++ types for external functions, bp:: types for internal
    if AIsExternal then
      AOutput.Append(MapTypeForExternal(ACodeGen, LTypeName))
    else
      AOutput.Append(ACodeGen.MapType(LTypeName));
  end
  else
    AOutput.Append('void');
end;

end.
