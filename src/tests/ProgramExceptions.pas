{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramExceptions;

procedure TestProcedure;
begin
  WriteLn('  Inside TestProcedure');
  RaiseException('Error from TestProcedure');
  WriteLn('  This line should not be reached');
end;

var
  LS: String;

begin
  WriteLn('=== Testing Exception Handling ===');
  WriteLn();
  
  { ============================================================================
    TRY/EXCEPT
    ============================================================================ }
  
  WriteLn('--- Try/Except ---');
  
  { Simple exception handling }
  try
    WriteLn('Before exception');
    RaiseException('Simple test exception');
    WriteLn('After exception (should not print)');
  except
    LS := GetExceptionMessage();
    WriteLn('✓ Caught exception: "', LS, '"');
  end;
  
  WriteLn('Program continues after exception');
  WriteLn();
  
  { Exception from procedure }
  WriteLn('--- Exception from Procedure ---');
  
  try
    WriteLn('Calling TestProcedure...');
    TestProcedure();
    WriteLn('After TestProcedure (should not print)');
  except
    LS := GetExceptionMessage();
    WriteLn('✓ Caught exception from procedure: "', LS, '"');
  end;
  
  WriteLn('Program continues after procedure exception');
  WriteLn();
  
  { ============================================================================
    TRY/FINALLY
    ============================================================================ }
  
  WriteLn('--- Try/Finally ---');
  
  { Finally block always executes }
  try
    WriteLn('In try block');
    WriteLn('Executing code...');
  finally
    WriteLn('✓ Finally block executed');
  end;
  
  WriteLn('After try/finally');
  WriteLn();
  
  { ============================================================================
    NESTED EXCEPTION HANDLING
    ============================================================================ }
  
  WriteLn('--- Nested Exception Handling ---');
  
  { Outer exception handler }
  try
    WriteLn('Outer try block');
    
    { Inner exception handler }
    try
      WriteLn('  Inner try block');
      RaiseException('Inner exception');
      WriteLn('  After inner exception (should not print)');
    except
      LS := GetExceptionMessage();
      WriteLn('  ✓ Inner except: "', LS, '"');
    end;
    
    WriteLn('Between inner and outer');
    RaiseException('Outer exception');
    WriteLn('After outer exception (should not print)');
  except
    LS := GetExceptionMessage();
    WriteLn('✓ Outer except: "', LS, '"');
  end;
  
  WriteLn('Program continues after nested exceptions');
  WriteLn();
  WriteLn('✓ All exception handling tested successfully');
end.
