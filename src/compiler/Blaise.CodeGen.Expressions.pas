{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.CodeGen.Expressions;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Consts,
  Blaise.CodeGen;

procedure EmitExpression(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);
procedure EmitIdentifier(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);
procedure EmitLiteral(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);
procedure EmitBinaryOp(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);
procedure EmitUnaryOp(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);

implementation

uses
  Blaise.CodeGen.Statements;

procedure EmitExpression(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);
var
  LChild: TSyntaxNode;
  LArrayBase: TSyntaxNode;
begin
  if not Assigned(ANode) then
    Exit;

  case ANode.Typ of
    ntIdentifier: EmitIdentifier(ACodeGen, ANode, AOutput);
    ntLiteral: EmitLiteral(ACodeGen, ANode, AOutput);
    ntCall: Blaise.CodeGen.Statements.EmitCall(ACodeGen, ANode, AOutput, 0);
    
    ntIndexed:
    begin
      // Array indexing: array[index] or array[index1][index2] for multi-dimensional
      // Find the array base (identifier) and all index expressions
      LArrayBase := nil;
      
      for LChild in ANode.ChildNodes do
      begin
        if LChild.Typ = ntIdentifier then
        begin
          LArrayBase := LChild;
          Break;
        end;
      end;
      
      if Assigned(LArrayBase) then
        EmitIdentifier(ACodeGen, LArrayBase, AOutput);
      
      // Emit each index expression as a separate [index]
      for LChild in ANode.ChildNodes do
      begin
        if LChild.Typ = ntExpression then
        begin
          AOutput.Append('[');
          // Emit the index expression's children
          for var LExprChild in LChild.ChildNodes do
            EmitExpression(ACodeGen, LExprChild, AOutput);
          AOutput.Append(']');
        end;
      end;
    end;
    
    ntDot:
    begin
      // Member access: record.field or pointer->field
      if ANode.HasChildren and (Length(ANode.ChildNodes) >= 2) then
      begin
        var LLeft := ANode.ChildNodes[0];
        var LRight := ANode.ChildNodes[1];
        
        // Check if left side is a pointer dereference
        if LLeft.Typ = ntDeref then
        begin
          // Pointer dereference: (*ptr).field -> ptr->field
          if LLeft.HasChildren then
            EmitExpression(ACodeGen, LLeft.ChildNodes[0], AOutput);
          AOutput.Append('->');
        end
        else
        begin
          // Regular member access: record.field
          EmitExpression(ACodeGen, LLeft, AOutput);
          AOutput.Append('.');
        end;
        
        EmitExpression(ACodeGen, LRight, AOutput);
      end;
    end;
    
    ntIn:
    begin
      // Set membership test: value in set -> bp::InSet(set, value)
      //LChild := nil;
      //LArrayBase := nil;
      
      if ANode.HasChildren and (Length(ANode.ChildNodes) >= 2) then
      begin
        LChild := ANode.ChildNodes[0];
        LArrayBase := ANode.ChildNodes[1];
        
        AOutput.Append('bp::InSet(');
        EmitExpression(ACodeGen, LArrayBase, AOutput);
        AOutput.Append(', ');
        EmitExpression(ACodeGen, LChild, AOutput);
        AOutput.Append(')');
      end;
    end;
    
    ntAdd, ntSub, ntMul, ntFDiv, ntDiv, ntMod,
    ntShl, ntShr,
    ntAnd, ntOr, ntXor,
    ntEqual, ntNotEqual, ntLower, ntGreater, ntLowerEqual, ntGreaterEqual:
      EmitBinaryOp(ACodeGen, ANode, AOutput);
    
    ntNot, ntUnaryMinus,
    ntAddr, ntDeref:
      EmitUnaryOp(ACodeGen, ANode, AOutput);
    
  else
    // For other expression types, recursively walk children
    for LChild in ANode.ChildNodes do
      EmitExpression(ACodeGen, LChild, AOutput);
  end;
end;

procedure EmitIdentifier(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);
var
  LName: string;
  LParent: TSyntaxNode;
begin
  LName := ACodeGen.GetNodeValue(ANode);
  
  if LName = '' then
    LName := ANode.GetAttribute(anName);
  
  // Handle boolean identifiers - convert Pascal to C++
  if SameText(LName, 'True') then
  begin
    AOutput.Append('true');
    Exit;
  end
  else if SameText(LName, 'False') then
  begin
    AOutput.Append('false');
    Exit;
  end;
  
  // Check if we're in a WITH context and should qualify the identifier
  // Only qualify if it's a bare identifier (not already part of a DOT expression)
  if ACodeGen.IsInWithContext() then
  begin
    LParent := ANode.ParentNode;
    // Qualify with WITH context UNLESS:
    // 1. Parent is a DOT node (already being qualified)
    // 2. Parent is an INDEXED node (array indexing, not member access)
    if not Assigned(LParent) or ((LParent.Typ <> ntDot) and (LParent.Typ <> ntIndexed)) then
    begin
      // Qualify with WITH context
      AOutput.Append(ACodeGen.GetWithContext() + '.' + ACodeGen.ResolveIdentifierName(LName));
      Exit;
    end;
  end;
  
  // Check if this is a runtime function that needs bp:: prefix
  // IMPORTANT: Only treat as runtime function if it's an EXACT case match
  // to avoid conflicts with user variables (e.g., LN vs Ln)
  if ACodeGen.RuntimeFunctions().ContainsKey(LName) and 
     (ACodeGen.GetRuntimeFunctionName(LName) = LName) then
    AOutput.Append('bp::' + LName)
  else
    AOutput.Append(ACodeGen.ResolveIdentifierName(LName));
end;

procedure EmitLiteral(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);
var
  LValue: string;
  LType: string;
  LDecoded: string;
  //LI: Integer;
begin
  LValue := ACodeGen.GetNodeValue(ANode);
  
  if LValue = '' then
    LValue := ANode.GetAttribute(anName);
  
  // Check the literal type
  LType := ANode.GetAttribute(anType);
  
  // Handle nil literal
  if SameText(LType, 'nil') then
  begin
    AOutput.Append('nullptr');
    Exit;
  end;
  
  // Handle boolean literals - convert Pascal to C++
  if SameText(LValue, 'True') then
  begin
    AOutput.Append('true');
    Exit;
  end
  else if SameText(LValue, 'False') then
  begin
    AOutput.Append('false');
    Exit;
  end;
  
  // Handle string literals - ensure they have quotes
  if SameText(LType, 'string') then
  begin
    // Decode XML entities
    LDecoded := LValue;
    LDecoded := StringReplace(LDecoded, '&quot;', '"', [rfReplaceAll]);
    LDecoded := StringReplace(LDecoded, '&apos;', '''', [rfReplaceAll]);
    LDecoded := StringReplace(LDecoded, '&lt;', '<', [rfReplaceAll]);
    LDecoded := StringReplace(LDecoded, '&gt;', '>', [rfReplaceAll]);
    LDecoded := StringReplace(LDecoded, '&amp;', '&', [rfReplaceAll]);
    
    // Check for #A prefix to indicate ANSI string literal (exception case)
    if (Length(LDecoded) >= 2) and (Copy(LDecoded, 1, 2) = '#A') then
    begin
      // Strip the #A marker
      LDecoded := Copy(LDecoded, 3, Length(LDecoded) - 2);
      
      // Escape backslashes and quotes for C++
      LDecoded := StringReplace(LDecoded, '\', '\\', [rfReplaceAll]);
      LDecoded := StringReplace(LDecoded, '"', '\"', [rfReplaceAll]);
      
      // Emit as regular ANSI string literal
      AOutput.Append('"' + LDecoded + '"');
    end
    else
    begin
      // DEFAULT: Emit as wide string literal with L prefix (Unicode)
      // Escape backslashes and quotes for C++
      LDecoded := StringReplace(LDecoded, '\', '\\', [rfReplaceAll]);
      LDecoded := StringReplace(LDecoded, '"', '\"', [rfReplaceAll]);
      
      AOutput.Append('L"' + LDecoded + '"');
    end;
  end
  else
  begin
    // Handle hexadecimal literals - convert Pascal $XXXX to C++ 0xXXXX
    if (Length(LValue) > 1) and (LValue[1] = '$') then
    begin
      AOutput.Append('0x' + Copy(LValue, 2, Length(LValue)));
      Exit;
    end;
    
    // For all other numeric literals, output as-is
    AOutput.Append(LValue);
  end;
end;

procedure EmitBinaryOp(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);
var
  LLeft: TSyntaxNode;
  LRight: TSyntaxNode;
  LOp: string;
  LIsBoolean: Boolean;
  
  function IsComparisonOrBoolean(const AExprNode: TSyntaxNode): Boolean;
  var
    LChild: TSyntaxNode;
  begin
    Result := False;
    if not Assigned(AExprNode) then
      Exit;
    
    // Check the node itself
    if AExprNode.Typ in [ntEqual, ntNotEqual, ntLower, ntGreater, ntLowerEqual, ntGreaterEqual,
                         ntAnd, ntOr, ntNot] then
    begin
      Result := True;
      Exit;
    end;
    
    // Check children recursively
    if AExprNode.HasChildren then
    begin
      for LChild in AExprNode.ChildNodes do
      begin
        if IsComparisonOrBoolean(LChild) then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
  
begin
  if ANode.HasChildren and (Length(ANode.ChildNodes) >= 2) then
  begin
    LLeft := ANode.ChildNodes[0];
    LRight := ANode.ChildNodes[1];
    LOp := ACodeGen.MapOperator(ANode.Typ);
    
    // Special handling for Pascal 'div' operator - call .Div() method
    if ANode.Typ = ntDiv then
    begin
      AOutput.Append('(');
      EmitExpression(ACodeGen, LLeft, AOutput);
      AOutput.Append('.Div(');
      EmitExpression(ACodeGen, LRight, AOutput);
      AOutput.Append('))');
      Exit;
    end;
    
    // Special handling for Pascal 'mod' operator - call .Mod() method  
    if ANode.Typ = ntMod then
    begin
      AOutput.Append('(');
      EmitExpression(ACodeGen, LLeft, AOutput);
      AOutput.Append('.Mod(');
      EmitExpression(ACodeGen, LRight, AOutput);
      AOutput.Append('))');
      Exit;
    end;
    
    // Determine if this is a boolean context by checking operands
    LIsBoolean := IsComparisonOrBoolean(LLeft) or IsComparisonOrBoolean(LRight);
    
    // Replace context-dependent operators
    if LOp = 'AND_OP' then
    begin
      if LIsBoolean then
        LOp := '&&'  // Logical AND
      else
        LOp := '&';  // Bitwise AND
    end
    else if LOp = 'OR_OP' then
    begin
      if LIsBoolean then
        LOp := '||'  // Logical OR
      else
        LOp := '|';  // Bitwise OR
    end;
    
    // Standard binary operator
    AOutput.Append('(');
    EmitExpression(ACodeGen, LLeft, AOutput);
    AOutput.Append(' ' + LOp + ' ');
    EmitExpression(ACodeGen, LRight, AOutput);
    AOutput.Append(')');
  end;
end;

procedure EmitUnaryOp(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder);
var
  LOperand: TSyntaxNode;
  LOp: string;
  LIsBoolean: Boolean;
  LIdentName: string;
begin
  if ANode.HasChildren then
  begin
    LOperand := ANode.ChildNodes[0];
    LOp := ACodeGen.MapOperator(ANode.Typ);
    
    AOutput.Append('(');
    
    // Special handling for NOT operator - context-dependent
    if LOp = 'NOT_OP' then
    begin
      // Check if we're in a boolean context (if/while/repeat-until condition)
      if ACodeGen.InBooleanContext() then
      begin
        // We're in a context that MUST be boolean - always use logical NOT
        AOutput.Append('!');
        EmitExpression(ACodeGen, LOperand, AOutput);
        AOutput.Append(')');
        Exit;
      end;
      
      // Not in boolean context - use heuristics to determine logical vs bitwise
      // 1. Comparison operators (always return boolean)
      // 2. Boolean operators (and, or, xor, not)
      // 3. Function calls that return boolean (Eof, FileExists, etc.)
      // 4. Identifiers named with 'B' prefix or containing 'Bool' or 'Flag' (heuristic)
      LIsBoolean := (LOperand.Typ in [ntEqual, ntNotEqual, ntLower, ntGreater, ntLowerEqual, ntGreaterEqual,
                                       ntAnd, ntOr, ntNot]);
      
      // For function calls, check if it's a known boolean-returning function
      if (not LIsBoolean) and (LOperand.Typ = ntCall) then
      begin
        // Get the function name from the call
        if LOperand.HasChildren then
        begin
          for var LCallChild in LOperand.ChildNodes do
          begin
            if LCallChild.Typ = ntIdentifier then
            begin
              LIdentName := ACodeGen.GetNodeValue(LCallChild);
              if LIdentName = '' then
                LIdentName := LCallChild.GetAttribute(anName);
              
              // Known boolean-returning functions
              LIsBoolean := SameText(LIdentName, 'Eof') or
                            SameText(LIdentName, 'Eoln') or
                            SameText(LIdentName, 'SeekEof') or
                            SameText(LIdentName, 'SeekEoln') or
                            SameText(LIdentName, 'FileExists') or
                            SameText(LIdentName, 'DirectoryExists') or
                            SameText(LIdentName, 'CreateDir') or
                            SameText(LIdentName, 'RemoveDir') or
                            SameText(LIdentName, 'SetCurrentDir') or
                            SameText(LIdentName, 'DeleteFile') or
                            SameText(LIdentName, 'RemoveFile') or
                            SameText(LIdentName, 'RenameFile') or
                            SameText(LIdentName, 'Odd');
              Break;
            end;
          end;
        end;
      end;
      
      // For identifiers, use heuristics to determine if likely boolean
      if (not LIsBoolean) and (LOperand.Typ = ntIdentifier) then
      begin
        LIdentName := ACodeGen.GetNodeValue(LOperand);
        if LIdentName = '' then
          LIdentName := LOperand.GetAttribute(anName);
        
        // Check if identifier suggests boolean type
        LIsBoolean := (Length(LIdentName) > 0) and 
                      ((LIdentName[1] = 'B') or  // Convention: Boolean variables start with 'B'
                       (Pos('Bool', LIdentName) > 0) or
                       (Pos('Flag', LIdentName) > 0) or
                       (Pos('Is', LIdentName) = 1) or
                       (Pos('Has', LIdentName) = 1) or
                       (Pos('Can', LIdentName) = 1));
      end;
      
      if LIsBoolean then
        AOutput.Append('!')   // Logical NOT for boolean
      else
        AOutput.Append('~');  // Bitwise NOT for integer
    end
    else
      AOutput.Append(LOp);
    
    EmitExpression(ACodeGen, LOperand, AOutput);
    AOutput.Append(')');
  end;
end;

end.
