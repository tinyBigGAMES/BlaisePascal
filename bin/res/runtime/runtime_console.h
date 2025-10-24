/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_console.h - Console initialization and setup
// Platform-specific console configuration (UTF-8, ANSI escape sequences, etc.)

#pragma once

namespace bp {
namespace internal {

// Initialize console for UTF-8 output and ANSI escape sequences
// Implementation is in runtime_console.cpp to avoid pulling in platform headers
void InitializeConsole();

} // namespace internal
} // namespace bp
