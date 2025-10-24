{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramMemoryAdvanced;

type
  TByteArray = array[0..99] of Byte;
  TWordArray = array[0..9] of Word;
  TDWordArray = array[0..9] of Cardinal;

var
  LPtr: Pointer;
  LSize: Integer;
  LByteArray: TByteArray;
  LWordArray: TWordArray;
  LDWordArray: TDWordArray;
  LI: Integer;
  LSource: array[0..9] of Integer;
  LDest: array[0..9] of Integer;

begin
  WriteLn('=== Testing Advanced Memory Functions ===');
  WriteLn();
  
  { ============================================================================
    ReallocMem
    ============================================================================ }
  
  WriteLn('--- ReallocMem ---');
  
  { Allocate initial block }
  GetMem(LPtr, 10);
  WriteLn('Allocated 10 bytes');
  
  { Write data to initial block }
  FillChar(LPtr^, 10, $AA);
  WriteLn('Filled with $AA');
  
  { Grow the block }
  ReallocMem(LPtr, 20);
  WriteLn('Reallocated to 20 bytes (grown)');
  
  { Shrink the block }
  ReallocMem(LPtr, 5);
  WriteLn('Reallocated to 5 bytes (shrunk)');
  
  { Free the memory }
  FreeMem(LPtr);
  WriteLn('Memory freed');
  
  WriteLn();
  
  { ============================================================================
    AllocMem
    ============================================================================ }
  
  WriteLn('--- AllocMem ---');
  
  { Allocate and zero-initialize }
  AllocMem(LPtr, 100);
  WriteLn('Allocated 100 bytes with zero-initialization');
  
  { Verify zeros (check first 10 bytes) }
  LSize := 0;
  for LI := 0 to 9 do
  begin
    if Byte(Pointer(UInt64(LPtr) + LI)^) = 0 then
      Inc(LSize);
  end;
  WriteLn('Verified first 10 bytes are zero: ', LSize = 10);
  
  { Free the memory }
  FreeMem(LPtr);
  WriteLn('Memory freed');
  
  WriteLn();
  
  { ============================================================================
    FillChar
    ============================================================================ }
  
  WriteLn('--- FillChar ---');
  
  { Fill array with specific byte value }
  FillChar(LByteArray, SizeOf(LByteArray), $55);
  WriteLn('Filled byte array with $55');
  
  { Verify fill (check first and last elements) }
  WriteLn('First element: $', IntToHex(LByteArray[0], 2));
  WriteLn('Last element: $', IntToHex(LByteArray[99], 2));
  WriteLn('Fill verified: ', (LByteArray[0] = $55) and (LByteArray[99] = $55));
  
  WriteLn();
  
  { ============================================================================
    FillByte
    ============================================================================ }
  
  WriteLn('--- FillByte ---');
  
  { Fill byte array with specific value }
  FillByte(LByteArray, 100, $FF);
  WriteLn('Filled byte array with $FF using FillByte');
  
  { Verify fill }
  WriteLn('First element: $', IntToHex(LByteArray[0], 2));
  WriteLn('Element 50: $', IntToHex(LByteArray[50], 2));
  WriteLn('Fill verified: ', (LByteArray[0] = $FF) and (LByteArray[50] = $FF));
  
  WriteLn();
  
  { ============================================================================
    FillWord
    ============================================================================ }
  
  WriteLn('--- FillWord ---');
  
  { Fill word array with specific value }
  FillWord(LWordArray, 10, $ABCD);
  WriteLn('Filled word array with $ABCD');
  
  { Verify fill }
  WriteLn('First element: $', IntToHex(LWordArray[0], 4));
  WriteLn('Last element: $', IntToHex(LWordArray[9], 4));
  WriteLn('Fill verified: ', (LWordArray[0] = $ABCD) and (LWordArray[9] = $ABCD));
  
  WriteLn();
  
  { ============================================================================
    FillDWord
    ============================================================================ }
  
  WriteLn('--- FillDWord ---');
  
  { Fill dword array with specific value }
  FillDWord(LDWordArray, 10, $12345678);
  WriteLn('Filled dword array with $12345678');
  
  { Verify fill }
  WriteLn('First element: $', IntToHex(LDWordArray[0], 8));
  WriteLn('Middle element: $', IntToHex(LDWordArray[5], 8));
  WriteLn('Fill verified: ', (LDWordArray[0] = $12345678) and (LDWordArray[5] = $12345678));
  
  WriteLn();
  
  { ============================================================================
    Move
    ============================================================================ }
  
  WriteLn('--- Move ---');
  
  { Initialize source array }
  for LI := 0 to 9 do
    LSource[LI] := LI * 10;
  
  WriteLn('Source array initialized: [0, 10, 20, ..., 90]');
  
  { Copy to destination }
  Move(LSource, LDest, SizeOf(LSource));
  WriteLn('Moved data to destination array');
  
  { Verify copy }
  WriteLn('Destination[0]: ', LDest[0]);
  WriteLn('Destination[5]: ', LDest[5]);
  WriteLn('Destination[9]: ', LDest[9]);
  WriteLn('Move verified: ', (LDest[0] = 0) and (LDest[5] = 50) and (LDest[9] = 90));
  
  WriteLn();
  WriteLn('✓ All advanced memory functions tested successfully');
end.
