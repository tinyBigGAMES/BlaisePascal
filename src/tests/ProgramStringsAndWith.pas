{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramStringsAndWith;

type
  TPoint = record
    X: Integer;
    Y: Integer;
  end;
  
  TRect = record
    TopLeft: TPoint;
    BottomRight: TPoint;
  end;

var
  GName: string;
  GPath: string;
  GPoint: TPoint;
  GRect: TRect;
  GLength: Integer;

begin
  WriteLn('=== ProgramStringsAndWith ===');
  
  // String operations
  GName := 'Hello';
  WriteLn('GName: ', GName);
  
  GPath := 'C:\Test';
  WriteLn('GPath: ', GPath);
  
  GName := GName + ' World';
  WriteLn('GName after concat: ', GName);
  
  GLength := Length(GName);
  WriteLn('Length of GName: ', GLength);
  
  // With statement for record
  with GPoint do
  begin
    X := 10;
    Y := 20;
  end;
  WriteLn('GPoint: (', GPoint.X, ', ', GPoint.Y, ')');
  
  // Nested with
  with GRect do
  begin
    with TopLeft do
    begin
      X := 0;
      Y := 0;
    end;
    with BottomRight do
    begin
      X := 100;
      Y := 100;
    end;
  end;
  WriteLn('GRect.TopLeft: (', GRect.TopLeft.X, ', ', GRect.TopLeft.Y, ')');
  WriteLn('GRect.BottomRight: (', GRect.BottomRight.X, ', ', GRect.BottomRight.Y, ')');
  
  // With and assignment
  with GRect.TopLeft do
    X := GRect.BottomRight.X div 2;
  WriteLn('GRect.TopLeft.X after div: ', GRect.TopLeft.X);
end.
