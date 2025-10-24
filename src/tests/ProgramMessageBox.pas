{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

{$APPTYPE GUI}
{$OPTIMIZATION ReleaseSmall}

{$INCLUDE_HEADER 'windows.h'}

program ProgramMessageBox;

function MessageBoxW(hWnd: Cardinal; const lpText: PChar; const lpCaption: PChar; uType: Cardinal): Integer; 
  stdcall; external 'user32.dll';
  
function MessageBoxA(hWnd: Cardinal; const lpText: PAnsiChar; const lpCaption: PAnsiChar; uType: Cardinal): Integer; 
  stdcall; external 'user32.dll';  

begin
  MessageBoxW(0, 'Hello from Blaise Pascal!', '#LTest - Unicode', 0);
  MessageBoxA(0, '#AHello from Blaise Pascal!', '#ATest - Ansi', 0);
end.
