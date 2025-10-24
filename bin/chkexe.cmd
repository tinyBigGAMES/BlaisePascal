@echo off
REM ============================================================================
REM chkexe.cmd - Executable File Type and Architecture Checker
REM ============================================================================
REM 
REM Description:
REM   Detects and reports the file format and architecture of executable files.
REM   Supports all major executable formats used by Zig and modern toolchains.
REM
REM Usage:
REM   chkexe FILE
REM
REM Supported Formats:
REM   - PE/PE32+    : Windows executables (x86, x64, ARM, ARM64)
REM   - ELF         : Linux/Unix executables (x86, x64, ARM, AArch64, RISC-V)
REM   - Mach-O      : macOS executables (32/64-bit, Fat binaries)
REM   - WASM        : WebAssembly modules
REM   - MZ/DOS      : Legacy DOS executables
REM
REM Examples:
REM   chkexe myapp.exe        -> PE32+ (x64)
REM   chkexe libfoo.so        -> ELF 64-bit (x64)
REM   chkexe program.wasm     -> WASM (v1)
REM
REM Author: Blaise Project
REM Date: 2025-10-22
REM ============================================================================

setlocal
if "%~1"=="" (
  echo Usage: chkexe FILE
  exit /b 1
)
set "ps=%TEMP%\chkexe_arch_%RANDOM%.ps1"
> "%ps%" echo Param([string]$Path)
>>"%ps%" echo $fs=[IO.File]::OpenRead($Path)
>>"%ps%" echo try{
>>"%ps%" echo   $br=New-Object IO.BinaryReader($fs)
>>"%ps%" echo   $m=$br.ReadBytes(4)
>>"%ps%" echo   if($m.Length -lt 4){'Unknown'; return}
>>"%ps%" echo   # ELF
>>"%ps%" echo   if($m[0]-eq0x7F -and $m[1]-eq0x45 -and $m[2]-eq0x4C -and $m[3]-eq0x46){
>>"%ps%" echo     $cls=$br.ReadByte(); $fs.Position=0x12; $mach=$br.ReadUInt16()
>>"%ps%" echo     $bit=if($cls -eq 2){'64-bit'} elseif($cls -eq 1){'32-bit'} else {'?'}
>>"%ps%" echo     $arch=switch($mach){0x03{'x86'}0x3E{'x64'}0x28{'ARM'}0xB7{'AArch64'}0xF3{'RISC-V'}default{"0x{0:X}" -f $mach}}
>>"%ps%" echo     "ELF $bit ($arch)"; return
>>"%ps%" echo   }
>>"%ps%" echo   # PE/MZ
>>"%ps%" echo   if($m[0]-eq0x4D -and $m[1]-eq0x5A){
>>"%ps%" echo     $fs.Position=0x3C; $peoff=$br.ReadInt32(); $fs.Position=$peoff
>>"%ps%" echo     $sig=$br.ReadBytes(4)
>>"%ps%" echo     if($sig[0]-eq0x50 -and $sig[1]-eq0x45 -and $sig[2]-eq0x00 -and $sig[3]-eq0x00){
>>"%ps%" echo       $machine=$br.ReadUInt16()
>>"%ps%" echo       switch($machine){
>>"%ps%" echo         0x14c  {'PE32 (x86)';  return}
>>"%ps%" echo         0x8664 {'PE32+ (x64)'; return}
>>"%ps%" echo         0x1c0  {'PE (ARM)';    return}
>>"%ps%" echo         0xaa64 {'PE (ARM64)';  return}
>>"%ps%" echo         0x1c4  {'PE (ARMv7)';  return}
>>"%ps%" echo         default {"PE (0x{0:X})" -f $machine; return}
>>"%ps%" echo       }
>>"%ps%" echo     } else {'MZ (DOS)'; return}
>>"%ps%" echo   }
>>"%ps%" echo   # WebAssembly
>>"%ps%" echo   if($m[0]-eq0x00 -and $m[1]-eq0x61 -and $m[2]-eq0x73 -and $m[3]-eq0x6D){
>>"%ps%" echo     $ver=$br.ReadUInt32(); "WASM (v$ver)"; return
>>"%ps%" echo   }
>>"%ps%" echo   # Mach-O
>>"%ps%" echo   $magic=[BitConverter]::ToUInt32($m,0)
>>"%ps%" echo   switch($magic){
>>"%ps%" echo     0xFEEDFACE {'Mach-O 32';        return}
>>"%ps%" echo     0xFEEDFACF {'Mach-O 64';        return}
>>"%ps%" echo     0xCEFAEDFE {'Mach-O 32 (BE)';   return}
>>"%ps%" echo     0xCFFAEDFE {'Mach-O 64 (BE)';   return}
>>"%ps%" echo     0xCAFEBABE {'Mach-O Fat';       return}
>>"%ps%" echo     0xBEBAFECA {'Mach-O Fat (BE)';  return}
>>"%ps%" echo   }
>>"%ps%" echo   'Unknown'
>>"%ps%" echo } finally { if($br){$br.Close()} if($fs){$fs.Close()} }
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%ps%" "%~1"
set "ec=%ERRORLEVEL%"
del /q "%ps%" >nul 2>&1
exit /b %ec%