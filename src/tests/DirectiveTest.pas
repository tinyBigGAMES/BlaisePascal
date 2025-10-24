{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

{$OPTIMIZATION "releasesmall"}

{$APPTYPE CONSOLE}
//{$APPTYPE GUI}

program DirectiveTest;

{$IFDEF GUI_APP}
function MessageBoxW(hWnd: Cardinal; lpText: PChar; lpCaption: PChar; uType: Cardinal): Integer;
  stdcall; external 'user32.dll';
{$ENDIF}

// Test conditional compilation
{$IFDEF BLAISEPASCAL}
const
  CompilerName = 'Blaise Pascal';
{$ELSE}  
const
  CompilerName = 'Unknown';
{$ENDIF}

{$IFDEF DEBUG}
const
  BuildMode = 'Debug Build';
{$ELSE}
const
  BuildMode = 'Release Build';
{$ENDIF}

{$IFDEF CONSOLE_APP}
const
  AppType = 'CONSOLE';
{$ENDIF}

{$IFDEF GUI_APP}
const
  AppType = 'GUI';
{$ENDIF}

{$IFDEF WIN32}
const
  Platform = 'Windows 32-bit';
{$ENDIF}

{$IFDEF WIN64}
const
  Platform = 'Windows 64-bit';
{$ENDIF}

{$IFDEF MSWINDOWS}
const
  OS = 'Windows';
{$ENDIF}

{$IFDEF LINUX}
const
  OS = 'Linux';
{$ENDIF}

begin
  {$IFDEF CONSOLE_APP}
  WriteLn('=== Compiler Directive Test ===');
  WriteLn('');
  WriteLn('Compiler: ', CompilerName);
  WriteLn('Build Mode: ', BuildMode);
  WriteLn('Optimization: ReleaseSmall');
  WriteLn('AppType: ', AppType);
  WriteLn('');
  
  {$IFDEF WIN32}
  WriteLn('Platform: ', Platform);
  {$ENDIF}
  
  {$IFDEF WIN64}
  WriteLn('Platform: ', Platform);
  {$ENDIF}
  
  {$IFDEF MSWINDOWS}
  WriteLn('OS: ', OS);
  {$ENDIF}
  
  {$IFDEF LINUX}
  WriteLn('OS: ', OS);
  {$ENDIF}
  
  WriteLn('');
  {$IFDEF DEBUG}
  WriteLn('Debug mode is active!');
  {$ELSE}
  WriteLn('Release mode is active!');
  {$ENDIF}
  
  WriteLn('');
  WriteLn('All directives processed successfully!');
  {$ENDIF}
  
  {$IFDEF GUI_APP}
  MessageBoxW(0, 'Compiler Directive Test passed!', 'DirectiveTest', 0);
  {$ENDIF}
end.