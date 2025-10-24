{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramExceptionAdvanced;

var
  LMessage: String;

begin
  WriteLn('=== Testing Advanced Exception Functions ===');
  WriteLn();
  
  { ============================================================================
    GetExceptionMessage
    ============================================================================ }
  
  WriteLn('--- GetExceptionMessage ---');
  
  { Test exception handling with message retrieval }
  try
    WriteLn('Raising exception with message: "Test error message"');
    RaiseException('Test error message');
  except
    WriteLn('Exception caught');
    LMessage := GetExceptionMessage();
    WriteLn('Exception message: "', LMessage, '"');
    WriteLn('Message retrieved successfully: ', Length(LMessage) > 0);
  end;
  
  WriteLn();
  
  { Test with different message }
  try
    WriteLn('Raising exception with message: "Another test error"');
    RaiseException('Another test error');
  except
    WriteLn('Exception caught');
    LMessage := GetExceptionMessage();
    WriteLn('Exception message: "', LMessage, '"');
    WriteLn('Message length: ', Length(LMessage));
  end;
  
  WriteLn();
  
  { Test with empty message }
  try
    WriteLn('Raising exception with empty message');
    RaiseException('');
  except
    WriteLn('Exception caught');
    LMessage := GetExceptionMessage();
    WriteLn('Exception message: "', LMessage, '"');
    WriteLn('Message is empty: ', Length(LMessage) = 0);
  end;
  
  WriteLn();
  
  { ============================================================================
    Summary
    ============================================================================ }
  
  WriteLn('--- Summary ---');
  WriteLn('GetExceptionMessage function:');
  WriteLn('  - Retrieves message from currently handled exception');
  WriteLn('  - Works within except block');
  WriteLn('  - Returns String containing exception message');
  WriteLn('  - Useful for logging and error reporting');
  
  WriteLn();
  WriteLn('✓ Advanced exception functions tested successfully');
end.
