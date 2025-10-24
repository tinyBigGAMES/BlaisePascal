{===============================================================================
  Blaise Pascal� - Think in Pascal. Compile to C++

  Copyright � 2025-present tinyBigGAMES� LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.CodeGen.Statements;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Consts,
  Blaise.CodeGen;

procedure EmitStatements(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitStatement(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitAssignment(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitCall(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitIf(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitWhile(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitFor(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitRepeat(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitCase(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitTry(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
procedure EmitWith(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);

implementation

procedure EmitCastedLiteral(const ACodeGen: TCodeGen; const ALiteralNode: TSyntaxNode; const AOutput: TStringBuilder);
var
  LValue: string;
  LType: string;
  LTargetType: string;
  LCastType: string;
begin
  LValue := ACodeGen.GetNodeValue(ALiteralNode);
  if LValue = '' then
    LValue := ALiteralNode.GetAttribute(anName);
  
  LType := ALiteralNode.GetAttribute(anType);
  
  // Only cast numeric literals with decimal points
  if not SameText(LType, 'numeric') then
  begin
    // Not a numeric literal - emit normally
    ACodeGen.EmitLiteral(ALiteralNode, AOutput);
    Exit;
  end;
  
  // Check if it's a floating-point literal (contains decimal point)
  if Pos('.', LValue) = 0 then
  begin
    // Integer literal - emit normally
    ACodeGen.EmitLiteral(ALiteralNode, AOutput);
    Exit;
  end;
  
  // Determine cast type from target context
  LTargetType := ACodeGen.GetTargetType();
  
  if SameText(LTargetType, 'Single') then
    LCastType := 'bp::Single'
  else if SameText(LTargetType, 'Extended') then
    LCastType := 'bp::Extended'
  else
    LCastType := 'bp::Double'; // Default to Double
  
  // Emit casted literal
  AOutput.Append(LCastType + '(' + LValue + ')');
end;

function NeedsLiteralCast(const AExprNode: TSyntaxNode): Boolean;
var
  LChild: TSyntaxNode;
begin
  Result := False;
  
  if not Assigned(AExprNode) or not AExprNode.HasChildren then
    Exit;
  
  // Check if this is a direct literal
  if (Length(AExprNode.ChildNodes) = 1) and (AExprNode.ChildNodes[0].Typ = ntLiteral) then
  begin
    Result := True;
    Exit;
  end;
  
  // Check if this is a unary minus applied to a literal
  if (Length(AExprNode.ChildNodes) = 1) and (AExprNode.ChildNodes[0].Typ = ntUnaryMinus) then
  begin
    LChild := AExprNode.ChildNodes[0];
    if LChild.HasChildren and (Length(LChild.ChildNodes) = 1) and (LChild.ChildNodes[0].Typ = ntLiteral) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function GetLiteralFromExpression(const AExprNode: TSyntaxNode): TSyntaxNode;
var
  LChild: TSyntaxNode;
begin
  Result := nil;
  
  if not Assigned(AExprNode) or not AExprNode.HasChildren then
    Exit;
  
  // Direct literal
  if (Length(AExprNode.ChildNodes) = 1) and (AExprNode.ChildNodes[0].Typ = ntLiteral) then
  begin
    Result := AExprNode.ChildNodes[0];
    Exit;
  end;
  
  // Literal under unary minus
  if (Length(AExprNode.ChildNodes) = 1) and (AExprNode.ChildNodes[0].Typ = ntUnaryMinus) then
  begin
    LChild := AExprNode.ChildNodes[0];
    if LChild.HasChildren and (Length(LChild.ChildNodes) = 1) and (LChild.ChildNodes[0].Typ = ntLiteral) then
    begin
      Result := LChild.ChildNodes[0];
      Exit;
    end;
  end;
end;

function CanOptimizeToInPlaceConcat(const ACodeGen: TCodeGen; 
  const ALLHS: TSyntaxNode; const ARLHS: TSyntaxNode; 
  out ARHSRight: TSyntaxNode): Boolean;
var
  LLHSIdentifier: TSyntaxNode;
  LLHSName: string;
  LRHSExpression: TSyntaxNode;
  LAddNode: TSyntaxNode;
  LAddLeft: TSyntaxNode;
  LAddLeftName: string;
  LVarType: string;
begin
  Result := False;
  ARHSRight := nil;
  
  // Safety check: nodes must be assigned
  if not Assigned(ALLHS) or not Assigned(ARLHS) then
    Exit;
  
  // Check 1: LHS must be a simple identifier (not array[i], not record.field)
  if not ALLHS.HasChildren or (Length(ALLHS.ChildNodes) <> 1) then
    Exit;
    
  LLHSIdentifier := ALLHS.ChildNodes[0];
  if LLHSIdentifier.Typ <> ntIdentifier then
    Exit;
  
  // Get LHS identifier name
  LLHSName := ACodeGen.GetNodeValue(LLHSIdentifier);
  if LLHSName = '' then
    LLHSName := LLHSIdentifier.GetAttribute(anName);
  
  if LLHSName = '' then
    Exit;
  
  // Check 3: LHS must be a String type
  LVarType := ACodeGen.GetVariableType(LLHSName);
  
  if not SameText(LVarType, 'String') then
    Exit;
  
  // Check 4: RHS must have exactly one child (the expression)
  if not ARLHS.HasChildren or (Length(ARLHS.ChildNodes) <> 1) then
    Exit;
  
  LRHSExpression := ARLHS.ChildNodes[0];
  
  // Check 5: RHS expression must contain ntAdd
  // If the RHS child is ntExpression, unwrap it to get the actual operation
  if LRHSExpression.Typ = ntExpression then
  begin
    if not LRHSExpression.HasChildren or (Length(LRHSExpression.ChildNodes) <> 1) then
      Exit;
    LRHSExpression := LRHSExpression.ChildNodes[0];
  end;
  
  if LRHSExpression.Typ <> ntAdd then
    Exit;
  
  LAddNode := LRHSExpression;
  
  // Check 6: ntAdd must have exactly 2 children
  if not LAddNode.HasChildren or (Length(LAddNode.ChildNodes) <> 2) then
    Exit;
  
  // Check 7: Left side of + must be an identifier
  LAddLeft := LAddNode.ChildNodes[0];
  if LAddLeft.Typ <> ntIdentifier then
    Exit;
  
  // Check 8: Left identifier must match LHS identifier
  LAddLeftName := ACodeGen.GetNodeValue(LAddLeft);
  if LAddLeftName = '' then
    LAddLeftName := LAddLeft.GetAttribute(anName);
  
  if not SameText(LAddLeftName, LLHSName) then
    Exit;
  
  // All checks passed! Set the right side for emission
  ARHSRight := LAddNode.ChildNodes[1];
  Result := True;
end;

procedure EmitExpressionWithCast(const ACodeGen: TCodeGen; const AExprNode: TSyntaxNode; const AOutput: TStringBuilder);
var
  LLiteralNode: TSyntaxNode;
  //LUnaryNode: TSyntaxNode;
  LExprChild: TSyntaxNode;
  LTargetType: string;
  LCastType: string;
  LValue: string;
  LType: string;
begin
  // Check if this expression contains a literal that needs casting
  if not NeedsLiteralCast(AExprNode) then
  begin
    // Normal expression - emit as usual
    for LExprChild in AExprNode.ChildNodes do
      ACodeGen.EmitExpression(LExprChild, AOutput);
    Exit;
  end;
  
  // Get the literal node
  LLiteralNode := GetLiteralFromExpression(AExprNode);
  if not Assigned(LLiteralNode) then
  begin
    // Fallback - emit normally
    for LExprChild in AExprNode.ChildNodes do
      ACodeGen.EmitExpression(LExprChild, AOutput);
    Exit;
  end;
  
  // Check if literal needs casting (floating point)
  LValue := ACodeGen.GetNodeValue(LLiteralNode);
  if LValue = '' then
    LValue := LLiteralNode.GetAttribute(anName);
  
  LType := LLiteralNode.GetAttribute(anType);
  
  if not SameText(LType, 'numeric') then
  begin
    // Not a numeric literal - emit normally
    for LExprChild in AExprNode.ChildNodes do
      ACodeGen.EmitExpression(LExprChild, AOutput);
    Exit;
  end;
  
  // Determine cast type based on whether it's a float or integer literal
  if Pos('.', LValue) > 0 then
  begin
    // Floating-point literal - determine cast type from target context
    LTargetType := ACodeGen.GetTargetType();
    if SameText(LTargetType, 'Single') then
      LCastType := 'bp::Single'
    else if SameText(LTargetType, 'Extended') then
      LCastType := 'bp::Extended'
    else
      LCastType := 'bp::Double';
  end
  else
  begin
    // Integer literal - cast to bp::Integer
    LCastType := 'bp::Integer';
  end;
  
  // Check if this is a unary minus case
  if (Length(AExprNode.ChildNodes) = 1) and (AExprNode.ChildNodes[0].Typ = ntUnaryMinus) then
  begin
    // Emit as: -(cast(literal))
    // This ensures the cast happens first, then the unary minus is applied
    AOutput.Append('(-');
    AOutput.Append(LCastType + '(');
    ACodeGen.EmitLiteral(LLiteralNode, AOutput);
    AOutput.Append('))');
  end
  else
  begin
    // Direct literal - emit as: cast(literal)
    AOutput.Append(LCastType + '(');
    ACodeGen.EmitLiteral(LLiteralNode, AOutput);
    AOutput.Append(')');
  end;
end;

procedure EmitStatements(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
begin
  for LChild in ANode.ChildNodes do
    ACodeGen.WalkNode(LChild, AOutput, AIndent);
end;

procedure EmitStatement(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
begin
  for LChild in ANode.ChildNodes do
    ACodeGen.WalkNode(LChild, AOutput, AIndent);
end;

procedure EmitAssignment(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LLHS: TSyntaxNode;
  LRHS: TSyntaxNode;
  LLHSIdentifier: TSyntaxNode;
  LTargetType: string;
  LIdentifierName: string;
  LRHSRight: TSyntaxNode;
begin
  LLHS := ANode.FindNode(ntLHS);
  LRHS := ANode.FindNode(ntRHS);
  
  // String concatenation optimization: LStr := LStr + X → LStr += X
  if CanOptimizeToInPlaceConcat(ACodeGen, LLHS, LRHS, LRHSRight) then
  begin
    ACodeGen.EmitLineDirective(ANode, AOutput);
    AOutput.Append(ACodeGen.GetIndent(AIndent));
    ACodeGen.EmitExpression(LLHS, AOutput);
    AOutput.Append(' += ');
    ACodeGen.EmitExpression(LRHSRight, AOutput);
    AOutput.AppendLine(';');
    Exit;
  end;
  
  // Original assignment logic (unchanged)
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  
  // Try to determine target type from LHS
  LTargetType := '';
  if Assigned(LLHS) then
  begin
    ACodeGen.EmitExpression(LLHS, AOutput);
    
    // Look for identifier in LHS to determine target type
    LLHSIdentifier := LLHS.FindNode(ntIdentifier);
    if Assigned(LLHSIdentifier) then
    begin
      LIdentifierName := ACodeGen.GetNodeValue(LLHSIdentifier);
      if LIdentifierName = '' then
        LIdentifierName := LLHSIdentifier.GetAttribute(anName);
      
      if LIdentifierName <> '' then
        LTargetType := ACodeGen.GetVariableType(LIdentifierName);
    end;
  end;
  
  AOutput.Append(' = ');
  
  if Assigned(LRHS) then
  begin
    // Pass target type context to expression emission
    ACodeGen.SetTargetType(LTargetType);
    ACodeGen.EmitExpression(LRHS, AOutput);
    ACodeGen.ClearTargetType();
  end;
  
  AOutput.AppendLine(';');
end;

procedure EmitCall(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
  LIdNode: TSyntaxNode;
  LExprsNode: TSyntaxNode;
  LExprNode: TSyntaxNode;
  LExprChild: TSyntaxNode;
  LFirst: Boolean;
  LFuncName: string;
  LIsSizeOf: Boolean;
  LArgIdentifier: string;
begin
  if AIndent > 0 then
  begin
    ACodeGen.EmitLineDirective(ANode, AOutput);
    AOutput.Append(ACodeGen.GetIndent(AIndent));
  end;
  
  // Find the identifier and expressions nodes
  LIdNode := nil;
  LExprsNode := nil;
  
  for LChild in ANode.ChildNodes do
  begin
    if LChild.Typ = ntIdentifier then
      LIdNode := LChild
    else if LChild.Typ = ntExpressions then
      LExprsNode := LChild
    else if LChild.Typ = ntCall then
    begin
      // Nested call - recurse into it
      for LExprChild in LChild.ChildNodes do
      begin
        if LExprChild.Typ = ntIdentifier then
          LIdNode := LExprChild
        else if LExprChild.Typ = ntExpressions then
          LExprsNode := LExprChild;
      end;
    end;
  end;
  
  // Check for special control flow keywords
  LIsSizeOf := False;
  if Assigned(LIdNode) then
  begin
    LFuncName := ACodeGen.GetNodeValue(LIdNode);
    if LFuncName = '' then
      LFuncName := LIdNode.GetAttribute(anName);
    
    // Check if this is a SizeOf call
    LIsSizeOf := SameText(LFuncName, 'SizeOf');
    
    // Handle break, continue, exit as special cases
    if SameText(LFuncName, 'break') then
    begin
      AOutput.Append('break');
      if AIndent > 0 then
        AOutput.AppendLine(';');
      Exit;
    end
    else if SameText(LFuncName, 'continue') then
    begin
      AOutput.Append('continue');
      if AIndent > 0 then
        AOutput.AppendLine(';');
      Exit;
    end
    else if SameText(LFuncName, 'exit') then
    begin
      // Check if exit has a parameter (return value)
      if Assigned(LExprsNode) and LExprsNode.HasChildren then
      begin
        // exit(value) - check if we're in a function
        if SameText(ACodeGen.GetRoutineKind(), 'FUNCTION') then
        begin
          // In a function: emit Result = value; return Result;
          AOutput.Append('Result = ');
          //LFirst := True;
          for LExprNode in LExprsNode.ChildNodes do
          begin
            if LExprNode.Typ = ntExpression then
            begin
              // Walk the expression's children
              for LExprChild in LExprNode.ChildNodes do
                ACodeGen.EmitExpression(LExprChild, AOutput);
              Break; // Only use the first expression
            end;
          end;
          AOutput.AppendLine(';');
          if AIndent > 0 then
            AOutput.Append(ACodeGen.GetIndent(AIndent));
          AOutput.Append('return Result');
        end
        else
        begin
          // In a procedure: just return (ignore the value - this is unusual but legal Pascal)
          AOutput.Append('return');
        end;
      end
      else
      begin
        // Bare exit; 
        AOutput.Append('return');
        // Check if we're in a function
        if SameText(ACodeGen.GetRoutineKind(), 'FUNCTION') then
        begin
          // In a function, return Result
          AOutput.Append(' Result');
        end;
        // In a procedure, just return (no value)
      end;
      
      if AIndent > 0 then
        AOutput.AppendLine(';');
      Exit;
    end;
  end;
  
  // Emit the call
  if Assigned(LIdNode) then
  begin
    // Special handling for SizeOf - emit as sizeof() in C++
    if LIsSizeOf then
    begin
      AOutput.Append('sizeof(');
      
      if Assigned(LExprsNode) then
      begin
        LFirst := True;
        for LExprNode in LExprsNode.ChildNodes do
        begin
          if LExprNode.Typ = ntExpression then
          begin
            if not LFirst then
              AOutput.Append(', ');
            LFirst := False;
            
            // Check if argument is a type identifier
            if LExprNode.HasChildren and (Length(LExprNode.ChildNodes) = 1) and 
               (LExprNode.ChildNodes[0].Typ = ntIdentifier) then
            begin
              LArgIdentifier := ACodeGen.GetNodeValue(LExprNode.ChildNodes[0]);
              if LArgIdentifier = '' then
                LArgIdentifier := LExprNode.ChildNodes[0].GetAttribute(anName);
              
              // Check if this is a known type name
              if ACodeGen.TypeMappings().ContainsKey(LArgIdentifier) then
              begin
                // This is a type name - emit it with bp:: prefix
                AOutput.Append(ACodeGen.TypeMappings()[LArgIdentifier]);
              end
              else
              begin
                // Not a known type - emit normally (could be a variable)
                for LExprChild in LExprNode.ChildNodes do
                  ACodeGen.EmitExpression(LExprChild, AOutput);
              end;
            end
            else
            begin
              // Normal expression - walk the children
              for LExprChild in LExprNode.ChildNodes do
                ACodeGen.EmitExpression(LExprChild, AOutput);
            end;
          end;
        end;
      end;
      
      AOutput.Append(')');
    end
    else
    begin
      // Normal function call
      // Check if this is a TYPE CAST (type constructor call) that needs bp:: prefix
      if ACodeGen.TypeMappings().ContainsKey(LFuncName) then
      begin
        // This is a type cast, e.g., Byte(...), Integer(...), Pointer(...)
        // Emit with bp:: prefix
        AOutput.Append(ACodeGen.TypeMappings()[LFuncName]);
      end
      // Check if this is a runtime function that needs bp:: prefix
      else if ACodeGen.RuntimeFunctions().ContainsKey(LFuncName) then
        AOutput.Append('bp::' + ACodeGen.GetRuntimeFunctionName(LFuncName))
      else
        ACodeGen.EmitIdentifier(LIdNode, AOutput);
      AOutput.Append('(');
      
      if Assigned(LExprsNode) then
      begin
        LFirst := True;
        for LExprNode in LExprsNode.ChildNodes do
        begin
          if LExprNode.Typ = ntExpression then
          begin
            if not LFirst then
              AOutput.Append(', ');
            LFirst := False;
            
            // Check if this is a floating-point literal (or unary minus of one)
            // that needs casting for overloaded runtime functions
            if ACodeGen.RuntimeFunctions().ContainsKey(LFuncName) and NeedsLiteralCast(LExprNode) then
            begin
              // This is a literal argument (possibly with unary minus) to a runtime function
              // Cast it based on target type context
              EmitExpressionWithCast(ACodeGen, LExprNode, AOutput);
            end
            else
            begin
              // Walk the expression's children normally
              for LExprChild in LExprNode.ChildNodes do
                ACodeGen.EmitExpression(LExprChild, AOutput);
            end;
          end;
        end;
      end;
      
      AOutput.Append(')');
    end;
  end;
  
  if AIndent > 0 then
    AOutput.AppendLine(';');
end;

procedure EmitIf(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LCondition: TSyntaxNode;
  LThen: TSyntaxNode;
  LElse: TSyntaxNode;
  LChild: TSyntaxNode;
begin
  LCondition := ANode.FindNode(ntExpression);
  LThen := ANode.FindNode(ntThen);
  LElse := ANode.FindNode(ntElse);
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.Append('if (');
  
  if Assigned(LCondition) then
  begin
    ACodeGen.SetBooleanContext(True);
    ACodeGen.EmitExpression(LCondition, AOutput);
    ACodeGen.SetBooleanContext(False);
  end;
  
  AOutput.AppendLine(') {');
  
  if Assigned(LThen) then
  begin
    // Walk children of THEN node, not the THEN node itself
    for LChild in LThen.ChildNodes do
      ACodeGen.WalkNode(LChild, AOutput, AIndent + 1);
  end;
  
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.Append('}');
  
  if Assigned(LElse) then
  begin
    AOutput.AppendLine(' else {');
    // Walk children of ELSE node, not the ELSE node itself
    for LChild in LElse.ChildNodes do
      ACodeGen.WalkNode(LChild, AOutput, AIndent + 1);
    AOutput.Append(ACodeGen.GetIndent(AIndent));
    AOutput.Append('}');
  end;
  
  AOutput.AppendLine();
end;

procedure EmitWhile(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LCondition: TSyntaxNode;
  LStatements: TSyntaxNode;
begin
  LCondition := ANode.FindNode(ntExpression);
  LStatements := ANode.FindNode(ntStatements);
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.Append('while (');
  
  if Assigned(LCondition) then
  begin
    ACodeGen.SetBooleanContext(True);
    ACodeGen.EmitExpression(LCondition, AOutput);
    ACodeGen.SetBooleanContext(False);
  end;
  
  AOutput.AppendLine(') {');
  
  if Assigned(LStatements) then
    EmitStatements(ACodeGen, LStatements, AOutput, AIndent + 1);
  
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.AppendLine('}');
end;

procedure EmitFor(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LVariable: TSyntaxNode;
  LFrom: TSyntaxNode;
  LTo: TSyntaxNode;
  LDownto: TSyntaxNode;
  LVarName: string;
  LIsDownto: Boolean;
begin
  // Find FOR loop components
  LVariable := ANode.FindNode(ntIdentifier);
  LFrom := ANode.FindNode(ntFrom);
  LTo := ANode.FindNode(ntTo);
  LDownto := ANode.FindNode(ntDownto);
  
  // Determine if this is a downto loop
  LIsDownto := Assigned(LDownto);
  
  if not Assigned(LVariable) or not Assigned(LFrom) or (not Assigned(LTo) and not Assigned(LDownto)) then
  begin
    ACodeGen.LogUnimplemented(ntFor, 'EmitFor - missing components');
    Exit;
  end;
  
  LVarName := ACodeGen.GetNodeValue(LVariable);
  if LVarName = '' then
    LVarName := LVariable.GetAttribute(anName);
  
  // Apply identifier conflict resolution
  LVarName := ACodeGen.ResolveIdentifierName(LVarName);
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.Append('for (' + LVarName + ' = ');
  
  // Emit FROM expression
  if LFrom.HasChildren then
  begin
    for var LChild in LFrom.ChildNodes do
      ACodeGen.EmitExpression(LChild, AOutput);
  end;
  
  if LIsDownto then
  begin
    // For DOWNTO loop: condition is >= and decrement
    AOutput.Append('; ' + LVarName + ' >= ');
    
    // Emit DOWNTO expression
    if LDownto.HasChildren then
    begin
      for var LChild in LDownto.ChildNodes do
        ACodeGen.EmitExpression(LChild, AOutput);
    end;
    
    AOutput.Append('; --' + LVarName);
  end
  else
  begin
    // For TO loop: condition is <= and increment
    AOutput.Append('; ' + LVarName + ' <= ');
    
    // Emit TO expression
    if LTo.HasChildren then
    begin
      for var LChild in LTo.ChildNodes do
        ACodeGen.EmitExpression(LChild, AOutput);
    end;
    
    AOutput.Append('; ++' + LVarName);
  end;
  
  AOutput.AppendLine(') {');
  
  // Emit FOR loop body
  // The body is directly in the FOR node's children, not in a separate STATEMENTS node
  for var LChild in ANode.ChildNodes do
  begin
    if (LChild.Typ <> ntIdentifier) and (LChild.Typ <> ntFrom) and (LChild.Typ <> ntTo) and (LChild.Typ <> ntDownto) then
      ACodeGen.WalkNode(LChild, AOutput, AIndent + 1);
  end;
  
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.AppendLine('}');
end;

procedure EmitRepeat(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LCondition: TSyntaxNode;
  LStatements: TSyntaxNode;
begin
  LCondition := ANode.FindNode(ntExpression);
  LStatements := ANode.FindNode(ntStatements);
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.AppendLine('do {');
  
  if Assigned(LStatements) then
    EmitStatements(ACodeGen, LStatements, AOutput, AIndent + 1);
  
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.Append('} while (!(');
  
  if Assigned(LCondition) then
  begin
    ACodeGen.SetBooleanContext(True);
    ACodeGen.EmitExpression(LCondition, AOutput);
    ACodeGen.SetBooleanContext(False);
  end;
  
  AOutput.AppendLine('));');
end;

procedure EmitCase(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LExpr: TSyntaxNode;
  LChild: TSyntaxNode;
  LLabelsNode: TSyntaxNode;
  LLabelNode: TSyntaxNode;
  LLabelExpr: TSyntaxNode;
  LStatements: TSyntaxNode;
  //LHasElse: Boolean;
  //LFirst: Boolean;
  LRangeStart: TSyntaxNode;
  LRangeEnd: TSyntaxNode;
  LStartVal: Integer;
  LEndVal: Integer;
  I: Integer;
begin
  LExpr := ANode.FindNode(ntExpression);
  //LHasElse := False;
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.Append('switch (static_cast<int>(');
  
  if Assigned(LExpr) then
    ACodeGen.EmitExpression(LExpr, AOutput);
  
  AOutput.AppendLine(')) {');
  
  // Walk children looking for case selectors
  for LChild in ANode.ChildNodes do
  begin
    if LChild.Typ = ntCaseSelector then
    begin
      // Find CASELABELS node
      LLabelsNode := LChild.FindNode(ntCaseLabels);
      LStatements := nil;
      
      // Find the statement (could be direct child or in STATEMENTS node)
      for var LSelectorChild in LChild.ChildNodes do
      begin
        if (LSelectorChild.Typ <> ntCaseLabels) and (LSelectorChild.Typ <> ntExpression) then
        begin
          if LSelectorChild.Typ = ntStatements then
            LStatements := LSelectorChild
          else
          begin
            // Direct statement - wrap it
            LStatements := LSelectorChild;
          end;
          Break;
        end;
      end;
      
      // Process each case label
      if Assigned(LLabelsNode) then
      begin
        for LLabelNode in LLabelsNode.ChildNodes do
        begin
          if LLabelNode.Typ = ntCaseLabel then
          begin
            // Check if this is a range (has 2 expressions) or single value
            if LLabelNode.HasChildren then
            begin
              if Length(LLabelNode.ChildNodes) = 2 then
              begin
                // Range: low..high
                LRangeStart := LLabelNode.ChildNodes[0];
                LRangeEnd := LLabelNode.ChildNodes[1];
                
                // Try to extract integer values for range expansion
                if LRangeStart.HasChildren and (LRangeStart.ChildNodes[0].Typ = ntLiteral) and
                   LRangeEnd.HasChildren and (LRangeEnd.ChildNodes[0].Typ = ntLiteral) then
                begin
                  LStartVal := StrToIntDef(ACodeGen.GetNodeValue(LRangeStart.ChildNodes[0]), 0);
                  LEndVal := StrToIntDef(ACodeGen.GetNodeValue(LRangeEnd.ChildNodes[0]), 0);
                  
                  // Emit case for each value in range
                  for I := LStartVal to LEndVal do
                  begin
                    AOutput.Append(ACodeGen.GetIndent(AIndent + 1));
                    AOutput.AppendLine('case ' + IntToStr(I) + ':');
                  end;
                end
                else
                begin
                  // Can't expand range - just emit first value
                  AOutput.Append(ACodeGen.GetIndent(AIndent + 1));
                  AOutput.Append('case ');
                  ACodeGen.EmitExpression(LRangeStart, AOutput);
                  AOutput.AppendLine(':');
                end;
              end
              else
              begin
                // Single value
                LLabelExpr := LLabelNode.ChildNodes[0];
                AOutput.Append(ACodeGen.GetIndent(AIndent + 1));
                AOutput.Append('case ');
                ACodeGen.EmitExpression(LLabelExpr, AOutput);
                AOutput.AppendLine(':');
              end;
            end;
          end;
        end;
      end;
      
      // Emit the statement(s) for this case
      if Assigned(LStatements) then
      begin
        if LStatements.Typ = ntStatements then
          EmitStatements(ACodeGen, LStatements, AOutput, AIndent + 2)
        else
          ACodeGen.WalkNode(LStatements, AOutput, AIndent + 2);
      end;
      
      AOutput.Append(ACodeGen.GetIndent(AIndent + 2));
      AOutput.AppendLine('break;');
    end
    else if LChild.Typ = ntCaseElse then
    begin
      //LHasElse := True;
      LStatements := LChild.FindNode(ntStatements);
      
      AOutput.Append(ACodeGen.GetIndent(AIndent + 1));
      AOutput.AppendLine('default:');
      
      if Assigned(LStatements) then
        EmitStatements(ACodeGen, LStatements, AOutput, AIndent + 2);
      
      AOutput.Append(ACodeGen.GetIndent(AIndent + 2));
      AOutput.AppendLine('break;');
    end;
  end;
  
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.AppendLine('}');
end;

procedure EmitTry(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LTryBlock: TSyntaxNode;
  LExcept: TSyntaxNode;
  LFinally: TSyntaxNode;
  LChild: TSyntaxNode;
  //LExceptVar: string;
  //LExceptType: string;
begin
  LTryBlock := ANode.FindNode(ntStatements);
  LExcept := ANode.FindNode(ntExcept);
  LFinally := ANode.FindNode(ntFinally);
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.AppendLine('try {');
  
  if Assigned(LTryBlock) then
    EmitStatements(ACodeGen, LTryBlock, AOutput, AIndent + 1);
  
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.Append('}');
  
  if Assigned(LExcept) then
  begin
    AOutput.AppendLine(' catch (const std::exception& e) {');
    
    for LChild in LExcept.ChildNodes do
      ACodeGen.WalkNode(LChild, AOutput, AIndent + 1);
    
    AOutput.Append(ACodeGen.GetIndent(AIndent));
    AOutput.Append('}');
  end;
  
  if Assigned(LFinally) then
  begin
    // For try...finally, emit catch-all that executes finally and re-throws
    AOutput.AppendLine(' catch (...) {');
    
    // Emit finally block statements
    for LChild in LFinally.ChildNodes do
      ACodeGen.WalkNode(LChild, AOutput, AIndent + 1);
    
    // Re-throw the exception
    AOutput.Append(ACodeGen.GetIndent(AIndent + 1));
    AOutput.AppendLine('throw;');
    
    AOutput.Append(ACodeGen.GetIndent(AIndent));
    AOutput.AppendLine('}');
    
    // Emit finally block again for non-exception path
    for LChild in LFinally.ChildNodes do
      ACodeGen.WalkNode(LChild, AOutput, AIndent);
  end;
  
  AOutput.AppendLine();
end;

procedure EmitWith(const ACodeGen: TCodeGen; const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LExpressionsNode: TSyntaxNode;
  LExprNode: TSyntaxNode;
  LWithTarget: string;
  LChild: TSyntaxNode;
  LTempBuilder: TStringBuilder;
begin
  LExpressionsNode := ANode.FindNode(ntExpressions);
  
  if not Assigned(LExpressionsNode) or not LExpressionsNode.HasChildren then
  begin
    ACodeGen.LogUnimplemented(ntWith, 'EmitWith - missing expressions');
    Exit;
  end;
  
  LExprNode := LExpressionsNode.ChildNodes[0];
  if LExprNode.Typ <> ntExpression then
  begin
    ACodeGen.LogUnimplemented(ntWith, 'EmitWith - invalid expression node');
    Exit;
  end;
  
  LTempBuilder := TStringBuilder.Create();
  try
    for LChild in LExprNode.ChildNodes do
      ACodeGen.EmitExpression(LChild, LTempBuilder);
    LWithTarget := LTempBuilder.ToString().Trim();
  finally
    LTempBuilder.Free();
  end;
  
  if LWithTarget = '' then
  begin
    ACodeGen.LogUnimplemented(ntWith, 'EmitWith - could not determine target');
    Exit;
  end;
  
  ACodeGen.EmitLineDirective(ANode, AOutput);
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.AppendLine('{ // with ' + LWithTarget);
  ACodeGen.PushWithContext(LWithTarget);
  try
    for LChild in ANode.ChildNodes do
    begin
      if (LChild.Typ <> ntExpressions) and (LChild.Typ <> ntExpression) then
        ACodeGen.WalkNode(LChild, AOutput, AIndent + 1);
    end;
  finally
    ACodeGen.PopWithContext();
  end;
  AOutput.Append(ACodeGen.GetIndent(AIndent));
  AOutput.AppendLine('}');
end;

end.
