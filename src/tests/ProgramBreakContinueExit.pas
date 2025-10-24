{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramBreakContinueExit;

var
  GResult: Integer;
  GMessage: String;

{------------------------------------------------------------------------------}
{ BREAK TESTS }
{------------------------------------------------------------------------------}

procedure TestBreakInForTo;
var
  LI: Integer;
  LSum: Integer;
begin
  WriteLn('--- TestBreakInForTo ---');
  LSum := 0;
  
  for LI := 1 to 10 do
  begin
    if LI > 5 then
      break;
    LSum := LSum + LI;
  end;
  
  WriteLn('Sum 1..5 (break at 6): ', LSum);  // Should be 15
  WriteLn('Final LI: ', LI);  // Should be 6
end;

procedure TestBreakInForDownto;
var
  LI: Integer;
  LCount: Integer;
begin
  WriteLn('--- TestBreakInForDownto ---');
  LCount := 0;
  
  for LI := 10 downto 1 do
  begin
    LCount := LCount + 1;
    if LI < 5 then
      break;
  end;
  
  WriteLn('Count before break: ', LCount);  // Should be 7 (10,9,8,7,6,5,4)
  WriteLn('Final LI: ', LI);  // Should be 4
end;

procedure TestBreakInWhile;
var
  LX: Integer;
  LSum: Integer;
begin
  WriteLn('--- TestBreakInWhile ---');
  LX := 0;
  LSum := 0;
  
  while LX < 100 do
  begin
    LX := LX + 1;
    LSum := LSum + LX;
    if LSum > 50 then
      break;
  end;
  
  WriteLn('Sum when > 50: ', LSum);  // Should be 55
  WriteLn('Final LX: ', LX);  // Should be 10
end;

procedure TestBreakInRepeat;
var
  LN: Integer;
begin
  WriteLn('--- TestBreakInRepeat ---');
  LN := 0;
  
  repeat
    LN := LN + 1;
    WriteLn('  Iteration: ', LN);
    if LN = 3 then
      break;
  until LN >= 10;
  
  WriteLn('Final LN (should be 3): ', LN);
end;

procedure TestBreakInNestedIf;
var
  LI: Integer;
  LFound: Integer;
begin
  WriteLn('--- TestBreakInNestedIf ---');
  LFound := 0;
  
  for LI := 1 to 20 do
  begin
    if LI > 10 then
    begin
      if LI = 15 then
      begin
        LFound := LI;
        break;
      end;
    end;
  end;
  
  WriteLn('Found value: ', LFound);  // Should be 15
end;

{------------------------------------------------------------------------------}
{ CONTINUE TESTS }
{------------------------------------------------------------------------------}

procedure TestContinueInForTo;
var
  LI: Integer;
  LSum: Integer;
begin
  WriteLn('--- TestContinueInForTo ---');
  LSum := 0;
  
  // Sum only odd numbers from 1 to 10
  for LI := 1 to 10 do
  begin
    if LI mod 2 = 0 then
      continue;
    LSum := LSum + LI;
  end;
  
  WriteLn('Sum of odd 1..10: ', LSum);  // Should be 25 (1+3+5+7+9)
end;

procedure TestContinueInForDownto;
var
  LI: Integer;
  LCount: Integer;
begin
  WriteLn('--- TestContinueInForDownto ---');
  LCount := 0;
  
  // Count numbers from 10 to 1, skip multiples of 3
  for LI := 10 downto 1 do
  begin
    if LI mod 3 = 0 then
      continue;
    LCount := LCount + 1;
  end;
  
  WriteLn('Count (excluding multiples of 3): ', LCount);  // Should be 7
end;

procedure TestContinueInWhile;
var
  LX: Integer;
  LSum: Integer;
begin
  WriteLn('--- TestContinueInWhile ---');
  LX := 0;
  LSum := 0;
  
  // Sum numbers 1 to 10, skip 5
  while LX < 10 do
  begin
    LX := LX + 1;
    if LX = 5 then
      continue;
    LSum := LSum + LX;
  end;
  
  WriteLn('Sum 1..10 (skip 5): ', LSum);  // Should be 50 (55-5)
end;

procedure TestContinueInRepeat;
var
  LN: Integer;
  LCount: Integer;
begin
  WriteLn('--- TestContinueInRepeat ---');
  LN := 0;
  LCount := 0;
  
  repeat
    LN := LN + 1;
    if LN mod 2 = 1 then
      continue;
    LCount := LCount + 1;
  until LN >= 10;
  
  WriteLn('Count of even numbers: ', LCount);  // Should be 5
end;

{------------------------------------------------------------------------------}
{ EXIT TESTS }
{------------------------------------------------------------------------------}

procedure TestExitInProcedure;
var
  LX: Integer;
begin
  WriteLn('--- TestExitInProcedure ---');
  
  for LX := 1 to 10 do
  begin
    WriteLn('  Processing: ', LX);
    if LX = 3 then
    begin
      WriteLn('  Early exit at 3');
      exit;
    end;
  end;
  
  WriteLn('  This should not print');
end;

function TestExitInFunction: Integer;
var
  LI: Integer;
begin
  WriteLn('--- TestExitInFunction ---');
  Result := 0;
  
  for LI := 1 to 10 do
  begin
    Result := Result + LI;
    if Result > 20 then
    begin
      WriteLn('  Early exit, Result = ', Result);
      exit;
    end;
  end;
  
  WriteLn('  This should not print');
end;

function TestExitWithValue: Integer;
var
  LX: Integer;
begin
  WriteLn('--- TestExitWithValue ---');
  
  for LX := 1 to 100 do
  begin
    if LX * LX > 50 then
    begin
      WriteLn('  Found value: ', LX);
      exit(LX * LX);
    end;
  end;
  
  exit(0);
end;

function TestMultipleExitPoints(const AValue: Integer): Integer;
begin
  WriteLn('--- TestMultipleExitPoints (', AValue, ') ---');
  
  if AValue < 0 then
    exit(-1);
  
  if AValue = 0 then
    exit(0);
  
  if AValue > 100 then
    exit(100);
  
  exit(AValue * 2);
end;

{------------------------------------------------------------------------------}
{ COMPLEX SCENARIOS }
{------------------------------------------------------------------------------}

procedure TestNestedLoopsWithBreak;
var
  LI: Integer;
  LJ: Integer;
  LFound: Integer;
begin
  WriteLn('--- TestNestedLoopsWithBreak ---');
  LFound := 0;
  
  for LI := 1 to 5 do
  begin
    WriteLn('  Outer loop: ', LI);
    for LJ := 1 to 5 do
    begin
      if LJ = 3 then
      begin
        WriteLn('    Breaking inner at LJ=3');
        break;  // Only breaks inner loop
      end;
      WriteLn('    Inner loop: ', LJ);
    end;
  end;
  
  WriteLn('Outer loop completed all 5 iterations');
end;

procedure TestBreakAndContinueTogether;
var
  LI: Integer;
  LSum: Integer;
begin
  WriteLn('--- TestBreakAndContinueTogether ---');
  LSum := 0;
  
  for LI := 1 to 20 do
  begin
    if LI > 15 then
      break;
    if LI mod 2 = 0 then
      continue;
    LSum := LSum + LI;
  end;
  
  WriteLn('Sum of odd 1..15: ', LSum);  // Should be 64 (1+3+5+7+9+11+13+15)
end;

function SearchArray(const ATarget: Integer): Integer;
var
  LI: Integer;
  LArray: array[0..9] of Integer;
begin
  WriteLn('--- SearchArray (target=', ATarget, ') ---');
  
  // Initialize array
  LArray[0] := 10;
  LArray[1] := 25;
  LArray[2] := 30;
  LArray[3] := 42;
  LArray[4] := 55;
  LArray[5] := 67;
  LArray[6] := 72;
  LArray[7] := 88;
  LArray[8] := 93;
  LArray[9] := 99;
  
  for LI := 0 to 9 do
  begin
    if LArray[LI] = ATarget then
      exit(LI);
  end;
  
  exit(-1);  // Not found
end;

{------------------------------------------------------------------------------}
{ MAIN PROGRAM }
{------------------------------------------------------------------------------}

begin
  WriteLn('===============================================');
  WriteLn('=== Break/Continue/Exit Comprehensive Tests ===');
  WriteLn('===============================================');
  WriteLn;
  
  { Break Tests }
  TestBreakInForTo();
  WriteLn;
  
  TestBreakInForDownto();
  WriteLn;
  
  TestBreakInWhile();
  WriteLn;
  
  TestBreakInRepeat();
  WriteLn;
  
  TestBreakInNestedIf();
  WriteLn;
  
  { Continue Tests }
  TestContinueInForTo();
  WriteLn;
  
  TestContinueInForDownto();
  WriteLn;
  
  TestContinueInWhile();
  WriteLn;
  
  TestContinueInRepeat();
  WriteLn;
  
  { Exit Tests }
  TestExitInProcedure();
  WriteLn;
  
  GResult := TestExitInFunction();
  WriteLn('Function returned: ', GResult);
  WriteLn;
  
  GResult := TestExitWithValue();
  WriteLn('Exit(value) returned: ', GResult);
  WriteLn;
  
  GResult := TestMultipleExitPoints(-5);
  WriteLn('Result for -5: ', GResult);
  GResult := TestMultipleExitPoints(0);
  WriteLn('Result for 0: ', GResult);
  GResult := TestMultipleExitPoints(50);
  WriteLn('Result for 50: ', GResult);
  GResult := TestMultipleExitPoints(150);
  WriteLn('Result for 150: ', GResult);
  WriteLn;
  
  { Complex Scenarios }
  TestNestedLoopsWithBreak();
  WriteLn;
  
  TestBreakAndContinueTogether();
  WriteLn;
  
  GResult := SearchArray(42);
  WriteLn('Found 42 at index: ', GResult);
  GResult := SearchArray(99);
  WriteLn('Found 99 at index: ', GResult);
  GResult := SearchArray(13);
  WriteLn('Search for 13 (not found): ', GResult);
  WriteLn;
  
  WriteLn('===============================================');
  WriteLn('=== All Tests Complete ===');
  WriteLn('===============================================');
end.
