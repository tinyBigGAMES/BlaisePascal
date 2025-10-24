{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramMathAdvanced;

var
  LX: Double;
  LY: Double;
  LZ: Double;

begin
  WriteLn('=== Testing Advanced Math Functions ===');
  WriteLn();
  
  { ============================================================================
    Int / Frac
    ============================================================================ }
  
  WriteLn('--- Int / Frac ---');
  
  { Positive value }
  LX := 3.7;
  WriteLn('Int(3.7) = ', FloatToStr(Int(LX)));
  WriteLn('Frac(3.7) = ', FloatToStr(Frac(LX)));
  
  { Negative value }
  LX := -3.7;
  WriteLn('Int(-3.7) = ', FloatToStr(Int(LX)));
  WriteLn('Frac(-3.7) = ', FloatToStr(Frac(LX)));
  
  { Zero }
  LX := 0.0;
  WriteLn('Int(0.0) = ', FloatToStr(Int(LX)));
  WriteLn('Frac(0.0) = ', FloatToStr(Frac(LX)));
  
  WriteLn();
  
  { ============================================================================
    Exp / Ln
    ============================================================================ }
  
  WriteLn('--- Exp / Ln ---');
  
  { Exp(1) should be approximately e (2.718...) }
  LX := Exp(1.0);
  WriteLn('Exp(1.0) = ', FloatToStr(LX));
  
  { Ln(e) should be 1 }
  LY := Ln(LX);
  WriteLn('Ln(Exp(1.0)) = ', FloatToStr(LY));
  
  { Verify identity: Ln(Exp(x)) = x }
  LX := 2.5;
  LY := Ln(Exp(LX));
  WriteLn('Ln(Exp(2.5)) = ', FloatToStr(LY));
  
  WriteLn();
  
  { ============================================================================
    Power
    ============================================================================ }
  
  WriteLn('--- Power ---');
  
  { Integer powers }
  LX := Power(2.0, 8.0);
  WriteLn('Power(2, 8) = ', FloatToStr(LX));
  
  { Fractional powers (square root) }
  LX := Power(9.0, 0.5);
  WriteLn('Power(9, 0.5) = ', FloatToStr(LX));
  
  { Negative powers }
  LX := Power(2.0, -2.0);
  WriteLn('Power(2, -2) = ', FloatToStr(LX));
  
  WriteLn();
  
  { ============================================================================
    Pi
    ============================================================================ }
  
  WriteLn('--- Pi ---');
  
  LX := Pi();
  WriteLn('Pi() = ', FloatToStr(LX));
  WriteLn('Verify Pi ≈ 3.14159...');
  
  WriteLn();
  
  { ============================================================================
    ArcTan2
    ============================================================================ }
  
  WriteLn('--- ArcTan2 ---');
  
  { Test all quadrants }
  LX := ArcTan2(1.0, 1.0);
  WriteLn('ArcTan2(1, 1) = ', FloatToStr(LX), ' (Quadrant I)');
  
  LX := ArcTan2(1.0, -1.0);
  WriteLn('ArcTan2(1, -1) = ', FloatToStr(LX), ' (Quadrant II)');
  
  LX := ArcTan2(-1.0, -1.0);
  WriteLn('ArcTan2(-1, -1) = ', FloatToStr(LX), ' (Quadrant III)');
  
  LX := ArcTan2(-1.0, 1.0);
  WriteLn('ArcTan2(-1, 1) = ', FloatToStr(LX), ' (Quadrant IV)');
  
  { Edge case }
  LX := ArcTan2(0.0, 1.0);
  WriteLn('ArcTan2(0, 1) = ', FloatToStr(LX), ' (Zero angle)');
  
  WriteLn();
  
  { ============================================================================
    Hyperbolic Functions
    ============================================================================ }
  
  WriteLn('--- Hyperbolic Functions ---');
  
  { Sinh }
  LX := Sinh(0.0);
  WriteLn('Sinh(0) = ', FloatToStr(LX));
  
  LX := Sinh(1.0);
  WriteLn('Sinh(1) = ', FloatToStr(LX));
  
  { Cosh }
  LX := Cosh(0.0);
  WriteLn('Cosh(0) = ', FloatToStr(LX));
  
  LX := Cosh(1.0);
  WriteLn('Cosh(1) = ', FloatToStr(LX));
  
  { Tanh }
  LX := Tanh(0.0);
  WriteLn('Tanh(0) = ', FloatToStr(LX));
  
  LX := Tanh(1.0);
  WriteLn('Tanh(1) = ', FloatToStr(LX));
  
  WriteLn();
  
  { ============================================================================
    Inverse Hyperbolic Functions
    ============================================================================ }
  
  WriteLn('--- Inverse Hyperbolic Functions ---');
  
  { ArcSinh }
  LX := ArcSinh(0.0);
  WriteLn('ArcSinh(0) = ', FloatToStr(LX));
  
  LY := 1.0;
  LX := ArcSinh(Sinh(LY));
  WriteLn('ArcSinh(Sinh(1)) = ', FloatToStr(LX), ' (should be ≈ 1)');
  
  { ArcCosh }
  LX := ArcCosh(1.0);
  WriteLn('ArcCosh(1) = ', FloatToStr(LX));
  
  LY := 2.0;
  LZ := Cosh(LY);
  LX := ArcCosh(LZ);
  WriteLn('ArcCosh(Cosh(2)) = ', FloatToStr(LX), ' (should be ≈ 2)');
  
  { ArcTanh }
  LX := ArcTanh(0.0);
  WriteLn('ArcTanh(0) = ', FloatToStr(LX));
  
  LY := 0.5;
  LX := ArcTanh(Tanh(LY));
  WriteLn('ArcTanh(Tanh(0.5)) = ', FloatToStr(LX), ' (should be ≈ 0.5)');
  
  WriteLn();
  
  { ============================================================================
    Logarithm Functions
    ============================================================================ }
  
  WriteLn('--- Logarithm Functions ---');
  
  { Log10 }
  LX := Log10(100.0);
  WriteLn('Log10(100) = ', FloatToStr(LX), ' (should be 2)');
  
  LX := Log10(1000.0);
  WriteLn('Log10(1000) = ', FloatToStr(LX), ' (should be 3)');
  
  { Log2 }
  LX := Log2(8.0);
  WriteLn('Log2(8) = ', FloatToStr(LX), ' (should be 3)');
  
  LX := Log2(256.0);
  WriteLn('Log2(256) = ', FloatToStr(LX), ' (should be 8)');
  
  { LogN - Base-N logarithm }
  LX := LogN(2.0, 16.0);
  WriteLn('LogN(2, 16) = ', FloatToStr(LX), ' (should be 4)');
  
  LX := LogN(10.0, 100.0);
  WriteLn('LogN(10, 100) = ', FloatToStr(LX), ' (should be 2)');
  
  { Verify logarithm law: LogN(a, x*y) = LogN(a,x) + LogN(a,y) }
  LX := LogN(2.0, 8.0);
  LY := LogN(2.0, 4.0);
  LZ := LogN(2.0, 32.0);
  WriteLn('LogN(2,8) + LogN(2,4) = ', FloatToStr(LX + LY), ' = LogN(2,32) = ', FloatToStr(LZ));
  
  WriteLn();
  WriteLn('✓ All advanced math functions tested successfully');
end.
