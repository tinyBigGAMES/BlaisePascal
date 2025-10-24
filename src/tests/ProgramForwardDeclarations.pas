{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramForwardDeclarations;

{ Forward declarations }
function Factorial(n: Integer): Integer; forward;
function IsEven(n: Integer): Boolean; forward;

{ Function that uses forward declared function }
function Fibonacci(n: Integer): Integer;
begin
  if n <= 1 then
    Result := n
  else
    Result := Fibonacci(n - 1) + Fibonacci(n - 2);
end;

{ Actual implementation of Factorial }
function Factorial(n: Integer): Integer;
begin
  if n <= 1 then
    Result := 1
  else
    Result := n * Factorial(n - 1);
end;

{ Function that uses IsEven (forward declared) }
function IsOdd(n: Integer): Boolean;
begin
  Result := not IsEven(n);
end;

{ Actual implementation of IsEven }
function IsEven(n: Integer): Boolean;
begin
  if n = 0 then
    Result := True
  else if n = 1 then
    Result := False
  else
    Result := IsEven(n - 2);
end;

{ Mutually recursive functions using forward declaration }
function CountDown(n: Integer): Integer; forward;

function CountUp(n: Integer): Integer;
begin
  WriteLn('  CountUp(', n, ')');
  if n >= 10 then
    Result := n
  else
    Result := CountDown(n + 2);
end;

function CountDown(n: Integer): Integer;
begin
  WriteLn('  CountDown(', n, ')');
  if n <= 0 then
    Result := 0
  else if n >= 10 then
    Result := CountUp(n - 3)
  else
    Result := n;
end;

var
  LI: Integer;
  LResult: Integer;
  LBool: Boolean;

begin
  WriteLn('=== Testing Forward Declarations ===');
  WriteLn();
  
  { ============================================================================
    SIMPLE FORWARD DECLARATION
    ============================================================================ }
  
  WriteLn('--- Simple Forward Declaration ---');
  
  { Test Factorial }
  WriteLn('Factorial tests:');
  for LI := 0 to 5 do
  begin
    LResult := Factorial(LI);
    WriteLn('  Factorial(', LI, ') = ', LResult);
  end;
  
  WriteLn();
  
  { ============================================================================
    MUTUAL RECURSION
    ============================================================================ }
  
  WriteLn('--- Mutual Recursion (IsEven/IsOdd) ---');
  
  { Test IsEven and IsOdd }
  WriteLn('IsEven/IsOdd tests:');
  for LI := 0 to 5 do
  begin
    LBool := IsEven(LI);
    if LBool then
      WriteLn('  ', LI, ' is even')
    else
      WriteLn('  ', LI, ' is odd');
  end;
  
  WriteLn();
  
  { Test IsOdd directly }
  WriteLn('IsOdd direct tests:');
  for LI := 0 to 5 do
  begin
    LBool := IsOdd(LI);
    if LBool then
      WriteLn('  ', LI, ' is odd (IsOdd)')
    else
      WriteLn('  ', LI, ' is even (IsOdd)');
  end;
  
  WriteLn();
  
  { ============================================================================
    COMPLEX MUTUAL RECURSION
    ============================================================================ }
  
  WriteLn('--- Complex Mutual Recursion (CountUp/CountDown) ---');
  
  { Test CountUp/CountDown }
  LResult := CountUp(0);
  WriteLn('CountUp(0) = ', LResult);
  
  LResult := CountDown(10);
  WriteLn('CountDown(10) = ', LResult);
  
  WriteLn();
  
  { ============================================================================
    FIBONACCI (USES FORWARD DECLARED FUNCTION)
    ============================================================================ }
  
  WriteLn('--- Fibonacci (uses Factorial concept) ---');
  
  { Test Fibonacci }
  WriteLn('Fibonacci sequence:');
  for LI := 0 to 10 do
  begin
    LResult := Fibonacci(LI);
    WriteLn('  Fibonacci(', LI, ') = ', LResult);
  end;
  
  WriteLn();
  WriteLn('✓ All forward declarations tested successfully');
end.
