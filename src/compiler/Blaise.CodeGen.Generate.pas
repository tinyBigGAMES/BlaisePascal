{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.CodeGen.Generate;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Consts,
  DelphiAST.ProjectIndexer,
  Blaise.Utils,
  Blaise.CodeGen;


function  Generate(const ACodeGen: TCodeGen; const AOutputPath: string): Boolean;
procedure GenerateUnit(const ACodeGen: TCodeGen; const AUnitInfo: TProjectIndexer.TUnitInfo);
procedure GenerateHeader(const ACodeGen: TCodeGen; const AUnitInfo: TProjectIndexer.TUnitInfo; const AOutput: TStringBuilder);
procedure GenerateImplementation(const ACodeGen: TCodeGen; const AUnitInfo: TProjectIndexer.TUnitInfo; const AOutput: TStringBuilder);

implementation


function Generate(const ACodeGen: TCodeGen; const AOutputPath: string): Boolean;
var
  LUnitInfo: TProjectIndexer.TUnitInfo;
begin
  Result := False;
  
  if not Assigned(ACodeGen.GetIndexer()) then
  begin
    if Assigned(ACodeGen.Errors()) then
      ACodeGen.Errors().AddErrorSimple('No parsed units available.', []);
    Exit;
  end;
  
  // Ensure output directory exists
  if not TUtils.CreateDirInPath(AOutputPath) then
  begin
    if Assigned(ACodeGen.Errors()) then
      ACodeGen.Errors().AddErrorSimple('Failed to create output directory: %s', [AOutputPath]);
    Exit;
  end;
  
  try
    // Generate .h and .cpp for each parsed unit
    for LUnitInfo in ACodeGen.GetIndexer().ParsedUnits do
    begin
      ACodeGen.SetCurrentUnit(LUnitInfo.Name);
      GenerateUnit(ACodeGen, LUnitInfo);
    end;
    
    Result := True;
    
  except
    on E: Exception do
    begin
      if Assigned(ACodeGen.Errors()) then
        ACodeGen.Errors().AddErrorSimple('Code generation exception: %s', [E.Message]);
      Result := False;
    end;
  end;
end;

procedure GenerateUnit(const ACodeGen: TCodeGen; const AUnitInfo: TProjectIndexer.TUnitInfo);
var
  LHeaderPath: string;
  LImplPath: string;
  LHeaderOutput: TStringBuilder;
  LImplOutput: TStringBuilder;
  LOutputPath: string;
begin
  // Get output path from CodeGen
  LOutputPath := ACodeGen.GetOutputPath();
  
  // Ensure unit directory exists
  TUtils.CreateDirInPath(LOutputPath);
  
  // Construct output file paths
  LHeaderPath := TPath.Combine(LOutputPath, AUnitInfo.Name + '.h');
  LImplPath := TPath.Combine(LOutputPath, AUnitInfo.Name + '.cpp');
  
  // Generate header file
  LHeaderOutput := TStringBuilder.Create();
  try
    GenerateHeader(ACodeGen, AUnitInfo, LHeaderOutput);
    TFile.WriteAllText(LHeaderPath, LHeaderOutput.ToString(), TEncoding.UTF8);
    ACodeGen.AddGeneratedFile(LHeaderPath);
  finally
    FreeAndNil(LHeaderOutput);
  end;
  
  // Generate implementation file
  LImplOutput := TStringBuilder.Create();
  try
    GenerateImplementation(ACodeGen, AUnitInfo, LImplOutput);
    TFile.WriteAllText(LImplPath, LImplOutput.ToString(), TEncoding.UTF8);
    ACodeGen.AddGeneratedFile(LImplPath);
  finally
    FreeAndNil(LImplOutput);
  end;
end;

procedure GenerateHeader(const ACodeGen: TCodeGen; const AUnitInfo: TProjectIndexer.TUnitInfo; const AOutput: TStringBuilder);
var
  LGuard: string;
  LChild: TSyntaxNode;
begin
  // FIX #1B: Clear method tracking for this unit
  ACodeGen.EmittedMethodsInHeader().Clear();
  
  // Detect if this is a library before generating output
  // Libraries have ntExports nodes; units do not
  if Assigned(AUnitInfo.SyntaxTree) then
  begin
    ACodeGen.SetIsLibrary(False);
    
    // Pre-scan to collect exports and detect library
    for LChild in AUnitInfo.SyntaxTree.ChildNodes do
    begin
      if LChild.Typ = ntExports then
      begin
        ACodeGen.SetIsLibrary(True);
        ACodeGen.EmitExports(LChild, AOutput, 0);
      end;
    end;
  end;
  
  // Generate header guard
  LGuard := UpperCase(AUnitInfo.Name) + '_H';
  
  AOutput.AppendLine('// Generated from: ' + AUnitInfo.Name);
  AOutput.AppendLine('#pragma once');
  AOutput.AppendLine();
  AOutput.AppendLine('#ifndef ' + LGuard);
  AOutput.AppendLine('#define ' + LGuard);
  AOutput.AppendLine();
  
  // Emit user-specified headers from {$INCLUDE_HEADER} directives
  if Assigned(ACodeGen.Preprocessor()) then
  begin
    var LHeaders := ACodeGen.Preprocessor().GetIncludeHeaders();
    if Length(LHeaders) > 0 then
    begin
      AOutput.AppendLine('// User-specified headers');
      for var LHeader in LHeaders do
      begin
        // Determine if it's a system header (<>) or local header ("")
        if (LHeader.StartsWith('<') and LHeader.EndsWith('>')) then
          AOutput.AppendLine('#include ' + LHeader)
        else if (LHeader.StartsWith('"') and LHeader.EndsWith('"')) then
          AOutput.AppendLine('#include ' + LHeader)
        else
          // Default to local header with quotes
          AOutput.AppendLine('#include "' + LHeader + '"');
      end;
      AOutput.AppendLine();
    end;
  end;
  
  AOutput.AppendLine('#include <runtime.h>');
  AOutput.AppendLine('#include <array>');
  AOutput.AppendLine();
  
  // Add export macro for libraries BEFORE walking interface
  if ACodeGen.IsLibrary() then
  begin
    var LExportABI: string;
    
    // Get export ABI setting from preprocessor (default is 'CPP')
    if Assigned(ACodeGen.Preprocessor()) then
      LExportABI := ACodeGen.Preprocessor().GetExportABI()
    else
      LExportABI := 'CPP';
    
    AOutput.AppendLine('// DLL Export macro');
    
    if SameText(LExportABI, 'CPP') then
    begin
      // C++ ABI: Export with name mangling
      AOutput.AppendLine('#ifdef _WIN32');
      AOutput.AppendLine('    #define BP_EXPORT __declspec(dllexport)');
      AOutput.AppendLine('#else');
      AOutput.AppendLine('    #define BP_EXPORT __attribute__((visibility("default")))');
      AOutput.AppendLine('#endif');
    end
    else
    begin
      // C ABI: Export with extern "C" (default, maximum compatibility)
      AOutput.AppendLine('#ifdef _WIN32');
      AOutput.AppendLine('    #define BP_EXPORT extern "C" __declspec(dllexport)');
      AOutput.AppendLine('#else');
      AOutput.AppendLine('    #define BP_EXPORT extern "C" __attribute__((visibility("default")))');
      AOutput.AppendLine('#endif');
    end;
    
    AOutput.AppendLine();
  end;
  
  ACodeGen.SetInInterfaceSection(True);
  
  if Assigned(AUnitInfo.SyntaxTree) then
  begin
    for LChild in AUnitInfo.SyntaxTree.ChildNodes do
    begin
      // For units: process interface section
      if LChild.Typ = ntInterface then
      begin
        ACodeGen.WalkNode(LChild, AOutput, 0);
      end;
      // For programs/libraries: nothing gets emitted in header
      // All declarations and definitions go in .cpp only
    end;
  end;
  
  AOutput.AppendLine();
  AOutput.AppendLine('#endif // ' + LGuard);
end;

procedure GenerateImplementation(const ACodeGen: TCodeGen; const AUnitInfo: TProjectIndexer.TUnitInfo; const AOutput: TStringBuilder);
var
  LChild: TSyntaxNode;
  LHasStatements: Boolean;
  LInitStatements: TSyntaxNode;
  LFiniStatements: TSyntaxNode;
  LLibraryInitCode: TStringBuilder;
  LLibraryFiniCode: TStringBuilder;
begin
  AOutput.AppendLine('// Generated from: ' + AUnitInfo.Name);
  AOutput.AppendLine('#include "' + AUnitInfo.Name + '.h"');
  AOutput.AppendLine();
  
  // Add include directives for external library headers
  // For units with external functions, include the C library headers
  if Assigned(ACodeGen.Preprocessor()) then
  begin
    var LHeaders := ACodeGen.Preprocessor().GetIncludeHeaders();
    if Length(LHeaders) > 0 then
    begin
      for var LHeader in LHeaders do
      begin
        // Determine if it's a system header (<>) or local header ("")
        if (LHeader.StartsWith('<') and LHeader.EndsWith('>')) then
          AOutput.AppendLine('#include ' + LHeader)
        else if (LHeader.StartsWith('"') and LHeader.EndsWith('"')) then
          AOutput.AppendLine('#include ' + LHeader)
        else
          // Default to angle brackets for library headers
          AOutput.AppendLine('#include <' + LHeader + '>');
      end;
      AOutput.AppendLine();
    end;
  end;
  
  ACodeGen.SetInInterfaceSection(False);
  
  // For libraries, collect initialization and finalization code
  if ACodeGen.IsLibrary() and Assigned(AUnitInfo.SyntaxTree) then
  begin
    LLibraryInitCode := TStringBuilder.Create();
    LLibraryFiniCode := TStringBuilder.Create();
    try
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        // Library begin..end block (initialization)
        if LChild.Typ = ntStatements then
        begin
          LInitStatements := LChild;
          if Assigned(LInitStatements) and LInitStatements.HasChildren then
            ACodeGen.EmitStatements(LInitStatements, LLibraryInitCode, 1);
        end;
        // Finalization section
        if LChild.Typ = ntFinalization then
        begin
          LFiniStatements := LChild;
          if Assigned(LFiniStatements) and LFiniStatements.HasChildren then
            ACodeGen.EmitStatements(LFiniStatements, LLibraryFiniCode, 1);
        end;
      end;
      
      // Process non-interface nodes
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ <> ntInterface then
        begin
          // For libraries, skip forward declarations (methods without bodies)
          if ACodeGen.IsLibrary() and (LChild.Typ = ntMethod) and not Assigned(LChild.FindNode(ntStatements)) then
            Continue;
          
          // For libraries, skip statements and finalization (handled by init/fini functions)
          if ACodeGen.IsLibrary() and ((LChild.Typ = ntStatements) or (LChild.Typ = ntFinalization)) then
            Continue;
          
          ACodeGen.WalkNode(LChild, AOutput, 0);
        end;
      end;
      
      // Add library initialization/finalization and DllMain
      AOutput.AppendLine();
      AOutput.AppendLine('// Library initialization function');
      AOutput.AppendLine('static void library_init() {');
      if LLibraryInitCode.Length > 0 then
        AOutput.Append(LLibraryInitCode.ToString());
      AOutput.AppendLine('}');
      AOutput.AppendLine();
      
      AOutput.AppendLine('// Library finalization function');
      AOutput.AppendLine('static void library_fini() {');
      if LLibraryFiniCode.Length > 0 then
        AOutput.Append(LLibraryFiniCode.ToString());
      AOutput.AppendLine('}');
      AOutput.AppendLine();
      
      // Windows DllMain
      AOutput.AppendLine('#ifdef _WIN32');
      AOutput.AppendLine('#include <windows.h>');
      AOutput.AppendLine();
      AOutput.AppendLine('BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) {');
      AOutput.AppendLine('    switch (fdwReason) {');
      AOutput.AppendLine('        case DLL_PROCESS_ATTACH:');
      AOutput.AppendLine('            library_init();');
      AOutput.AppendLine('            break;');
      AOutput.AppendLine('        case DLL_PROCESS_DETACH:');
      AOutput.AppendLine('            library_fini();');
      AOutput.AppendLine('            break;');
      AOutput.AppendLine('    }');
      AOutput.AppendLine('    return TRUE;');
      AOutput.AppendLine('}');
      
      // POSIX constructor/destructor
      AOutput.AppendLine('#else');
      AOutput.AppendLine();
      AOutput.AppendLine('__attribute__((constructor))');
      AOutput.AppendLine('static void library_load() {');
      AOutput.AppendLine('    library_init();');
      AOutput.AppendLine('}');
      AOutput.AppendLine();
      AOutput.AppendLine('__attribute__((destructor))');
      AOutput.AppendLine('static void library_unload() {');
      AOutput.AppendLine('    library_fini();');
      AOutput.AppendLine('}');
      AOutput.AppendLine();
      AOutput.AppendLine('#endif');
    finally
      LLibraryInitCode.Free();
      LLibraryFiniCode.Free();
    end;
    Exit;
  end;
  
  if Assigned(AUnitInfo.SyntaxTree) then
  begin
    // Check if this is a program (has direct statements in UNIT node)
    // BUT: Libraries are never programs, even if they have begin..end blocks
    LHasStatements := False;
    if not ACodeGen.IsLibrary() then
    begin
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ = ntStatements then
        begin
          LHasStatements := True;
          Break;
        end;
      end;
    end;
    
    // If it's a program, wrap in main()
    if LHasStatements then
    begin
      // First pass: emit USES (includes) at file scope
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ = ntUses then
          ACodeGen.WalkNode(LChild, AOutput, 0);
      end;
      
      AOutput.AppendLine();
      
      // Second pass: emit TYPE SECTIONS
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ = ntTypeSection then
          ACodeGen.WalkNode(LChild, AOutput, 0);
      end;
      
      AOutput.AppendLine();
      
      // Third pass: emit constant definitions
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ = ntConstants then
          ACodeGen.WalkNode(LChild, AOutput, 0);
      end;
      
      AOutput.AppendLine();
      
      // Fourth pass: emit variable definitions (not declarations)
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ = ntVariables then
          ACodeGen.WalkNode(LChild, AOutput, 0);
      end;
      
      AOutput.AppendLine();
      
      // Fifth pass: emit forward declarations for all methods/functions
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ = ntMethod then
        begin
          // Only emit forward declaration if the method has a body
          if Assigned(LChild.FindNode(ntStatements)) then
            ACodeGen.EmitMethodForwardDeclaration(LChild, AOutput, 0);
        end;
      end;
      
      AOutput.AppendLine();
      
      // Sixth pass: emit all method implementations BEFORE main()
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ = ntMethod then
          ACodeGen.WalkNode(LChild, AOutput, 0);
      end;
      
      AOutput.AppendLine('int main(int argc, char* argv[]) {');
      AOutput.AppendLine('    bp::internal::InitializeConsole();');
      AOutput.AppendLine('    bp::internal::SetCommandLine(argc, argv);');
      
      // Seventh pass: emit only the program statements inside main()
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ = ntStatements then
          ACodeGen.WalkNode(LChild, AOutput, 1);
      end;
      
      AOutput.AppendLine('    return 0;');
      AOutput.AppendLine('}');
    end
    else
    begin
      // It's a unit or library - process normally
      for LChild in AUnitInfo.SyntaxTree.ChildNodes do
      begin
        if LChild.Typ <> ntInterface then
        begin
          ACodeGen.WalkNode(LChild, AOutput, 0);
        end;
      end;
    end;
  end;
end;

end.
