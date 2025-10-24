{===============================================================================
  Blaise Pascal� - Think in Pascal. Compile to C++

  Copyright � 2025-present tinyBigGAMES� LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.CodeGen;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Defaults,
  System.Generics.Collections,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Consts,
  DelphiAST.ProjectIndexer,
  Blaise.Errors,
  Blaise.Utils,
  Blaise.Preprocessing;

type

  { TCodeGen }
  TCodeGen = class
  private
    FIndexer: TProjectIndexer;
    FMainUnitName: string;
    FMainSourceFilePath: string;
    FOutputPath: string;
    FErrors: TErrors;
    FPreprocessor: TPreprocessor;
    FCurrentUnit: string;
    FInInterfaceSection: Boolean;
    FIsLibrary: Boolean;
    FExportedFunctions: TStringList;
    FLibraryInitCode: TStringBuilder;
    FLibraryFiniCode: TStringBuilder;
    FGeneratedFiles: TArray<string>;
    FRuntimeFunctions: TDictionary<string, Boolean>;
    FTypeMappings: TDictionary<string, string>;
    FOperatorMappings: TDictionary<TSyntaxNodeType, string>;
    FRoutineKind: string;
    FRoutineReturnType: string;
    FEmittedMethodsInHeader: TDictionary<string, Boolean>;
    FTargetType: string;
    FInBooleanContext: Boolean;
    FWithContextStack: TList<string>;
    FUnitPaths: TStringList;
    FCurrentMethodNode: TSyntaxNode;
    
    procedure ReportErrors(const AIndexer: TProjectIndexer; const AErrors: TErrors);
    function ParseLineColFromDescription(const ADescription: string; out ALine: Integer; out ACol: Integer): Boolean;
    procedure SetupDefines();
    procedure SetupSearchPaths();
    
    // Code generation methods
    function Generate(const AOutputPath: string): Boolean;
    {$HINTS OFF}
    procedure GenerateUnit(const AUnitInfo: TProjectIndexer.TUnitInfo);
    procedure GenerateHeader(const AUnitInfo: TProjectIndexer.TUnitInfo; const AOutput: TStringBuilder);
    procedure GenerateImplementation(const AUnitInfo: TProjectIndexer.TUnitInfo; const AOutput: TStringBuilder);
    {$HINTS ON}

  public
    constructor Create();
    destructor Destroy(); override;

    function Process(const AFilename: string; const AOutputPath: string; const APreprocessor: TPreprocessor; const AErrors: TErrors): Boolean;
    
    function GetParsedUnits(): TProjectIndexer.TParsedUnits;
    function GetMainUnitName(): string;
    function GetMainSourceFilePath(): string;
    function FindUnit(const AUnitName: string): TSyntaxNode;
    function GetGeneratedFiles(): TArray<string>;
    
    procedure Clear();
    
    // Public methods for use by emitter units
    procedure WalkNode(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitLineDirective(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
    function GetIndent(const ALevel: Integer): string;
    function MapType(const ATypeName: string): string;
    function MapOperator(const AOpType: TSyntaxNodeType): string;
    function GetNodeName(const ANode: TSyntaxNode): string;
    function GetNodeValue(const ANode: TSyntaxNode): string;
    procedure LogUnimplemented(const ANodeType: TSyntaxNodeType; const AContext: string);
    function GetRuntimeFunctionName(const APascalName: string): string;
    function HasRuntimeFunctionConflict(const AIdentifier: string): Boolean;
    function ResolveIdentifierName(const AIdentifier: string): string;
    function GetVariableType(const AIdentifier: string): string;
    
    // Accessors for private fields needed by emitter units
    function RuntimeFunctions(): TDictionary<string, Boolean>;
    function TypeMappings(): TDictionary<string, string>;
    function InInterfaceSection(): Boolean;
    procedure SetInInterfaceSection(const AValue: Boolean);
    function IsLibrary(): Boolean;
    procedure SetIsLibrary(const AValue: Boolean);
    function ExportedFunctions(): TStringList;
    function CurrentUnit(): string;
    procedure SetCurrentUnit(const AValue: string);
    function Errors(): TErrors;
    function Preprocessor(): TPreprocessor;
    function GetOutputPath(): string;
    procedure SetOutputPath(const AValue: string);
    procedure AddGeneratedFile(const AFilePath: string);
    function GetIndexer(): TProjectIndexer;
    
    // Routine context for exit handling
    procedure SetRoutineContext(const AKind: string; const AReturnType: string);
    procedure ClearRoutineContext();
    function GetRoutineKind(): string;
    function GetRoutineReturnType(): string;
    
    // Method tracking
    function EmittedMethodsInHeader(): TDictionary<string, Boolean>;
    
    // Target type context for expression emission
    procedure SetTargetType(const AType: string);
    procedure ClearTargetType();
    function GetTargetType(): string;
    
    // Boolean context for expression emission
    procedure SetBooleanContext(const AValue: Boolean);
    function InBooleanContext(): Boolean;
    
    procedure PushWithContext(const AContext: string);
    procedure PopWithContext();
    function GetWithContext(): string;
    function IsInWithContext(): Boolean;
    
    // Current method node tracking for local variable lookup
    procedure SetCurrentMethodNode(const ANode: TSyntaxNode);
    procedure ClearCurrentMethodNode();
    function GetCurrentMethodNode(): TSyntaxNode;
    
    // Unit path management
    procedure AddUnitPath(const APath: string);
    procedure ClearUnitPaths();
    function GetUnitPaths(): TArray<string>;
    
    // Methods that delegate to emitter units
    procedure EmitUnit(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitInterface(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitImplementation(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitUses(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitExports(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    
    procedure EmitTypeSection(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitTypeDecl(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitType(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    
    procedure EmitVariables(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitVariable(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitConstants(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitConstant(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    
    procedure EmitMethod(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitMethodForwardDeclaration(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitParameters(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
    procedure EmitReturnType(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
    
    procedure EmitStatements(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitStatement(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitAssignment(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitCall(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitIf(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitWhile(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitFor(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitRepeat(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitCase(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitTry(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    procedure EmitWith(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
    
    procedure EmitExpression(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
    procedure EmitIdentifier(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
    procedure EmitLiteral(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
    procedure EmitBinaryOp(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
    procedure EmitUnaryOp(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
  end;

implementation

uses
  Blaise.CodeGen.Setup,
  Blaise.CodeGen.Generate,
  Blaise.CodeGen.Sections,
  Blaise.CodeGen.Types,
  Blaise.CodeGen.Variables,
  Blaise.CodeGen.Methods,
  Blaise.CodeGen.Statements,
  Blaise.CodeGen.Expressions;

{ TCodeGen }

constructor TCodeGen.Create();
begin
  inherited Create();
  
  FIndexer := nil;
  FMainUnitName := '';
  FMainSourceFilePath := '';
  FOutputPath := '';
  FErrors := nil;
  FCurrentUnit := '';
  FInInterfaceSection := False;
  FIsLibrary := False;
  FExportedFunctions := TStringList.Create();
  FLibraryInitCode := TStringBuilder.Create();
  FLibraryFiniCode := TStringBuilder.Create();
  FGeneratedFiles := nil;
  FRoutineKind := '';
  FRoutineReturnType := '';
  FTargetType := '';
  FInBooleanContext := False;
  FCurrentMethodNode := nil;
  
  FWithContextStack := TList<string>.Create();
  
  FUnitPaths := TStringList.Create();
  FUnitPaths.Duplicates := dupIgnore;
  
  FEmittedMethodsInHeader := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal());
  
  FRuntimeFunctions := TDictionary<string, Boolean>.Create(TIStringComparer.Ordinal());
  Blaise.CodeGen.Setup.SetupRuntimeFunctions(FRuntimeFunctions);

  FTypeMappings := TDictionary<string, string>.Create(TIStringComparer.Ordinal());
  Blaise.CodeGen.Setup.SetupTypeMappings(FTypeMappings);

  FOperatorMappings := TDictionary<TSyntaxNodeType, string>.Create();
  Blaise.CodeGen.Setup.SetupOperatorMappings(FOperatorMappings);

  AddUnitPath('.\res\libs\std');
end;

destructor TCodeGen.Destroy();
begin
  Clear();
  FExportedFunctions.Free();
  FLibraryInitCode.Free();
  FLibraryFiniCode.Free();
  FRuntimeFunctions.Free();
  FTypeMappings.Free();
  FOperatorMappings.Free();
  FEmittedMethodsInHeader.Free();
  FWithContextStack.Free();
  FUnitPaths.Free();
  
  inherited Destroy();
end;

procedure TCodeGen.Clear();
begin
  if Assigned(FIndexer) then
  begin
    FIndexer.Free();
    FIndexer := nil;
  end;
  
  FMainUnitName := '';
  FMainSourceFilePath := '';
  FOutputPath := '';
  FErrors := nil;
  FPreprocessor := nil;
  FCurrentUnit := '';
  FInInterfaceSection := False;
  FIsLibrary := False;
  FExportedFunctions.Clear();
  FLibraryInitCode.Clear();
  FLibraryFiniCode.Clear();
  FGeneratedFiles := nil;
  FRoutineKind := '';
  FRoutineReturnType := '';
  FEmittedMethodsInHeader.Clear();
  FTargetType := '';
  FInBooleanContext := False;
  FCurrentMethodNode := nil;
  if Assigned(FWithContextStack) then
    FWithContextStack.Clear();

  //if Assigned(FUnitPaths) then
  //  FUnitPaths.Clear();
end;

function TCodeGen.Process(const AFilename: string; const AOutputPath: string; const APreprocessor: TPreprocessor; const AErrors: TErrors): Boolean;
var
  LUnitInfo: TProjectIndexer.TUnitInfo;
begin
  Result := False;
  Clear();
  
  if not FileExists(AFilename) then
  begin
    AErrors.AddErrorSimple('File not found: %s', [AFilename]);
    Exit;
  end;
  
  FErrors := AErrors;
  FPreprocessor := APreprocessor;
  FMainSourceFilePath := AFilename;
  FIndexer := TProjectIndexer.Create();
  
  try
    if Assigned(FPreprocessor) then
      FPreprocessor.ProcessFile(AFilename, True);

    SetupSearchPaths();
    SetupDefines();

    FIndexer.Index(AFilename);

    if FIndexer.Problems.Count > 0 then
    begin
      ReportErrors(FIndexer, AErrors);
      Exit;
    end;

    if Assigned(FPreprocessor) then
    begin
      for LUnitInfo in GetParsedUnits() do
        FPreprocessor.ProcessFile(LUnitInfo.Path);
    end;
    
    FMainUnitName := ChangeFileExt(ExtractFileName(AFilename), '');
    
    if not Generate(AOutputPath) then
      Exit;
    
    Result := True;
    
  except
    on E: Exception do
    begin
      AErrors.AddErrorSimple('Code generation exception: %s', [E.Message]);
      Result := False;
    end;
  end;
end;

function TCodeGen.Generate(const AOutputPath: string): Boolean;
begin
  FOutputPath := AOutputPath;
  FGeneratedFiles := nil;
  Result := Blaise.CodeGen.Generate.Generate(Self, AOutputPath);
end;

procedure TCodeGen.GenerateUnit(const AUnitInfo: TProjectIndexer.TUnitInfo);
begin
  Blaise.CodeGen.Generate.GenerateUnit(Self, AUnitInfo);
end;

procedure TCodeGen.GenerateHeader(const AUnitInfo: TProjectIndexer.TUnitInfo; const AOutput: TStringBuilder);
begin
  Blaise.CodeGen.Generate.GenerateHeader(Self, AUnitInfo, AOutput);
end;

procedure TCodeGen.GenerateImplementation(const AUnitInfo: TProjectIndexer.TUnitInfo; const AOutput: TStringBuilder);
begin
  Blaise.CodeGen.Generate.GenerateImplementation(Self, AUnitInfo, AOutput);
end;

procedure TCodeGen.WalkNode(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
var
  LChild: TSyntaxNode;
begin
  if not Assigned(ANode) then
    Exit;
  
  case ANode.Typ of
    ntUnit: EmitUnit(ANode, AOutput, AIndent);
    ntInterface: EmitInterface(ANode, AOutput, AIndent);
    ntImplementation: EmitImplementation(ANode, AOutput, AIndent);
    ntInitialization: EmitStatements(ANode, AOutput, AIndent);
    ntFinalization: EmitStatements(ANode, AOutput, AIndent);
    ntUses: EmitUses(ANode, AOutput, AIndent);
    ntExports: EmitExports(ANode, AOutput, AIndent);
    
    ntTypeSection: EmitTypeSection(ANode, AOutput, AIndent);
    ntTypeDecl: EmitTypeDecl(ANode, AOutput, AIndent);
    ntType: EmitType(ANode, AOutput, AIndent);
    
    ntVariables: EmitVariables(ANode, AOutput, AIndent);
    ntVariable: EmitVariable(ANode, AOutput, AIndent);
    
    ntConstants: EmitConstants(ANode, AOutput, AIndent);
    ntConstant: EmitConstant(ANode, AOutput, AIndent);
    
    ntMethod: EmitMethod(ANode, AOutput, AIndent);
    
    ntStatements: EmitStatements(ANode, AOutput, AIndent);
    ntStatement: EmitStatement(ANode, AOutput, AIndent);
    ntAssign: EmitAssignment(ANode, AOutput, AIndent);
    ntCall: EmitCall(ANode, AOutput, AIndent);
    ntIf: EmitIf(ANode, AOutput, AIndent);
    ntWhile: EmitWhile(ANode, AOutput, AIndent);
    ntFor: EmitFor(ANode, AOutput, AIndent);
    ntRepeat: EmitRepeat(ANode, AOutput, AIndent);
    ntCase: EmitCase(ANode, AOutput, AIndent);
    ntTry: EmitTry(ANode, AOutput, AIndent);
    ntWith: EmitWith(ANode, AOutput, AIndent);
    
  else
    if ANode.HasChildren then
    begin
      LogUnimplemented(ANode.Typ, 'WalkNode');
      for LChild in ANode.ChildNodes do
        WalkNode(LChild, AOutput, AIndent);
    end;
  end;
end;

procedure TCodeGen.EmitUnit(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Sections.EmitUnit(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitInterface(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Sections.EmitInterface(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitImplementation(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Sections.EmitImplementation(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitUses(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Sections.EmitUses(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitExports(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Sections.EmitExports(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitTypeSection(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Types.EmitTypeSection(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitTypeDecl(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Types.EmitTypeDecl(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitType(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Types.EmitType(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitVariables(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Variables.EmitVariables(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitVariable(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Variables.EmitVariable(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitConstants(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Variables.EmitConstants(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitConstant(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Variables.EmitConstant(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitMethod(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Methods.EmitMethod(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitMethodForwardDeclaration(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Methods.EmitMethodForwardDeclaration(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitParameters(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
begin
  Blaise.CodeGen.Methods.EmitParameters(Self, ANode, AOutput);
end;

procedure TCodeGen.EmitReturnType(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
begin
  Blaise.CodeGen.Methods.EmitReturnType(Self, ANode, AOutput);
end;

procedure TCodeGen.EmitStatements(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitStatements(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitStatement(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitStatement(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitAssignment(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitAssignment(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitCall(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitCall(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitIf(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitIf(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitWhile(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitWhile(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitFor(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitFor(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitRepeat(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitRepeat(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitCase(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitCase(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitTry(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitTry(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitWith(const ANode: TSyntaxNode; const AOutput: TStringBuilder; const AIndent: Integer);
begin
  Blaise.CodeGen.Statements.EmitWith(Self, ANode, AOutput, AIndent);
end;

procedure TCodeGen.EmitExpression(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
begin
  Blaise.CodeGen.Expressions.EmitExpression(Self, ANode, AOutput);
end;

procedure TCodeGen.EmitIdentifier(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
begin
  Blaise.CodeGen.Expressions.EmitIdentifier(Self, ANode, AOutput);
end;

procedure TCodeGen.EmitLiteral(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
begin
  Blaise.CodeGen.Expressions.EmitLiteral(Self, ANode, AOutput);
end;

procedure TCodeGen.EmitBinaryOp(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
begin
  Blaise.CodeGen.Expressions.EmitBinaryOp(Self, ANode, AOutput);
end;

procedure TCodeGen.EmitUnaryOp(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
begin
  Blaise.CodeGen.Expressions.EmitUnaryOp(Self, ANode, AOutput);
end;

function TCodeGen.RuntimeFunctions(): TDictionary<string, Boolean>;
begin
  Result := FRuntimeFunctions;
end;

function TCodeGen.TypeMappings(): TDictionary<string, string>;
begin
  Result := FTypeMappings;
end;

function TCodeGen.InInterfaceSection(): Boolean;
begin
  Result := FInInterfaceSection;
end;

procedure TCodeGen.SetInInterfaceSection(const AValue: Boolean);
begin
  FInInterfaceSection := AValue;
end;

function TCodeGen.IsLibrary(): Boolean;
begin
  Result := FIsLibrary;
end;

procedure TCodeGen.SetIsLibrary(const AValue: Boolean);
begin
  FIsLibrary := AValue;
end;

function TCodeGen.ExportedFunctions(): TStringList;
begin
  Result := FExportedFunctions;
end;

function TCodeGen.CurrentUnit(): string;
begin
  Result := FCurrentUnit;
end;

procedure TCodeGen.SetCurrentUnit(const AValue: string);
begin
  FCurrentUnit := AValue;
end;

function TCodeGen.Errors(): TErrors;
begin
  Result := FErrors;
end;

function TCodeGen.Preprocessor(): TPreprocessor;
begin
  Result := FPreprocessor;
end;

function TCodeGen.GetOutputPath(): string;
begin
  Result := FOutputPath;
end;

procedure TCodeGen.SetOutputPath(const AValue: string);
begin
  FOutputPath := AValue;
end;

procedure TCodeGen.AddGeneratedFile(const AFilePath: string);
begin
  FGeneratedFiles := FGeneratedFiles + [AFilePath];
end;

function TCodeGen.GetIndexer(): TProjectIndexer;
begin
  Result := FIndexer;
end;

procedure TCodeGen.SetRoutineContext(const AKind: string; const AReturnType: string);
begin
  FRoutineKind := AKind;
  FRoutineReturnType := AReturnType;
end;

procedure TCodeGen.ClearRoutineContext();
begin
  FRoutineKind := '';
  FRoutineReturnType := '';
end;

function TCodeGen.GetRoutineKind(): string;
begin
  Result := FRoutineKind;
end;

function TCodeGen.GetRoutineReturnType(): string;
begin
  Result := FRoutineReturnType;
end;

function TCodeGen.EmittedMethodsInHeader(): TDictionary<string, Boolean>;
begin
  Result := FEmittedMethodsInHeader;
end;

procedure TCodeGen.EmitLineDirective(const ANode: TSyntaxNode; const AOutput: TStringBuilder);
var
  LFileName: string;
begin
  if ANode.Line > 0 then
  begin
    LFileName := ANode.FileName;
    if LFileName = '' then
      LFileName := FCurrentUnit + '.pas';
    
    AOutput.AppendFormat('#line %d "%s"', [ANode.Line, LFileName]);
    AOutput.AppendLine();
  end;
end;

function TCodeGen.GetIndent(const ALevel: Integer): string;
begin
  Result := StringOfChar(' ', ALevel * 4);
end;

function TCodeGen.MapType(const ATypeName: string): string;
begin
  if not FTypeMappings.TryGetValue(ATypeName, Result) then
    Result := ATypeName;
end;

function TCodeGen.MapOperator(const AOpType: TSyntaxNodeType): string;
begin
  if not FOperatorMappings.TryGetValue(AOpType, Result) then
    Result := '?';
end;

function TCodeGen.GetNodeName(const ANode: TSyntaxNode): string;
var
  LNameNode: TSyntaxNode;
begin
  Result := '';
  
  if not Assigned(ANode) then
    Exit;
  
  LNameNode := ANode.FindNode(ntName);
  if Assigned(LNameNode) then
    Result := GetNodeValue(LNameNode);
end;

function TCodeGen.GetNodeValue(const ANode: TSyntaxNode): string;
begin
  Result := '';
  
  if not Assigned(ANode) then
    Exit;
  
  if ANode is TValuedSyntaxNode then
    Result := TValuedSyntaxNode(ANode).Value;
end;

procedure TCodeGen.LogUnimplemented(const ANodeType: TSyntaxNodeType; const AContext: string);
begin
  if Assigned(FErrors) then
    FErrors.AddWarningSimple('Unimplemented node type in %s: %s', 
      [AContext, SyntaxNodeNames[ANodeType]]);
end;

function TCodeGen.GetRuntimeFunctionName(const APascalName: string): string;
var
  LKey: string;
begin
  Result := APascalName;
  
  if FRuntimeFunctions.ContainsKey(APascalName) then
  begin
    for LKey in FRuntimeFunctions.Keys do
    begin
      if SameText(LKey, APascalName) then
      begin
        Result := LKey;
        Break;
      end;
    end;
  end;
end;

function TCodeGen.GetGeneratedFiles(): TArray<string>;
begin
  Result := FGeneratedFiles;
end;

function TCodeGen.ParseLineColFromDescription(const ADescription: string; out ALine: Integer; out ACol: Integer): Boolean;
var
  LLinePos: Integer;
  LColPos: Integer;
  LColonPos: Integer;
  LLineStr: string;
  LColStr: string;
  LCommaPos: Integer;
begin
  Result := False;
  ALine := 0;
  ACol := 0;
  
  LLinePos := Pos('Line ', ADescription);
  if LLinePos = 0 then
    Exit;
    
  LColPos := Pos('Column ', ADescription);
  if LColPos = 0 then
    Exit;
    
  LCommaPos := Pos(',', ADescription);
  if LCommaPos = 0 then
    Exit;
    
  LLineStr := Copy(ADescription, LLinePos + 5, LCommaPos - (LLinePos + 5));
  LLineStr := Trim(LLineStr);
  
  LColonPos := Pos(':', ADescription);
  if LColonPos = 0 then
    Exit;
    
  LColStr := Copy(ADescription, LColPos + 7, LColonPos - (LColPos + 7));
  LColStr := Trim(LColStr);
  
  if not TryStrToInt(LLineStr, ALine) then
    Exit;
    
  if not TryStrToInt(LColStr, ACol) then
    Exit;
    
  Result := True;
end;

procedure TCodeGen.SetupDefines();
var
  LDefinesList: TStringList;
  LDefines: string;
  LTargetStr: string;
  LParts: TArray<string>;
  LArch: string;
  LOS: string;
  LOptimizationStr: string;
  LAppTypeStr: string;
begin
  if not Assigned(FIndexer) then
    Exit;
    
  if not Assigned(FPreprocessor) then
    Exit;
    
  LDefinesList := TStringList.Create();
  try
    // 1. Always add BLAISEPASCAL define
    LDefinesList.Add('BLAISEPASCAL');
    
    // 2. Add DEBUG or RELEASE based on optimization mode
    LOptimizationStr := FPreprocessor.GetOptimization();
    if SameText(LOptimizationStr, 'Debug') then
      LDefinesList.Add('DEBUG')
    else
      LDefinesList.Add('RELEASE');
    
    // 3. Add CONSOLE_APP or GUI_APP based on app type
    LAppTypeStr := FPreprocessor.GetAppType();
    if SameText(LAppTypeStr, 'CONSOLE') then
      LDefinesList.Add('CONSOLE_APP')
    else if SameText(LAppTypeStr, 'GUI') then
      LDefinesList.Add('GUI_APP');
    
    // 4. Parse target triplet for platform defines
    LTargetStr := FPreprocessor.GetTarget();
    if (not LTargetStr.IsEmpty) and (LTargetStr.ToLower <> 'native') then
    begin
      // Parse already-validated triplet: arch-os[-abi]
      LParts := LTargetStr.ToLower.Split(['-']);
      
      if Length(LParts) >= 2 then
      begin
        LArch := LParts[0];
        LOS := LParts[1];
        
        // Architecture defines
        if (LArch = 'x86_64') or (LArch = 'amd64') then
        begin
          LDefinesList.Add('CPUX64');
          if LOS.Contains('windows') then
            LDefinesList.Add('WIN64');
        end
        else if (LArch = 'i386') or (LArch = 'i686') then
        begin
          LDefinesList.Add('CPU386');
          if LOS.Contains('windows') then
            LDefinesList.Add('WIN32');
        end
        else if (LArch = 'aarch64') or LArch.Contains('arm64') then
        begin
          LDefinesList.Add('CPUARM64');
          LDefinesList.Add('ARM64');
        end;
        
        // OS defines
        if LOS.Contains('windows') then
        begin
          LDefinesList.Add('MSWINDOWS');
          LDefinesList.Add('WINDOWS');
        end
        else if LOS.Contains('linux') then
        begin
          LDefinesList.Add('LINUX');
          LDefinesList.Add('POSIX');
          LDefinesList.Add('UNIX');
        end
        else if LOS.Contains('darwin') or LOS.Contains('macos') then
        begin
          LDefinesList.Add('MACOS');
          LDefinesList.Add('DARWIN');
          LDefinesList.Add('POSIX');
          LDefinesList.Add('UNIX');
        end;
      end;
    end;
    
    // Convert list to semicolon-separated string for DelphiAST
    LDefines := string.Join(';', LDefinesList.ToStringArray());
    
    // Apply Defines to DelphiAST indexer
    FIndexer.Defines := LDefines;
    
  finally
    LDefinesList.Free();
  end;
end;

procedure TCodeGen.ReportErrors(const AIndexer: TProjectIndexer; const AErrors: TErrors);
var
  LProblem: TProjectIndexer.TProblemInfo;
  LNotFoundUnit: string;
  LLine: Integer;
  LCol: Integer;
  LMessage: string;
  LColonPos: Integer;
begin
  for LProblem in AIndexer.Problems do
  begin
    case LProblem.ProblemType of
      ptCantFindFile:
        AErrors.AddErrorSimple('Cannot find file: %s - %s', [LProblem.FileName, LProblem.Description]);
        
      ptCantOpenFile:
        AErrors.AddErrorSimple('Cannot open file: %s - %s', [LProblem.FileName, LProblem.Description]);
        
      ptCantParseFile:
        begin
          if ParseLineColFromDescription(LProblem.Description, LLine, LCol) then
          begin
            LColonPos := Pos(':', LProblem.Description);
            if LColonPos > 0 then
              LMessage := Trim(Copy(LProblem.Description, LColonPos + 1, Length(LProblem.Description)))
            else
              LMessage := LProblem.Description;
              
            AErrors.AddError(LProblem.FileName, LLine, LCol, '%s', [LMessage]);
          end
          else
          begin
            AErrors.AddError(LProblem.FileName, 0, 0, 'Parse error: %s', [LProblem.Description]);
          end;
        end;
        
    else
      AErrors.AddErrorSimple('Unknown problem: %s - %s', [LProblem.FileName, LProblem.Description]);
    end;
  end;
  
  for LNotFoundUnit in AIndexer.NotFoundUnits do
  begin
    AErrors.AddWarningSimple('Unit not found: %s', [LNotFoundUnit]);
  end;
end;

function TCodeGen.GetParsedUnits(): TProjectIndexer.TParsedUnits;
begin
  if Assigned(FIndexer) then
    Result := FIndexer.ParsedUnits
  else
    Result := nil;
end;

function TCodeGen.GetMainUnitName(): string;
begin
  Result := FMainUnitName;
end;

function TCodeGen.GetMainSourceFilePath(): string;
begin
  Result := FMainSourceFilePath;
end;

function TCodeGen.FindUnit(const AUnitName: string): TSyntaxNode;
var
  LUnitInfo: TProjectIndexer.TUnitInfo;
begin
  Result := nil;
  
  if not Assigned(FIndexer) then
    Exit;
  
  for LUnitInfo in FIndexer.ParsedUnits do
  begin
    if SameText(LUnitInfo.Name, AUnitName) then
    begin
      Result := LUnitInfo.SyntaxTree;
      Exit;
    end;
  end;
end;

function TCodeGen.HasRuntimeFunctionConflict(const AIdentifier: string): Boolean;
var
  LKey: string;
begin
  Result := False;
  
  if AIdentifier = '' then
    Exit;
  
  for LKey in FRuntimeFunctions.Keys do
  begin
    if SameText(LKey, AIdentifier) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TCodeGen.ResolveIdentifierName(const AIdentifier: string): string;
begin
  if HasRuntimeFunctionConflict(AIdentifier) then
    Result := AIdentifier + '_v'
  else
    Result := AIdentifier;
end;

function TCodeGen.GetVariableType(const AIdentifier: string): string;
var
  LUnitInfo: TProjectIndexer.TUnitInfo;
  
  function SearchVariablesInNode(const AParentNode: TSyntaxNode): string;
  var
    LVarsNode: TSyntaxNode;
    LVarNode: TSyntaxNode;
    LName: TSyntaxNode;
    LType: TSyntaxNode;
    LFoundName: string;
  begin
    Result := '';
    
    if not Assigned(AParentNode) then
      Exit;
    
    // Search for VARIABLES nodes
    for LVarsNode in AParentNode.ChildNodes do
    begin
      if LVarsNode.Typ = ntVariables then
      begin
        // Search each VARIABLE in this VARIABLES section
        for LVarNode in LVarsNode.ChildNodes do
        begin
          if LVarNode.Typ = ntVariable then
          begin
            LName := LVarNode.FindNode(ntName);
            LType := LVarNode.FindNode(ntType);
            
            if Assigned(LName) and Assigned(LType) then
            begin
              LFoundName := GetNodeValue(LName);
              if LFoundName = '' then
                LFoundName := LName.GetAttribute(anName);
              
              if SameText(LFoundName, AIdentifier) then
              begin
                Result := GetNodeName(LType);
                if Result = '' then
                  Result := LType.GetAttribute(anName);
                if Result = '' then
                  Result := LType.GetAttribute(anType);
                Exit;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  
begin
  Result := '';
  
  // Check for implicit Result variable (case-insensitive)
  if SameText(AIdentifier, 'Result') then
  begin
    Result := FRoutineReturnType;
    Exit;
  end;
  
  if not Assigned(FIndexer) then
    Exit;
  
  // Search in current unit first
  for LUnitInfo in FIndexer.ParsedUnits do
  begin
    if SameText(LUnitInfo.Name, FCurrentUnit) or 
       SameText(LUnitInfo.Name, FMainUnitName) then
    begin
      Result := SearchVariablesInNode(LUnitInfo.SyntaxTree);
      if Result <> '' then
        Exit;
    end;
  end;
  
  // If not found in current unit, search all units
  for LUnitInfo in FIndexer.ParsedUnits do
  begin
    Result := SearchVariablesInNode(LUnitInfo.SyntaxTree);
    if Result <> '' then
      Exit;
  end;
  
  // NEW: If still not found and we're inside a method, search local variables
  if (Result = '') and Assigned(FCurrentMethodNode) then
  begin
    Result := SearchVariablesInNode(FCurrentMethodNode);
  end;
end;

procedure TCodeGen.SetTargetType(const AType: string);
begin
  FTargetType := AType;
end;

procedure TCodeGen.ClearTargetType();
begin
  FTargetType := '';
end;

function TCodeGen.GetTargetType(): string;
begin
  Result := FTargetType;
end;

procedure TCodeGen.SetBooleanContext(const AValue: Boolean);
begin
  FInBooleanContext := AValue;
end;

function TCodeGen.InBooleanContext(): Boolean;
begin
  Result := FInBooleanContext;
end;

procedure TCodeGen.PushWithContext(const AContext: string);
begin
  FWithContextStack.Add(AContext);
end;

procedure TCodeGen.PopWithContext();
begin
  if FWithContextStack.Count > 0 then
    FWithContextStack.Delete(FWithContextStack.Count - 1);
end;

function TCodeGen.GetWithContext(): string;
begin
  if FWithContextStack.Count > 0 then
    Result := FWithContextStack[FWithContextStack.Count - 1]
  else
    Result := '';
end;

function TCodeGen.IsInWithContext(): Boolean;
begin
  Result := FWithContextStack.Count > 0;
end;

procedure TCodeGen.AddUnitPath(const APath: string);
begin
  if APath <> '' then
    FUnitPaths.Add(APath);
end;

procedure TCodeGen.ClearUnitPaths();
begin
  FUnitPaths.Clear();
end;

function TCodeGen.GetUnitPaths(): TArray<string>;
begin
  Result := FUnitPaths.ToStringArray();
end;

procedure TCodeGen.SetupSearchPaths();
var
  LPreprocessorPaths: TArray<string>;
  LAllPaths: TStringList;
  LPath: string;
  LSearchPath: string;
  LExeDir: string;
  LFullPath: string;
begin
  if not Assigned(FIndexer) then
    Exit;
    
  LAllPaths := TStringList.Create();
  try
    LAllPaths.Duplicates := dupIgnore;
    
    // Get the executable directory for relative path resolution
    LExeDir := TPath.GetDirectoryName(ParamStr(0));
    
    // Add programmatically-added paths first (convert to full paths)
    for LPath in FUnitPaths do
    begin
      // Make paths absolute relative to executable directory
      if not TPath.IsPathRooted(LPath) then
      begin
        LFullPath := TPath.GetFullPath(TPath.Combine(LExeDir, LPath));
        LAllPaths.Add(LFullPath);
      end
      else
        LAllPaths.Add(LPath);
    end;
    
    // Add preprocessor paths from {$UNIT_PATH} directives (convert to full paths)
    if Assigned(FPreprocessor) then
    begin
      LPreprocessorPaths := FPreprocessor.GetUnitPaths();
      for LPath in LPreprocessorPaths do
      begin
        // Make paths absolute relative to executable directory
        if not TPath.IsPathRooted(LPath) then
        begin
          LFullPath := TPath.GetFullPath(TPath.Combine(LExeDir, LPath));
          LAllPaths.Add(LFullPath);
        end
        else
          LAllPaths.Add(LPath);
      end;
    end;
    
    // Convert to semicolon-delimited string for DelphiAST
    if LAllPaths.Count > 0 then
    begin
      LSearchPath := string.Join(';', LAllPaths.ToStringArray());
      FIndexer.SearchPath := LSearchPath;
    end;
    
  finally
    LAllPaths.Free();
  end;
end;

procedure TCodeGen.SetCurrentMethodNode(const ANode: TSyntaxNode);
begin
  FCurrentMethodNode := ANode;
end;

procedure TCodeGen.ClearCurrentMethodNode();
begin
  FCurrentMethodNode := nil;
end;

function TCodeGen.GetCurrentMethodNode(): TSyntaxNode;
begin
  Result := FCurrentMethodNode;
end;

end.
