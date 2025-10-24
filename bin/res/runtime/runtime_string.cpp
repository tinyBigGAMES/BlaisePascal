/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_string.cpp - Implementation for runtime_string.h
// Most string implementations are inline in the header
// This file is for any non-inline implementations

#include "runtime_string.h"

namespace bp {

// Thread-local storage for temporary string conversions
// This allows ToCharPtr() to return a const char* that remains valid during the function call
thread_local std::string g_tempCharBuffer;

// Convert UTF-16 String to const char* (UTF-8) for C API interop
const char* String::ToCharPtr() const {
    g_tempCharBuffer = ToUTF8();
    return g_tempCharBuffer.c_str();
}

} // namespace bp
