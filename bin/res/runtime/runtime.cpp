/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime.cpp - Blaise Pascal Runtime Library Implementation
// Master implementation file that includes all runtime module implementations
//
// Since the runtime is mostly header-only (inline functions),
// this file is minimal and can be omitted from builds if not needed

#include "runtime.h"

// Include all implementation files
#include "runtime_types.cpp"
#include "runtime_io.cpp"
#include "runtime_string.cpp"
#include "runtime_math.cpp"
#include "runtime_convert.cpp"
#include "runtime_system.cpp"
#include "runtime_console.cpp"
#include "runtime_memory.cpp"
#include "runtime_control.cpp"
#include "runtime_exception.cpp"

namespace bp {
    // All implementations are in the individual module .cpp files
}
