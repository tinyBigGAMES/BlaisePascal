{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramTypedConstants;
const
  CInt: Integer = 42;
  CInt64: Int64 = 9999999999;
  CFloat: Double = 3.14159;
  CString: String = 'Constant';
  CBool: Boolean = True;
  CChar: Char = 'X';
begin
  WriteLn('=== Testing Typed Constants ===');
  WriteLn('Integer constant: ', CInt);
  WriteLn('Int64 constant: ', CInt64);
  WriteLn('Double constant: ', CFloat);
  WriteLn('String constant: ', CString);
  WriteLn('Boolean constant: ', CBool);
  WriteLn('Char constant: ', CChar);
  WriteLn('✓ All typed constants tested');
end.
