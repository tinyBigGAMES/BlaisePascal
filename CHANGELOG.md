# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Create FUNDING.yml** (2025-10-24 – Jarrod Davis)


### Changed
- **Initial commit** (2025-10-24 – Jarrod Davis)


### Removed
- **Release v0.1.0: Foundation - The Transpiler That Works** (2025-10-24 – jarroddavis68)
  Blaise Pascal v0.1.0 establishes the foundational architecture that proves the
  concept: a simple token-mapping transpiler combined with a sophisticated C++
  runtime library can faithfully preserve Pascal semantics while generating clean,
  performant C++23 code. This release delivers complete procedural Pascal support,
  comprehensive type system, full control flow, and a runtime library that handles
  the semantic complexity so the transpiler stays simple.
  KEY MILESTONE:
  Blaise Pascal demonstrates ARCHITECTURAL VIABILITY. The "dumb transpiler, smart
  runtime" design works. Pascal code transpiles cleanly to C++23. The bp namespace
  runtime preserves exact Pascal semantics. Cross-platform compilation works via
  Zig and LLVM. The foundation is solid.
  CORE TYPE SYSTEM:
  - Complete integer types (Integer, Cardinal, Int64, UInt64, Byte, Word, ShortInt, SmallInt, LongInt, LongWord)
  - Boolean type with proper Pascal semantics
  - Character types (Char, AnsiChar) with correct behavior
  - String types (String with UTF-16 1-based indexing, AnsiString, WideString)
  - Floating-point types (Single, Double, Extended, Real)
  - Pointer types with proper dereferencing (^Type)
  - File types (File, TextFile/Text) with Pascal I/O semantics
  - Type aliases mapped correctly to C++ equivalents
  - All basic types working with full semantic compatibility
  STRUCTURED TYPES:
  - Records mapped to C++ structs with forward declarations
  - Enumerations with optional explicit values
  - Static arrays with bounds (array[Low..High] of Type)
  - Dynamic arrays with proper memory management
  - Multi-dimensional arrays (nested StaticArray template)
  - Set types with Include/Exclude operations (Set<Low, High>)
  - Function pointer types with calling conventions (cdecl, stdcall, pascal, safecall)
  - Pointer typedef generation with correct ordering
  - Complete structured type support
  OPERATORS AND EXPRESSIONS:
  - Arithmetic operators (+, -, *, /, div, mod)
  - Comparison operators (=, <>, <, >, <=, >=)
  - Logical operators (and, or, not, xor)
  - Bitwise operators (and, or, xor, not, shl, shr)
  - Address-of operator (@)
  - Dereference operator (^)
  - Set membership operator (in)
  - Assignment operator (:=)
  - String concatenation with optimization (S := S + X -> S += X)
  - Full expression evaluation
  CONTROL FLOW STATEMENTS:
  - if..then..else with proper block handling
  - while..do loops
  - repeat..until loops
  - for..to..do increment loops
  - for..downto..do decrement loops
  - case..of..else with range support (Low..High)
  - break and continue statements
  - exit with optional return value
  - with statements for record field access
  - Complete procedural control flow
  EXCEPTION HANDLING:
  - try..except..end blocks mapped to C++ exceptions
  - try..finally..end with proper cleanup semantics
  - Exception mapping to std::exception
  - RaiseException and GetExceptionMessage functions
  - Delphi-compatible exception model
  PROCEDURES AND FUNCTIONS:
  - Procedure declarations
  - Function declarations with typed return values
  - Parameter modifiers (const, var, out) with correct semantics
  - Forward declarations
  - Result variable for function returns
  - External function declarations (stdcall, cdecl)
  - Calling convention mapping to C++
  - Complete routine support
  PROGRAM STRUCTURE:
  - Programs (executables with main())
  - Units (modules with interface/implementation sections)
  - Libraries (DLLs/shared objects)
  - Library initialization/finalization (platform-specific)
  - Exports clause for DLL functions
  - Uses clause dependency resolution
  - Multi-file project support
  COMPILER DIRECTIVES:
  - {$INCLUDE_HEADER} - Include C/C++ headers in generated code
  - {$EXPORT_ABI} - Control DLL export ABI (C or CPP)
  - {$UNIT_PATH} - Add unit search paths
  - {$LIBRARY_PATH} - Add library search paths
  - {$INCLUDE_PATH} - Add include search paths
  - {$LINK} - Link external libraries
  - {$OPTIMIZATION} - Set optimization mode (Debug, ReleaseSafe, ReleaseFast, ReleaseSmall)
  - {$TARGET} - Set target platform
  - {$APPTYPE} - Set application type (CONSOLE or GUI)
  - {$IFDEF}/{$IFNDEF}/{$ELSE}/{$ENDIF} - Conditional compilation
  - Complete preprocessor directive system
  COMPREHENSIVE RUNTIME LIBRARY:
  - I/O functions (WriteLn, Write, ReadLn, Read)
  - File I/O (AssignFile, Rewrite, Reset, BlockWrite, BlockRead, CloseFile, FileSize, FilePos, Seek, Eof, Eoln)
  - File operations (DeleteFile, RenameFile, FileExists, Append, SeekEof, SeekEoln, Truncate, Flush, IOResult)
  - String functions (Length, SetLength, Copy, Pos, Insert, Delete, Concat)
  - String manipulation (UpperCase, LowerCase, Trim, TrimLeft, TrimRight)
  - String conversions (IntToStr, StrToInt, StrToIntDef, FloatToStr, StrToFloat, BoolToStr, Format, Chr, Ord)
  - Array functions (SetLength, Copy, Length, High, Low)
  - Set functions (Include, Exclude)
  - Directory operations (DirectoryExists, CreateDir, RemoveDir, GetCurrentDir, SetCurrentDir)
  - Increment/Decrement (Inc, Dec)
  - Command line (ParamCount, ParamStr)
  - System functions (Halt, SizeOf)
  - Memory functions (FillChar, Move, GetMem, FreeMem, ReallocMem, AllocMem, FillByte, FillWord, FillDWord, New, Dispose)
  - Math functions (Abs, Sqr, Sqrt, trigonometric, hyperbolic, exponential, logarithmic, rounding, Power, Pi, Random, Min, Max, Sign)
  - Ordinal functions (Odd, Swap)
  - 80+ runtime functions ready to use
  C++23 CODE GENERATION:
  - Clean C++23 output
  - Header files (.h) with include guards
  - Implementation files (.cpp)
  - #line directives for debugging
  - Type mapping to bp namespace
  - Identifier conflict resolution
  - Boolean context detection
  - Proper scoping and declarations
  CROSS-PLATFORM BUILD SYSTEM:
  - Zig 0.15.2 build system
  - LLVM 20.1.8 backend
  - Automatic build.zig generation
  - Cross-platform compilation (Windows, Linux, macOS)
  - Target validation and normalization
  - Optimization mode support
  - Exception handling configuration
  - Symbol stripping options
  - Application type configuration (Console/GUI)
  PROJECT MANAGEMENT:
  - Project initialization with templates (Program, Library, Unit)
  - Multi-file compilation
  - Dependency resolution
  - Uses clause processing
  - Module path configuration
  - Include path management
  - Library path management
  - Link library specification
  OPTIMIZATIONS:
  - String concatenation optimization (in-place +=)
  - Automatic literal casting for type safety
  - Type cast detection and emission
  - Efficient runtime function dispatch
  SMART ARCHITECTURE:
  - "Dumb transpiler, smart runtime" design
  - Transpiler focuses on AST walking and token mapping
  - Runtime library (bp namespace) handles all Pascal semantics
  - Clean separation of concerns
  - 1-based string indexing in runtime
  - Pascal division semantics preserved
  - UTF-16 Unicode support built-in
  - Array bounds checking in runtime
  - Set operations in runtime
  - Memory management in runtime
  MODULAR COMPILER DESIGN:
  - TCodeGen - Code generation orchestration
  - TPreprocessor - Directive processing
  - TBuild - Build system management
  - TErrors - Error reporting with line/column info
  - TUtils - Utility functions
  - Specialized modules:
  * CodeGen.Types - Type handling
  * CodeGen.Statements - Control flow
  * CodeGen.Expressions - Expression evaluation
  * CodeGen.Methods - Function/procedure handling
  * CodeGen.Variables - Variable declarations
  * CodeGen.Sections - Interface/implementation sections
  * CodeGen.Setup - Initialization
  * CodeGen.Generate - Main generation logic
  TESTING INFRASTRUCTURE:
  - Testbed system (UTestbed.pas)
  - Systematic test case execution
  - Pascal Source -> XML AST -> C++ files workflow
  - Test file organization
  - Transpilation verification
  This release establishes Blaise Pascal as a WORKING transpiler. The architecture
  is sound. The code generation is clean. The runtime is comprehensive. Pascal
  semantics are faithfully preserved. Cross-platform compilation works. The
  foundation is complete.
  THE FOUNDATION MILESTONE:
  Blaise Pascal isn't just a proof-of-concept - it's a working transpiler ready
  for expansion. Write procedural Pascal. Get clean C++23. Preserve exact
  semantics. Compile everywhere. The "dumb transpiler, smart runtime" architecture
  proves its worth. Build on this foundation with confidence.
  Think in Pascal. Compile to C++. Run everywhere.
  Version: 0.1.0

