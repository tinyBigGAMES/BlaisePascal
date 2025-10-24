/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime.h - Blaise Pascal Runtime Library
// Master header that includes all runtime modules
// 
// This is the only header that generated C++ code needs to include:
//   #include "runtime.h"
//
// All runtime lives in namespace bp { ... }
// Generated code uses fully-qualified names: bp::Integer, bp::WriteLn, etc.
// NEVER use 'using namespace bp;' in generated code

#pragma once

// Core types (Integer, Boolean, Single, Double, Extended, Char, String, Array, Set)
#include "runtime_types.h"

// I/O functions (WriteLn, Write, TextFile)
#include "runtime_io.h"

// String manipulation (Copy, Pos, UpperCase, LowerCase, etc.)
#include "runtime_string.h"

// Math functions (Abs, Sqrt, Sin, Cos, etc.)
#include "runtime_math.h"

// std::formatter specializations for bp:: types (MUST come before runtime_convert.h!)
#include "runtime_formatters.h"

// Type conversions (IntToStr, StrToInt, FloatToStr, etc.)
#include "runtime_convert.h"

// System functions (Halt, GetTickCount64, ParamCount, etc.)
#include "runtime_system.h"

// Memory management (GetMem, FreeMem, New, Dispose)
#include "runtime_memory.h"

// Control flow wrappers (PFor, PForDownto, PRepeatUntil)
#include "runtime_control.h"

// Exception handling (Exception class, RaiseException)
#include "runtime_exception.h"

// All runtime is in namespace bp
namespace bp {
    // Everything is already declared in the included headers
    // This namespace statement is just for documentation
}
