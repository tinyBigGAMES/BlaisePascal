{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.CodeGen.Types;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Consts,
  Blaise.CodeGen;

procedure EmitTypeSection(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitTypeDecl(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitType(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);

implementation

uses
  Blaise.CodeGen.Methods;

function MapCallingConvention(const AConvention: string): string;
begin
  // Map Pascal calling conventions to C++ calling convention specifiers
  if SameText(AConvention, 'cdecl') then
    Result := '' // cdecl is default in C, can be explicit with '__cdecl '
  else if SameText(AConvention, 'stdcall') then
    Result := '__stdcall '
  else if SameText(AConvention, 'pascal') then
    Result := '__pascal '
  else if SameText(AConvention, 'safecall') then
    Result := '__stdcall ' // COM uses stdcall
  else if SameText(AConvention, 'register') then
    Result := '' // register cannot be used in function pointers, treat as default
  else
    Result := ''; // Unknown or no convention, use default
end;

procedure EmitTypeSection(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
  LTypeNode: TSyntaxNode;
  LTypeName: string;
  LKind: string;
  LTypeAttr: string;
  LForwardDecls: TStringList;
  LEarlyPointerTypedefs: TStringList;
  LRecordPointerTypedefs: TStringList;
  LAliasPointerTypedefs: TStringList;
  //LDecl: TSyntaxNode;
  LPointerTypeNode: TSyntaxNode;
  LRecordTypes: TStringList;
  LAliasTypes: TStringList;
begin
  // First pass: collect struct/record names and type aliases
  LForwardDecls := TStringList.Create;
  LEarlyPointerTypedefs := TStringList.Create;
  LRecordPointerTypedefs := TStringList.Create;
  LAliasPointerTypedefs := TStringList.Create;
  LRecordTypes := TStringList.Create;
  LAliasTypes := TStringList.Create;
  try
    // Collect all records and type aliases
    for LChild in ANode.ChildNodes do
    begin
      if LChild.Typ = ntTypeDecl then
      begin
        LTypeName := ACodeGen.GetNodeName(LChild);
        if LTypeName = '' then
          LTypeName := LChild.GetAttribute(anName);
        
        LTypeNode := LChild.FindNode(ntType);
        if Assigned(LTypeNode) then
        begin
          LKind := LTypeNode.GetAttribute(anKind);
          LTypeAttr := LTypeNode.GetAttribute(anType);
          
          // Check if this is a record type
          if SameText(LKind, 'record') or SameText(LTypeAttr, 'record') then
          begin
            if LTypeName <> '' then
            begin
              LForwardDecls.Add(LTypeName);
              LRecordTypes.Add(LTypeName);
            end;
          end
          // Check if this is a non-pointer, non-record type alias
          else if not SameText(LTypeAttr, 'pointer') then
          begin
            if LTypeName <> '' then
              LAliasTypes.Add(LTypeName);
          end;
        end;
      end;
    end;
    
    // Second, collect and categorize pointer typedefs into three categories
    for LChild in ANode.ChildNodes do
    begin
      if LChild.Typ = ntTypeDecl then
      begin
        LTypeName := ACodeGen.GetNodeName(LChild);
        if LTypeName = '' then
          LTypeName := LChild.GetAttribute(anName);
        
        LTypeNode := LChild.FindNode(ntType);
        if Assigned(LTypeNode) then
        begin
          LTypeAttr := LTypeNode.GetAttribute(anType);
          
          // Check if this is a pointer typedef
          if SameText(LTypeAttr, 'pointer') then
          begin
            // Get the pointed-to type
            LPointerTypeNode := LTypeNode.FindNode(ntType);
            if Assigned(LPointerTypeNode) then
            begin
              var LPointedType := ACodeGen.GetNodeName(LPointerTypeNode);
              if LPointedType = '' then
                LPointedType := LPointerTypeNode.GetAttribute(anName);
              
              if (LTypeName <> '') and (LPointedType <> '') then
              begin
                var LTypedefStr := 'typedef ' + LPointedType + '* ' + LTypeName + ';';
                
                // Categorize based on pointed-to type
                if LRecordTypes.IndexOf(LPointedType) >= 0 then
                  // Points to a record - emit AFTER forward decls, BEFORE record bodies
                  LRecordPointerTypedefs.Add(LTypedefStr)
                else if LAliasTypes.IndexOf(LPointedType) >= 0 then
                  // Points to a type alias - emit AFTER alias definitions
                  LAliasPointerTypedefs.Add(LTypedefStr)
                else
                  // Points to built-in type - emit early
                  LEarlyPointerTypedefs.Add('typedef ' + ACodeGen.MapType(LPointedType) + '* ' + LTypeName + ';');
              end;
            end;
          end;
        end;
      end;
    end;
    
    // Emit forward declarations for all struct types
    if LForwardDecls.Count > 0 then
    begin
      for LTypeName in LForwardDecls do
      begin
        AOutput.Append(ACodeGen.GetIndent(AIndent));
        AOutput.AppendLine('struct ' + LTypeName + ';');
      end;
      AOutput.AppendLine();
    end;
    
    // Emit pointer typedefs that point to records (after forward decls, before bodies)
    if LRecordPointerTypedefs.Count > 0 then
    begin
      for var LTypedefStr in LRecordPointerTypedefs do
      begin
        AOutput.Append(ACodeGen.GetIndent(AIndent));
        AOutput.AppendLine(LTypedefStr);
      end;
      AOutput.AppendLine();
    end;
    
    // Emit pointer typedefs that point to built-in types
    if LEarlyPointerTypedefs.Count > 0 then
    begin
      for var LTypedefStr in LEarlyPointerTypedefs do
      begin
        AOutput.Append(ACodeGen.GetIndent(AIndent));
        AOutput.AppendLine(LTypedefStr);
      end;
      AOutput.AppendLine();
    end;
  finally
    LForwardDecls.Free;
    LEarlyPointerTypedefs.Free;
    LRecordPointerTypedefs.Free;
  end;
  
  // Second pass: emit all NON-POINTER type declarations (records and aliases)
  for LChild in ANode.ChildNodes do
  begin
    if LChild.Typ = ntTypeDecl then
    begin
      LTypeNode := LChild.FindNode(ntType);
      if Assigned(LTypeNode) then
      begin
        LTypeAttr := LTypeNode.GetAttribute(anType);
        // Skip pointer typedefs - they were emitted earlier or will be emitted later
        if not SameText(LTypeAttr, 'pointer') then
          ACodeGen.WalkNode(LChild, AOutput, AIndent);
      end;
    end
    else
      ACodeGen.WalkNode(LChild, AOutput, AIndent);
  end;
  
  // Third pass: emit pointer typedefs that point to type aliases
  try
    if LAliasPointerTypedefs.Count > 0 then
    begin
      AOutput.AppendLine();
      for var LTypedefStr in LAliasPointerTypedefs do
      begin
        AOutput.Append(ACodeGen.GetIndent(AIndent));
        AOutput.AppendLine(LTypedefStr);
      end;
    end;
  finally
    LAliasPointerTypedefs.Free;
    LRecordTypes.Free;
    LAliasTypes.Free;
  end;
end;

procedure EmitTypeDecl(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LName: string;
  LTypeNode: TSyntaxNode;
  LKind: string;
  LTypeName: string;
  LTypeAttr: string;
  LReturnTypeNode: TSyntaxNode;
  LParamsNode: TSyntaxNode;
  LCallingConvention: string;
begin
  LName := ACodeGen.GetNodeName(ANode);
  
  // Fallback to attribute if no NAME child node
  if LName = '' then
    LName := ANode.GetAttribute(anName);
  
  LTypeNode := ANode.FindNode(ntType);
  
  if not Assigned(LTypeNode) or (LName = '') then
    Exit;
  
  // Check if this is an enum or record type
  LKind := LTypeNode.GetAttribute(anKind);
  LTypeName := LTypeNode.GetAttribute(anName);
  LTypeAttr := LTypeNode.GetAttribute(anType);
  
  // SKIP pointer typedefs - they were already emitted in EmitTypeSection
  if SameText(LTypeAttr, 'pointer') then
    Exit;
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  
  if SameText(LKind, 'record') or SameText(LTypeAttr, 'record') then
  begin
    // For records, emit: struct Name { ... };
    AOutput.Append(ACodeGen.GetIndent(AIndent));
    AOutput.Append('struct ' + LName + ' {');
    
    // Emit record fields
    for var LChild in LTypeNode.ChildNodes do
    begin
      if LChild.Typ = ntField then
      begin
        var LFieldName := ACodeGen.GetNodeName(LChild);
        if LFieldName = '' then
          LFieldName := LChild.GetAttribute(anName);
        
        var LFieldType := LChild.FindNode(ntType);
        if Assigned(LFieldType) then
        begin
          AOutput.AppendLine();
          AOutput.Append('    ');
          EmitType(ACodeGen, LFieldType, AOutput, 0);
          AOutput.Append(' ' + LFieldName + ';');
        end;
      end;
    end;
    
    if LTypeNode.HasChildren then
      AOutput.AppendLine();

    AOutput.AppendLine('};');
  end
  else if SameText(LKind, 'enum') or SameText(LKind, 'enumeration') or 
     SameText(LTypeName, 'enum') or SameText(LTypeName, 'enumeration') then
  begin
    // For enums, emit: typedef enum { ... } Name;
    AOutput.Append(ACodeGen.GetIndent(AIndent));
    AOutput.Append('typedef ');
    EmitType(ACodeGen, LTypeNode, AOutput, AIndent);
    AOutput.Append(' ' + LName);
    AOutput.AppendLine(';');
  end
  else if SameText(LTypeName, 'procedure') or SameText(LTypeName, 'function') then
  begin
    // Emit C++ function pointer typedef
    // Format: typedef ReturnType (CallingConvention *Name)(params);
    AOutput.Append(ACodeGen.GetIndent(AIndent));
    AOutput.Append('typedef ');
    
    // Return type (void for procedures, actual type for functions)
    if SameText(LKind, 'function') then
    begin
      LReturnTypeNode := LTypeNode.FindNode(ntReturnType);
      if Assigned(LReturnTypeNode) then
      begin
        Blaise.CodeGen.Methods.EmitReturnType(ACodeGen, LReturnTypeNode, AOutput, True);
      end
      else
        AOutput.Append('void');
    end
    else
      AOutput.Append('void');

    AOutput.Append(' (');

    // Calling convention
    LCallingConvention := LTypeNode.GetAttribute(anCallingConvention);
    if LCallingConvention <> '' then
      AOutput.Append(MapCallingConvention(LCallingConvention));

    AOutput.Append('*' + LName + ')(');

    // Parameters - reuse existing EmitParameters from CodeGen.Methods
    LParamsNode := LTypeNode.FindNode(ntParameters);
    if Assigned(LParamsNode) then
      Blaise.CodeGen.Methods.EmitParameters(ACodeGen, LParamsNode, AOutput, True);
    
    AOutput.AppendLine(');');
  end
  else
  begin
    // For other types (NOT pointers - already handled above), emit: typedef Type Name;
    AOutput.Append(ACodeGen.GetIndent(AIndent));
    AOutput.Append('typedef ');
    EmitType(ACodeGen, LTypeNode, AOutput, AIndent);
    AOutput.Append(' ' + LName);
    AOutput.AppendLine(';');
  end;
end;

procedure EmitType(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LTypeName: string;
  LKind: string;
  LTypeAttr: string;
  LBoundsNode: TSyntaxNode;
  LDimensionNode: TSyntaxNode;
  LElementTypeNode: TSyntaxNode;
  LElementTypeName: string;
  LLowExpr: TSyntaxNode;
  LHighExpr: TSyntaxNode;
  LLowVal: Integer;
  LHighVal: Integer;
  LSize: Integer;
  LDimensionCount: Integer;
  LDimSizes: TArray<Integer>;
  LTypeNode: TSyntaxNode;
begin
  LKind := ANode.GetAttribute(anKind);
  LTypeAttr := ANode.GetAttribute(anType);
  LTypeName := ANode.GetAttribute(anName);
  
  if SameText(LKind, 'record') or SameText(LTypeAttr, 'record') then
  begin
    AOutput.Append('struct {');
    
    // Emit record fields
    for var LChild in ANode.ChildNodes do
    begin
      if LChild.Typ = ntField then
      begin
        var LFieldName := ACodeGen.GetNodeName(LChild);
        if LFieldName = '' then
          LFieldName := LChild.GetAttribute(anName);
        
        var LFieldType := LChild.FindNode(ntType);
        if Assigned(LFieldType) then
        begin
          AOutput.AppendLine();
          AOutput.Append('    ');
          EmitType(ACodeGen, LFieldType, AOutput, 0);
          AOutput.Append(' ' + LFieldName + ';');
        end;
      end;
    end;
    
    if ANode.HasChildren then
      AOutput.AppendLine();
    
    AOutput.Append('}');
  end
  else if SameText(LKind, 'enum') or SameText(LKind, 'enumeration') or
          SameText(LTypeName, 'enum') or SameText(LTypeName, 'enumeration') then
  begin
    AOutput.Append('enum {');
    
    var LFirst := True;
    for var LChild in ANode.ChildNodes do
    begin
      if LChild.Typ = ntElement then
      begin
        if not LFirst then
          AOutput.Append(',');
        LFirst := False;
        
        var LEnumName := ACodeGen.GetNodeName(LChild);
        if LEnumName = '' then
          LEnumName := LChild.GetAttribute(anName);
        
        AOutput.AppendLine();
        AOutput.Append('    ' + LEnumName);
        
        var LValue := LChild.FindNode(ntValue);
        if Assigned(LValue) then
        begin
          AOutput.Append(' = ');
          ACodeGen.EmitExpression(LValue, AOutput);
        end;
      end
      else if LChild.Typ = ntIdentifier then
      begin
        // Direct identifier child (alternative enum element format)
        if not LFirst then
          AOutput.Append(',');
        LFirst := False;
        
        var LEnumName := ACodeGen.GetNodeName(LChild);
        if LEnumName = '' then
          LEnumName := LChild.GetAttribute(anName);
        
        AOutput.AppendLine();
        AOutput.Append('    ' + LEnumName);
      end
      else if LChild.Typ = ntExpression then
      begin
        // Expression following an identifier (enum value assignment)
        AOutput.Append(' = ');
        ACodeGen.EmitExpression(LChild, AOutput);
      end;
    end;
    
    if not LFirst then
      AOutput.AppendLine();
    
    AOutput.Append('}');
  end
  else if SameText(LTypeAttr, 'set') then
  begin
    // Set type - extract low and high bounds
    // LLowExpr := nil;
    // LHighExpr := nil;
    // LLowVal := 0;
    //LHighVal := 0;
    
    // Get bounds from child EXPRESSION nodes
    if ANode.HasChildren and (Length(ANode.ChildNodes) >= 2) then
    begin
      LLowExpr := ANode.ChildNodes[0];
      LHighExpr := ANode.ChildNodes[1];
      
      // Extract literal values
      if LLowExpr.HasChildren and (LLowExpr.ChildNodes[0].Typ = ntLiteral) then
        LLowVal := StrToIntDef(ACodeGen.GetNodeValue(LLowExpr.ChildNodes[0]), 0)
      else
        LLowVal := 0;
      
      if LHighExpr.HasChildren and (LHighExpr.ChildNodes[0].Typ = ntLiteral) then
        LHighVal := StrToIntDef(ACodeGen.GetNodeValue(LHighExpr.ChildNodes[0]), 0)
      else
        LHighVal := 0;
      
      AOutput.Append('bp::Set<' + IntToStr(LLowVal) + ', ' + IntToStr(LHighVal) + '>');
    end
    else
      AOutput.Append('bp::Set<0, 255>'); // fallback for unbounded sets
  end
  else if SameText(LTypeAttr, 'pointer') then
  begin
    // Pointer type: ^Type -> Type*
    LTypeNode := ANode.FindNode(ntType);
    if Assigned(LTypeNode) then
    begin
      EmitType(ACodeGen, LTypeNode, AOutput, AIndent);
      AOutput.Append('*');
    end
    else
      AOutput.Append('void*');
  end
  else if SameText(LTypeAttr, 'array') then
  begin
    // Check for bounds - static array vs dynamic array
    LBoundsNode := ANode.FindNode(ntBounds);
    
    if Assigned(LBoundsNode) and LBoundsNode.HasChildren then
    begin
      // Static array with bounds
      LElementTypeNode := ANode.FindNode(ntType);
      if Assigned(LElementTypeNode) then
      begin
        LElementTypeName := ACodeGen.GetNodeName(LElementTypeNode);
        if LElementTypeName = '' then
          LElementTypeName := LElementTypeNode.GetAttribute(anName);
      end
      else
        LElementTypeName := 'Integer';
      
      // Count dimensions
      LDimensionCount := 0;
      SetLength(LDimSizes, 0);
      
      for LDimensionNode in LBoundsNode.ChildNodes do
      begin
        if LDimensionNode.Typ = ntDimension then
        begin
          Inc(LDimensionCount);
          
          // Get low and high bounds
          if LDimensionNode.HasChildren and (Length(LDimensionNode.ChildNodes) >= 2) then
          begin
            LLowExpr := LDimensionNode.ChildNodes[0];
            LHighExpr := LDimensionNode.ChildNodes[1];
            
            // Extract literal values
            if LLowExpr.HasChildren and (LLowExpr.ChildNodes[0].Typ = ntLiteral) then
              LLowVal := StrToIntDef(ACodeGen.GetNodeValue(LLowExpr.ChildNodes[0]), 0)
            else
              LLowVal := 0;
            
            if LHighExpr.HasChildren and (LHighExpr.ChildNodes[0].Typ = ntLiteral) then
              LHighVal := StrToIntDef(ACodeGen.GetNodeValue(LHighExpr.ChildNodes[0]), 0)
            else
              LHighVal := 0;
            
            LSize := LHighVal - LLowVal + 1;
            SetLength(LDimSizes, Length(LDimSizes) + 1);
            LDimSizes[Length(LDimSizes) - 1] := LSize;
          end;
        end;
      end;
      
      // Generate C++ array type
      if LDimensionCount = 1 then
      begin
        // Single dimension: bp::StaticArray<T, N>
        AOutput.Append('bp::StaticArray<' + ACodeGen.MapType(LElementTypeName) + ', ' + IntToStr(LDimSizes[0]) + '>');
      end
      else if LDimensionCount > 1 then
      begin
        // Multi-dimensional: nested bp::StaticArray
        // For array[0..1, 0..2] of Integer (LDimSizes = [2, 3])
        // -> bp::StaticArray<bp::StaticArray<Integer, 3>, 2>
        // Strategy: build from innermost (last dimension) to outermost (first dimension)
        
        var LTypeStr: string;
        LTypeStr := ACodeGen.MapType(LElementTypeName);
        
        // Wrap with each dimension from last to first
        for var I := LDimensionCount - 1 downto 0 do
        begin
          LTypeStr := 'bp::StaticArray<' + LTypeStr + ', ' + IntToStr(LDimSizes[I]) + '>';
        end;
        
        AOutput.Append(LTypeStr);
      end;
    end
    else
    begin
      // Dynamic array - no bounds
      LElementTypeNode := ANode.FindNode(ntType);
      if Assigned(LElementTypeNode) then
      begin
        LElementTypeName := ACodeGen.GetNodeName(LElementTypeNode);
        if LElementTypeName = '' then
          LElementTypeName := LElementTypeNode.GetAttribute(anName);
        AOutput.Append('bp::Array<' + ACodeGen.MapType(LElementTypeName) + '>');
      end
      else
        AOutput.Append('bp::Array<int>');
    end;
  end
  else
  begin
    LTypeName := ACodeGen.GetNodeName(ANode);
    
    if LTypeName = '' then
      LTypeName := ANode.GetAttribute(anName);
    
    if LTypeName <> '' then
      AOutput.Append(ACodeGen.MapType(LTypeName))
    else
      AOutput.Append('int');
  end;
end;

end.
