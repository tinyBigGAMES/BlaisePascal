{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit UTester;

interface

procedure RunTests();

implementation

uses
  System.SysUtils,
  Blaise.Utils,
  Blaise.Tester;

procedure RunTests();
var
  LTester: TTester;
begin
  LTester := TTester.Create();
  try
    // Configure paths
    LTester.SetProjectFolder('.\output');
    LTester.SetTestSourceFolder('..\src\tests');

    // Configure display options
    LTester.SetShowPascal(True);
    LTester.SetShowXML(True);
    LTester.SetShowCPP(True);
    
    // ========================================
    // BASICS - Fundamental language features
    // ========================================
    LTester.AddTest(01, 'ProgramSimple.pas', 0, True, True, False);
    LTester.AddTest(02, 'ProgramVariables.pas', 0, True, True, False);
    LTester.AddTest(03, 'ProgramBasicTypes.pas', 0, True, True, False);
    LTester.AddTest(04, 'ProgramTypes.pas', 0, True, True, False);
    LTester.AddTest(05, 'ProgramWriteWriteLn.pas', 0, True, True, False);
    
    // ========================================
    // CONTROL FLOW - Flow control constructs
    // ========================================
    LTester.AddTest(10, 'ProgramControlFlow.pas', 0, True, True, False);
    LTester.AddTest(11, 'ProgramBreakContinueExit.pas', 0, True, True, False);
    LTester.AddTest(12, 'ProgramCaseAndOperators.pas', 0, True, True, False);
    LTester.AddTest(13, 'ProgramConstantsAndRepeat.pas', 0, True, True, False);
    
    // ========================================
    // OPERATORS - Operator tests
    // ========================================
    LTester.AddTest(15, 'ProgramAllOperators.pas', 0, True, True, False);
    
    // ========================================
    // FUNCTIONS - Routines and parameters
    // ========================================
    LTester.AddTest(20, 'ProgramFunctions.pas', 0, True, True, False);
    LTester.AddTest(21, 'ProgramForwardDeclarations.pas', 0, True, True, False);
    LTester.AddTest(22, 'ProgramParameterPassing.pas', 0, True, True, False);
    
    // ========================================
    // ARRAYS - Array operations
    // ========================================
    LTester.AddTest(25, 'ProgramArrays.pas', 0, True, True, False);
    LTester.AddTest(26, 'ProgramArrayCopy.pas', 0, True, True, False);
    LTester.AddTest(27, 'ProgramArraySet.pas', 0, True, True, False);
    LTester.AddTest(28, 'ProgramMultiDimArrays.pas', 0, True, True, False);
    LTester.AddTest(29, 'ProgramDynamicArrayAdvanced.pas', 0, True, True, False);
    
    // ========================================
    // STRINGS - String manipulation
    // ========================================
    LTester.AddTest(30, 'ProgramStringOperations.pas', 0, True, True, False);
    LTester.AddTest(31, 'ProgramStringFunctions.pas', 0, True, True, False);
    LTester.AddTest(32, 'ProgramStringAdvanced.pas', 0, True, True, False);
    LTester.AddTest(33, 'ProgramStringsAndWith.pas', 0, True, True, False);
    LTester.AddTest(34, 'ProgramWideString.pas', 0, True, True, False);
    
    // ========================================
    // RECORDS - Record types
    // ========================================
    LTester.AddTest(35, 'ProgramNestedRecords.pas', 0, True, True, False);
    
    // ========================================
    // ENUMERATIONS - Enum and ordinal types
    // ========================================
    LTester.AddTest(40, 'ProgramEnumerations.pas', 0, True, True, False);
    LTester.AddTest(41, 'ProgramOrdinalAdvanced.pas', 0, True, True, False);
    
    // ========================================
    // POINTERS & MEMORY - Pointer operations
    // ========================================
    LTester.AddTest(45, 'ProgramPointerOperations.pas', 0, True, True, False);
    LTester.AddTest(46, 'ProgramMemoryAdvanced.pas', 0, True, True, False);
    LTester.AddTest(47, 'ProgramSizeOf.pas', 0, True, True, False);
    
    // ========================================
    // MATH - Mathematical operations
    // ========================================
    LTester.AddTest(50, 'ProgramMathFunctions.pas', 0, True, True, False);
    LTester.AddTest(51, 'ProgramMathAdvanced.pas', 0, True, True, False);
    
    // ========================================
    // FILE I/O - File operations
    // ========================================
    LTester.AddTest(55, 'ProgramFileIO.pas', 0, True, True, False);
    LTester.AddTest(56, 'ProgramFileIOAdvanced.pas', 0, True, True, False);
    LTester.AddTest(57, 'ProgramBinaryFileIO.pas', 0, True, True, False);
    LTester.AddTest(58, 'ProgramFileSystem.pas', 0, True, True, False);
    
    // ========================================
    // EXCEPTIONS - Exception handling
    // ========================================
    LTester.AddTest(60, 'ProgramExceptions.pas', 0, True, True, False);
    LTester.AddTest(61, 'ProgramExceptionAdvanced.pas', 0, True, True, False);
    
    // ========================================
    // RUNTIME & SYSTEM - System features
    // ========================================
    LTester.AddTest(65, 'ProgramRuntimeIntrinsics.pas', 0, True, True, False);
    LTester.AddTest(66, 'ProgramCommandLine.pas', 0, True, True, False);
    LTester.AddTest(67, 'ProgramFormat.pas', 0, True, True, False);
    LTester.AddTest(68, 'ProgramMessageBox.pas', 0, True, True, False);
    
    // ========================================
    // PROGRAM TERMINATION - Exit codes
    // ========================================
    LTester.AddTest(70, 'ProgramTestAbort.pas', 3, True, True, False);
    LTester.AddTest(71, 'ProgramTestHalt.pas', 7, True, True, False);
    LTester.AddTest(72, 'ProgramTestRunError.pas', 42, True, True, False);
    
    // ========================================
    // TYPE SYSTEM - Advanced type features
    // ========================================
    LTester.AddTest(75, 'ProgramTypeAliases.pas', 0, True, True, False);
    LTester.AddTest(76, 'ProgramTypedConstants.pas', 0, True, True, False);
    
    // ========================================
    // COMPILER - Compiler directives
    // ========================================
    LTester.AddTest(80, 'ProgramCompilerDirectives.pas', 0, True, True, False);
    LTester.AddTest(81, 'DirectiveTest.pas', 0, True, True, False);
    
    // ========================================
    // UNITS - Unit usage
    // ========================================
    LTester.AddTest(85, 'ProgramUsesUnit.pas', 0, True, True, False);
    LTester.AddTest(86, 'ProgramUsesUnitTypes.pas', 0, True, True, False);
    LTester.AddTest(87, 'UnitSimple.pas', 0, True, True, False);
    LTester.AddTest(88, 'UnitWithTypes.pas', 0, True, True, False);
    
    // ========================================
    // LIBRARIES - Library projects
    // ========================================
    LTester.AddTest(90, 'LibrarySimple.pas', 0, True, True, False);
    LTester.AddTest(91, 'LibraryForward.pas', 0, True, True, False);
    LTester.AddTest(92, 'LibraryWithExports.pas', 0, True, True, False);
    
    // ========================================
    // COMPLETE - Complete test program
    // ========================================
    LTester.AddTest(95, 'ProgramComplete.pas', 0, True, True, False);


    // ========================================
    // TESTBED - Development testbed
    // ========================================
    LTester.AddTest(999, 'ProgramTestbed.pas', 0, True, True, False);


    // ========================================
    // BPBench - Micro Test Bench
    // ========================================
    LTester.SetTestSourceFolder('.\projects\BPBench\src');
    LTester.AddTest(1000, 'BPBench.pas', 0, True, True, False);

    // ========================================
    // RAYLIB - Examples
    // ========================================
    LTester.SetTestSourceFolder('.\projects\raylib\core_basic_window\src');
    LTester.AddTest(2000, 'core_basic_window.pas', 0, True, True, False);


    {$IFDEF RELEASE}
    // Run tester CLI
    LTester.Run();
    {$ELSE}
    // Run a specific test
    //LTester.RunTest(999);
    LTester.RunTest(1000);
    //LTester.RunTest(96);
    TUtils.Pause();
    {$ENDIF}

  finally
    LTester.Free();
  end;
end;

end.
