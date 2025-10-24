{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramUsesUnitTypes;
uses 
  UnitWithTypes;

var
  P: TPoint;
  Ptr: PPoint;
  Dist: Integer;
begin
  WriteLn('=== Testing Units With Types ===');
  
  P := CreatePoint(10, 20);
  WriteLn('Created point: (', P.X, ',', P.Y, ')');
  
  Dist := DistanceFromOrigin(P);
  WriteLn('Distance^2 from origin: ', Dist);
  
  ModifyPoint(P, 5);
  WriteLn('After ModifyPoint(+5): (', P.X, ',', P.Y, ')');
  
  New(Ptr);
  Ptr^ := P;
  WriteLn('Pointer to point: (', Ptr^.X, ',', Ptr^.Y, ')');
  Dispose(Ptr);
  
  WriteLn('✓ Units with types tested');
end.
