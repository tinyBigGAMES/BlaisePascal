{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramNestedRecords;
type
  TPoint = record
    X: Integer;
    Y: Integer;
  end;
  
  TRect = record
    TopLeft: TPoint;
    BottomRight: TPoint;
  end;
  
  TShape = record
    Bounds: TRect;
    Color: Integer;
  end;

var
  Shape: TShape;
  Width, Height: Integer;
begin
  WriteLn('=== Testing Nested Records ===');
  
  Shape.Bounds.TopLeft.X := 0;
  Shape.Bounds.TopLeft.Y := 0;
  Shape.Bounds.BottomRight.X := 100;
  Shape.Bounds.BottomRight.Y := 100;
  Shape.Color := 255;
  
  WriteLn('Shape TopLeft: (', Shape.Bounds.TopLeft.X, ',', Shape.Bounds.TopLeft.Y, ')');
  WriteLn('Shape BottomRight: (', Shape.Bounds.BottomRight.X, ',', Shape.Bounds.BottomRight.Y, ')');
  WriteLn('Shape Color: ', Shape.Color);
  
  Width := Shape.Bounds.BottomRight.X - Shape.Bounds.TopLeft.X;
  Height := Shape.Bounds.BottomRight.Y - Shape.Bounds.TopLeft.Y;
  WriteLn('Shape Width: ', Width);
  WriteLn('Shape Height: ', Height);
  
  WriteLn('✓ Nested records tested');
end.
