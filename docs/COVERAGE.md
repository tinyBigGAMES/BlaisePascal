# Blaise Language Coverage

This document tracks currently implemented and working features in the Blaise compiler based on actual source code verification.

## Compiler Directives

- [x] `{$INCLUDE_HEADER}` - Include C/C++ headers in generated code
- [x] `{$EXPORT_ABI}` - Control DLL export ABI (C or CPP)
- [x] `{$IFDEF}` / `{$IFNDEF}` / `{$ELSE}` / `{$ENDIF}` - Conditional compilation

## Basic Types

- [x] Integer
- [x] Cardinal
- [x] Int64
- [x] UInt64
- [x] Byte
- [x] Word
- [x] ShortInt
- [x] SmallInt
- [x] LongInt (alias for Integer)
- [x] LongWord (alias for Cardinal)
- [x] Boolean
- [x] Char
- [x] AnsiChar
- [x] String (UTF-16, 1-based indexing)
- [x] AnsiString
- [x] WideString (alias for String)
- [x] Single
- [x] Double
- [x] Extended
- [x] Real (alias for Double)
- [x] Pointer
- [x] File
- [x] TextFile / Text
- [x] Wide string literals (default: `'text'` → `L"text"`)
- [x] ANSI string literals (`'#Atext'` → `"text"`)

## Structured Types

- [x] Records (struct)
- [x] Enumerations (enum)
- [x] Arrays (static with bounds)
- [x] Dynamic arrays
- [x] Multi-dimensional arrays
- [x] Sets
- [x] Pointer types (`^Type`)

## Operators

### Arithmetic
- [x] `+` (addition)
- [x] `-` (subtraction)
- [x] `*` (multiplication)
- [x] `/` (division - returns Double)
- [x] `div` (integer division)
- [x] `mod` (modulo)

### Comparison
- [x] `=` (equal)
- [x] `<>` (not equal)
- [x] `<` (less than)
- [x] `>` (greater than)
- [x] `<=` (less than or equal)
- [x] `>=` (greater than or equal)

### Logical
- [x] `and` (logical and)
- [x] `or` (logical or)
- [x] `not` (logical not)
- [x] `xor` (exclusive or)

### Bitwise (on integer types)
- [x] `and` (bitwise and)
- [x] `or` (bitwise or)
- [x] `xor` (bitwise xor)
- [x] `not` (bitwise not)
- [x] `shl` (shift left)
- [x] `shr` (shift right)

### Other
- [x] `@` (address-of)
- [x] `^` (dereference)
- [x] `in` (set membership)
- [x] `:=` (assignment)
- [x] `+=` (optimized string concatenation: `S := S + X` → `S += X`)

## Control Flow Statements

- [x] if..then..else
- [x] while..do
- [x] repeat..until
- [x] for..to..do (increment loops)
- [x] for..downto..do (decrement loops)
- [x] case..of..else
- [x] break
- [x] continue
- [x] exit (with and without return value)

## Exception Handling

- [x] try..except..end
- [x] try..finally..end

## Procedures and Functions

- [x] Procedure declarations
- [x] Function declarations with return types
- [x] Parameters (const, var, out modifiers)
- [x] Forward declarations
- [x] Result variable for functions
- [x] External function declarations (stdcall, cdecl)

## Program Types

- [x] Programs (executable with main())
- [x] Units (modules with interface/implementation)
- [x] Libraries (DLLs/shared objects)
- [x] Library initialization/finalization
- [x] Exports clause

## Variables and Constants

- [x] Global variables
- [x] Local variables in procedures/functions
- [x] Constant declarations
- [x] Typed constants (initialized arrays/records)

## Runtime Functions

### I/O Functions
- [x] WriteLn
- [x] Write
- [x] ReadLn
- [x] Read

### String Functions
- [x] Length
- [x] SetLength
- [x] Copy
- [x] Pos
- [x] Insert
- [x] Delete
- [x] Concat
- [x] UpperCase
- [x] LowerCase
- [x] Trim
- [x] TrimLeft
- [x] TrimRight

### String Conversion
- [x] IntToStr
- [x] StrToInt
- [x] StrToIntDef
- [x] FloatToStr
- [x] StrToFloat
- [x] BoolToStr
- [x] Format
- [x] Chr
- [x] Ord

### Array Functions
- [x] SetLength
- [x] Copy
- [x] Length
- [x] High
- [x] Low

### Set Functions
- [x] Include
- [x] Exclude

### File I/O
- [x] AssignFile
- [x] Rewrite
- [x] Reset
- [x] BlockWrite
- [x] BlockRead
- [x] CloseFile
- [x] FileSize
- [x] FilePos
- [x] Seek
- [x] Eof
- [x] Eoln
- [x] DeleteFile
- [x] RenameFile
- [x] FileExists
- [x] Append
- [x] SeekEof
- [x] SeekEoln
- [x] Truncate
- [x] Flush
- [x] IOResult

### Directory Operations
- [x] DirectoryExists
- [x] CreateDir
- [x] RemoveDir
- [x] GetCurrentDir
- [x] SetCurrentDir

### Increment/Decrement
- [x] Inc
- [x] Dec

### Command Line
- [x] ParamCount
- [x] ParamStr

### System Functions
- [x] Halt

### Memory Functions
- [x] FillChar
- [x] Move
- [x] SizeOf
- [x] GetMem
- [x] FreeMem
- [x] ReallocMem
- [x] AllocMem
- [x] FillByte
- [x] FillWord
- [x] FillDWord
- [x] New
- [x] Dispose

### Exception Functions
- [x] RaiseException
- [x] GetExceptionMessage

### Math Functions
- [x] Abs
- [x] Sqr
- [x] Sqrt
- [x] Sin / Cos / Tan
- [x] ArcSin / ArcCos / ArcTan
- [x] ArcTan2
- [x] Sinh / Cosh / Tanh
- [x] ArcSinh / ArcCosh / ArcTanh
- [x] Ln
- [x] Exp
- [x] Trunc
- [x] Round
- [x] Int
- [x] Frac
- [x] Ceil
- [x] Floor
- [x] Power
- [x] Pi
- [x] Log10
- [x] Log2
- [x] LogN
- [x] Randomize
- [x] Random
- [x] Min
- [x] Max
- [x] Sign

### Ordinal Functions
- [x] Odd
- [x] Swap

## Optimizations

- [x] String concatenation optimization (`S := S + X` → `S += X`)
- [x] In-place string operations

## Code Generation

- [x] C++23 code generation
- [x] Header (.h) files with include guards
- [x] Implementation (.cpp) files
- [x] #line directives for debugging support
- [x] Forward declarations for records
- [x] Pointer typedef generation
- [x] Type mapping (Pascal types to C++ types)
- [x] DLL/shared library support
- [x] Library initialization/finalization (DllMain for Windows, constructor/destructor for POSIX)
- [x] C++ ABI exports (default, with name mangling for C++ interop)
- [x] C ABI exports (optional via `{$EXPORT_ABI C}` for pure C interop with POD types only)

## Build System

- [x] Zig 0.15.2 build system
- [x] LLVM 20.1.8 backend
- [x] Project file indexing
- [x] Multi-file compilation
- [x] Dependency resolution
- [x] Uses clause processing
- [x] Error reporting with line/column information
- [x] Preprocessing directives
- [x] Cross-platform compilation (Windows, Linux, macOS)
