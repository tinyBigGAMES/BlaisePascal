{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramMathFunctions;

var
  LX: Double;
  LY: Double;
  LI: Integer;
  LJ: Integer;

begin
  WriteLn('=== Testing Math Functions ===');
  WriteLn();
  
  { ============================================================================
    ARITHMETIC FUNCTIONS
    ============================================================================ }
  
  WriteLn('--- Arithmetic Functions ---');
  
  { Abs - Absolute value }
  LI := Abs(-5);
  WriteLn('Abs(-5) = ', LI);
  
  LX := Abs(-3.14);
  WriteLn('Abs(-3.14) = ', FloatToStr(LX));
  
  { Sqr - Square }
  LI := Sqr(4);
  WriteLn('Sqr(4) = ', LI);
  
  LX := Sqr(2.5);
  WriteLn('Sqr(2.5) = ', FloatToStr(LX));
  
  { Sqrt - Square root }
  LX := Sqrt(16.0);
  WriteLn('Sqrt(16) = ', FloatToStr(LX));
  
  LX := Sqrt(2.0);
  WriteLn('Sqrt(2) = ', FloatToStr(LX));
  
  WriteLn();
  
  { ============================================================================
    TRIGONOMETRIC FUNCTIONS
    ============================================================================ }
  
  WriteLn('--- Trigonometric Functions ---');
  
  { Sin - Sine }
  LX := Sin(0.0);
  WriteLn('Sin(0) = ', FloatToStr(LX));
  
  { Cos - Cosine }
  LX := Cos(0.0);
  WriteLn('Cos(0) = ', FloatToStr(LX));
  
  { Tan - Tangent }
  LX := Tan(0.0);
  WriteLn('Tan(0) = ', FloatToStr(LX));
  
  { ArcTan - Arctangent }
  LX := ArcTan(1.0);
  WriteLn('ArcTan(1) = ', FloatToStr(LX));
  
  { ArcSin - Arcsine }
  LX := ArcSin(0.5);
  WriteLn('ArcSin(0.5) = ', FloatToStr(LX));
  
  { ArcCos - Arccosine }
  LX := ArcCos(0.5);
  WriteLn('ArcCos(0.5) = ', FloatToStr(LX));
  
  WriteLn();
  
  { ============================================================================
    ROUNDING FUNCTIONS
    ============================================================================ }
  
  WriteLn('--- Rounding Functions ---');
  
  { Round - Round to nearest integer }
  LX := 3.7;
  LI := Round(LX);
  WriteLn('Round(3.7) = ', LI);
  
  LX := 3.2;
  LI := Round(LX);
  WriteLn('Round(3.2) = ', LI);
  
  { Trunc - Truncate to integer }
  LX := 3.7;
  LI := Trunc(LX);
  WriteLn('Trunc(3.7) = ', LI);
  
  LX := -3.7;
  LI := Trunc(LX);
  WriteLn('Trunc(-3.7) = ', LI);
  
  { Ceil - Ceiling }
  LX := Ceil(3.2);
  WriteLn('Ceil(3.2) = ', FloatToStr(LX));
  
  LX := Ceil(-3.2);
  WriteLn('Ceil(-3.2) = ', FloatToStr(LX));
  
  { Floor - Floor }
  LX := Floor(3.7);
  WriteLn('Floor(3.7) = ', FloatToStr(LX));
  
  LX := Floor(-3.7);
  WriteLn('Floor(-3.7) = ', FloatToStr(LX));
  
  WriteLn();
  
  { ============================================================================
    MIN/MAX FUNCTIONS
    ============================================================================ }
  
  WriteLn('--- Min/Max Functions ---');
  
  { Max - Maximum }
  LI := Max(5, 3);
  WriteLn('Max(5, 3) = ', LI);
  
  LX := Max(2.5, 7.1);
  WriteLn('Max(2.5, 7.1) = ', FloatToStr(LX));
  
  { Min - Minimum }
  LI := Min(5, 3);
  WriteLn('Min(5, 3) = ', LI);
  
  LX := Min(2.5, 7.1);
  WriteLn('Min(2.5, 7.1) = ', FloatToStr(LX));
  
  WriteLn();
  
  { ============================================================================
    RANDOM FUNCTIONS
    ============================================================================ }
  
  WriteLn('--- Random Functions ---');
  
  { Randomize - Initialize random seed }
  Randomize();
  WriteLn('Randomize(): Random seed initialized');
  
  { Random - Random integer }
  WriteLn('Random(100) samples:');
  for LI := 1 to 5 do
  begin
    LJ := Random(100);
    WriteLn('  Sample ', LI, ': ', LJ);
  end;
  
  { Random - Random double }
  WriteLn('Random() samples (0.0 to 1.0):');
  for LI := 1 to 5 do
  begin
    LX := Random();
    WriteLn('  Sample ', LI, ': ', FloatToStr(LX));
  end;
  
  WriteLn();
  WriteLn('✓ All math functions tested successfully');
end.
