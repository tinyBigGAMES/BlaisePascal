{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

{$IFDEF BLAISEPASCAL}
{$INCLUDE_HEADER 'windows.h'}
{$ENDIF}

unit UBPBench;

interface

procedure RunBench();

implementation

{$IFNDEF BLAISEPASCAL}
uses
  WinApi.Windows,
  System.SysUtils;
{$ENDIF}

const
  CMaxInt = 2147483647;

type
  TBenchResult = record
    BenchName: string;
    Iterations: Int64;
    ElapsedTicks: Int64;
    TPS: Int64;
    BytesProcessed: Double;
  end;

var
  GSink: Int64;

{$IFDEF BLAISEPASCAL}
function QueryPerformanceFrequency(AFrequency: PLARGE_INTEGER): Integer; stdcall; external 'kernel32.dll' name 'QueryPerformanceFrequency';
function QueryPerformanceCounter(ACounter: PLARGE_INTEGER): Integer; stdcall; external 'kernel32.dll' name 'QueryPerformanceCounter';

function TicksPerSec(): Int64;
var
  LFreq: LARGE_INTEGER;
begin
  if QueryPerformanceFrequency(@LFreq) = 0 then
  begin
    WriteLn('ERROR: High-resolution timer not supported.');
    Halt(1);
  end;
  Result := LFreq.QuadPart;
end;

function TicksNow(): Int64;
var
  LCounter: LARGE_INTEGER;
begin
  QueryPerformanceCounter(@LCounter);
  Result := LCounter.QuadPart;
end;
{$ELSE}
function QueryPerformanceFrequency(AFrequency: PLargeInteger): Integer; stdcall; external 'kernel32.dll' name 'QueryPerformanceFrequency';
function QueryPerformanceCounter(ACounter: PLargeInteger): Integer; stdcall; external 'kernel32.dll' name 'QueryPerformanceCounter';

function TicksPerSec(): Int64;
var
  LFreq: LARGE_INTEGER;
begin
  if QueryPerformanceFrequency(@LFreq) = 0 then
  begin
    WriteLn('ERROR: High-resolution timer not supported.');
    Halt(1);
  end;
  Result := LFreq.QuadPart;
end;

function TicksNow(): Int64;
var
  LCounter: LARGE_INTEGER;
begin
  QueryPerformanceCounter(@LCounter);
  Result := LCounter.QuadPart;
end;

{$ENDIF}

function MyStrToIntDef(const AStr: string; const ADefault: Integer): Integer;
var
  LIndex: Integer;
  LValue: Integer;
  LSign: Integer;
  LCh: Char;
  LCharZero: Char;
  LCharNine: Char;
  LCharMinus: Char;
begin
  if AStr = '' then
  begin
    Result := ADefault;
    Exit;
  end;

  LIndex := 1;
  LValue := 0;
  LSign := 1;
  LCharMinus := '-';
  LCharZero := '0';
  LCharNine := '9';

  LCh := AStr[1];
  if LCh = LCharMinus then
  begin
    LSign := -1;
    Inc(LIndex);
  end;

  while LIndex <= Length(AStr) do
  begin
    LCh := AStr[LIndex];
    if (LCh >= LCharZero) and (LCh <= LCharNine) then
      LValue := LValue * 10 + Ord(LCh) - Ord(LCharZero)
    else
    begin
      Result := ADefault;
      Exit;
    end;
    Inc(LIndex);
  end;

  Result := LValue * LSign;
end;

function GetParamValue(const AKey: string; const ADefaultValue: string): string;
var
  LIndex: Integer;
  LLen: Integer;
  LParam: string;
  LPrefix: string;
begin
  LPrefix := '--' + AKey + '=';
  LLen := Length(LPrefix);

  LIndex := 1;
  while LIndex <= ParamCount() do
  begin
    LParam := ParamStr(LIndex);
    if (Length(LParam) >= LLen) and (Copy(LParam, 1, LLen) = LPrefix) then
    begin
      Result := Copy(LParam, LLen + 1, CMaxInt);
      Exit;
    end;
    Inc(LIndex);
  end;

  Result := ADefaultValue;
end;

function GetParamInt(const AKey: string; const ADefaultValue: Integer): Integer;
begin
  Result := MyStrToIntDef(GetParamValue(AKey, ''), ADefaultValue);
end;

function MySameText(const AStr1: string; const AStr2: string): Boolean;
var
  LIndex: Integer;
  LLen1: Integer;
  LLen2: Integer;
  LCh1: Char;
  LCh2: Char;
  LCharA: Char;
  LCharZ: Char;
begin
  LLen1 := Length(AStr1);
  LLen2 := Length(AStr2);

  if LLen1 <> LLen2 then
  begin
    Result := False;
    Exit;
  end;

  LCharA := 'A';
  LCharZ := 'Z';

  LIndex := 1;
  while LIndex <= LLen1 do
  begin
    LCh1 := AStr1[LIndex];
    LCh2 := AStr2[LIndex];

    if (LCh1 >= LCharA) and (LCh1 <= LCharZ) then
      LCh1 := Char(Ord(LCh1) + 32);

    if (LCh2 >= LCharA) and (LCh2 <= LCharZ) then
      LCh2 := Char(Ord(LCh2) + 32);

    if LCh1 <> LCh2 then
    begin
      Result := False;
      Exit;
    end;

    Inc(LIndex);
  end;

  Result := True;
end;

function NsPerOp(const AResult: TBenchResult): Double;
begin
  if AResult.Iterations = 0 then
  begin
    Result := 0.0;
    Exit;
  end;
  Result := (AResult.ElapsedTicks * 1000000000.0) / (AResult.TPS * AResult.Iterations);
end;

function OpsPerSec(const AResult: TBenchResult): Double;
var
  LSec: Double;
begin
  LSec := Double(AResult.ElapsedTicks) / Double(AResult.TPS);
  if LSec <= 0.0 then
  begin
    Result := 0.0;
    Exit;
  end;
  Result := Double(AResult.Iterations) / LSec;
end;

function MBPerSec(const AResult: TBenchResult): Double;
var
  LSec: Double;
begin
  if AResult.BytesProcessed = 0.0 then
  begin
    Result := 0.0;
    Exit;
  end;

  LSec := Double(AResult.ElapsedTicks) / Double(AResult.TPS);
  if LSec <= 0.0 then
  begin
    Result := 0.0;
    Exit;
  end;

  Result := (AResult.BytesProcessed / 1048576.0) / LSec;
end;

procedure Bench_StringConcat_1k(var ABytesProcessed: Double);
var
  LStr: string;
  LIndex: Integer;
begin
  LStr := '';
  LIndex := 1;
  while LIndex <= 1024 do
  begin
    LStr := LStr + 'x';
    Inc(LIndex);
  end;
  ABytesProcessed := 1024.0;
  if Length(LStr) = 0 then
    Write('');
end;

procedure Bench_ArraySum_10M(var ABytesProcessed: Double);
var
  LIndex: Integer;
  LSum: Int64;
  LArray: array[0..99] of Int64;
begin
  LIndex := 0;
  while LIndex <= 99 do
  begin
    LArray[LIndex] := 0;
    Inc(LIndex);
  end;
  
  LSum := 0;
  LIndex := 1;
  while LIndex <= 10000000 do
  begin
    LSum := LSum + LIndex;
    LArray[LIndex mod 100] := LSum;
    Inc(LIndex);
  end;
  
  ABytesProcessed := 10000000.0 * 8.0;
  GSink := LArray[99];
  if GSink = 0 then
    Write('');
end;

procedure Bench_MatMul_64(var ABytesProcessed: Double);
var
  LMatrixA: array[0..63, 0..63] of Double;
  LMatrixB: array[0..63, 0..63] of Double;
  LMatrixC: array[0..63, 0..63] of Double;
  LIndexI: Integer;
  LIndexJ: Integer;
  LIndexK: Integer;
  LAcc: Double;
begin
  LIndexI := 0;
  while LIndexI <= 63 do
  begin
    LIndexJ := 0;
    while LIndexJ <= 63 do
    begin
      LMatrixA[LIndexI, LIndexJ] := (LIndexI + LIndexJ) * 0.001;
      LMatrixB[LIndexI, LIndexJ] := (LIndexI - LIndexJ) * 0.002;
      LMatrixC[LIndexI, LIndexJ] := 0.0;
      Inc(LIndexJ);
    end;
    Inc(LIndexI);
  end;

  LIndexI := 0;
  while LIndexI <= 63 do
  begin
    LIndexJ := 0;
    while LIndexJ <= 63 do
    begin
      LAcc := 0.0;
      LIndexK := 0;
      while LIndexK <= 63 do
      begin
        LAcc := LAcc + LMatrixA[LIndexI, LIndexK] * LMatrixB[LIndexK, LIndexJ];
        Inc(LIndexK);
      end;
      LMatrixC[LIndexI, LIndexJ] := LAcc;
      Inc(LIndexJ);
    end;
    Inc(LIndexI);
  end;

  ABytesProcessed := 64.0 * 64.0 * 3.0 * 8.0;
  if LMatrixC[0, 0] < 0.0 then
    Write('');
end;

procedure RunBenchmark(const ABenchNum: Integer; var ABytesProcessed: Double);
begin
  if ABenchNum = 1 then
    Bench_StringConcat_1k(ABytesProcessed)
  else if ABenchNum = 2 then
    Bench_ArraySum_10M(ABytesProcessed)
  else if ABenchNum = 3 then
    Bench_MatMul_64(ABytesProcessed);
end;

procedure WarmupBench(const ABenchNum: Integer; const ARounds: Integer);
var
  LIndex: Integer;
  LBytes: Double;
begin
  LIndex := 1;
  while LIndex <= ARounds do
  begin
    LBytes := 0.0;
    RunBenchmark(ABenchNum, LBytes);
    Inc(LIndex);
  end;
end;

function AutoIters(const ABenchNum: Integer; const ATPS: Int64; const ATargetMs: Integer): Int64;
var
  LBytes: Double;
  LTime0: Int64;
  LTime1: Int64;
  LDelta: Int64;
  LTargetTicks: Int64;
  LIterations: Int64;
begin
  LTargetTicks := (ATPS * ATargetMs) div 1000;
  if LTargetTicks <= 0 then
    LTargetTicks := ATPS div 100;

  LBytes := 0.0;
  LTime0 := TicksNow();
  RunBenchmark(ABenchNum, LBytes);
  LTime1 := TicksNow();
  LDelta := LTime1 - LTime0;

  if LDelta <= 0 then
    LDelta := 1;

  LIterations := LTargetTicks div LDelta;
  if LIterations < 1 then
    LIterations := 1;
  if LIterations > 100000000 then
    LIterations := 100000000;

  Result := LIterations;
end;

function RunOne(const ABenchNum: Integer; const ABenchName: string; const ABytesHint: Double; const ATPS: Int64; const AWarmups: Integer; const ATargetMs: Integer): TBenchResult;
var
  LIterCount: Int64;
  LIndex: Int64;
  LBytes: Double;
  LBytesTotal: Double;
  LTime0: Int64;
  LTime1: Int64;
begin
  WarmupBench(ABenchNum, AWarmups);
  LIterCount := AutoIters(ABenchNum, ATPS, ATargetMs);

  LBytesTotal := 0.0;
  LTime0 := TicksNow();

  LIndex := 1;
  while LIndex <= LIterCount do
  begin
    LBytes := 0.0;
    RunBenchmark(ABenchNum, LBytes);
    LBytesTotal := LBytesTotal + LBytes;
    Inc(LIndex);
  end;

  LTime1 := TicksNow();

  Result.BenchName := ABenchName;
  Result.Iterations := LIterCount;
  Result.ElapsedTicks := LTime1 - LTime0;
  Result.TPS := ATPS;

  if ABytesHint <> 0.0 then
  begin
    Result.BytesProcessed := ABytesHint * Double(LIterCount);
  end
  else
    Result.BytesProcessed := LBytesTotal;
end;

procedure PrintCsvHeader();
begin
  WriteLn('variant,benchmark,iterations,ns_per_op,ops_per_sec,mb_per_sec');
end;

procedure PrintCsvRow(const AVariantName: string; const AResult: TBenchResult);
var
  LNs: Double;
  LOps: Double;
  LMb: Double;
begin
  LNs := NsPerOp(AResult);
  LOps := OpsPerSec(AResult);
  LMb := MBPerSec(AResult);
  {$IFDEF BLAISEPASCAL}
  WriteLn(Format('%s,%s,%lld,%.2f,%.2f,%.2f', AVariantName, AResult.BenchName, AResult.Iterations, LNs, LOps, LMb));
  {$ELSE}
  WriteLn(Format('%s,%s,%d,%.2f,%.2f,%.2f', [AVariantName, AResult.BenchName, AResult.Iterations, LNs, LOps, LMb]));
  {$ENDIF}
end;

procedure PrintMarkdownRow(const AVariantName: string; const AResult: TBenchResult);
var
  LNs: Double;
  LOps: Double;
  LMb: Double;
begin
  LNs := NsPerOp(AResult);
  LOps := OpsPerSec(AResult);
  LMb := MBPerSec(AResult);
  {$IFDEF BLAISEPASCAL}
  WriteLn(Format('| %s | %s | %lld | %.2f | %.2f | %.2f |', AVariantName, AResult.BenchName, AResult.Iterations, LNs, LOps, LMb));
  {$ELSE}
  WriteLn(Format('| %s | %s | %d | %.2f | %.2f | %.2f |', [AVariantName, AResult.BenchName, AResult.Iterations, LNs, LOps, LMb]));
  {$ENDIF}
end;

procedure RunBench();
var
  LVariantName: string;
  LWarmups: Integer;
  LTargetMs: Integer;
  LCsv: Boolean;
  LTps: Int64;
  LResult1: TBenchResult;
  LResult2: TBenchResult;
  LResult3: TBenchResult;
  LBytes1: Double;
  LBytes2: Double;
  LBytes3: Double;


begin
  GSink := 0;
  
  {$IFDEF BLAISEPASCAL}
  LVariantName := 'BlaisePascal';
  {$ELSE}
  LVariantName := 'Delphi';
  {$ENDIF}
  
  // Allow command-line override
  if ParamCount() > 0 then
  begin
    if GetParamValue('variant', '') <> '' then
      LVariantName := GetParamValue('variant', LVariantName);
  end;
  
  LWarmups := GetParamInt('warmups', 2);
  LTargetMs := GetParamInt('target_ms', 400);
  LCsv := MySameText(GetParamValue('csv', 'no'), 'yes');

  LTps := TicksPerSec();

  LBytes1 := 1024.0;
  LBytes2 := 80000000.0;
  LBytes3 := 98304.0;

  if LCsv then
    PrintCsvHeader();

  LResult1 := RunOne(1, 'string_concat_1k', LBytes1, LTps, LWarmups, LTargetMs);
  LResult2 := RunOne(2, 'array_sum_10m', LBytes2, LTps, LWarmups, LTargetMs);
  LResult3 := RunOne(3, 'matmul_64', LBytes3, LTps, LWarmups, LTargetMs);

  if LCsv then
  begin
    PrintCsvRow(LVariantName, LResult1);
    PrintCsvRow(LVariantName, LResult2);
    PrintCsvRow(LVariantName, LResult3);
  end
  else
  begin
    WriteLn;
    WriteLn('| Variant | Benchmark | Iterations | ns/op | ops/s | MB/s |');
    WriteLn('|--------:|-----------|-----------:|------:|------:|-----:|');
    PrintMarkdownRow(LVariantName, LResult1);
    PrintMarkdownRow(LVariantName, LResult2);
    PrintMarkdownRow(LVariantName, LResult3);
    WriteLn;
  end;

  if GSink < 0 then
    WriteLn('Sink: ', IntToStr(GSink));
end;

end.
