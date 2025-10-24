/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_system.h - Blaise Pascal system functions

#pragma once

#include "runtime_types.h"
#include "runtime_console.h"
#include <chrono>
#include <cstdlib>
#include <cstdio>

namespace bp {

// ============================================================================
// Program Control
// ============================================================================

inline void Halt(const Integer& exitcode = Integer(0)) {
    std::exit(exitcode.ToInt());
}

inline void Halt(int exitcode = 0) {
    std::exit(exitcode);
}

inline void Abort() {
    std::exit(3);  // Exit code 3 for abnormal termination (matches Windows behavior)
}

inline void RunError(const Integer& errorcode = Integer(0)) {
    if (errorcode.ToInt() != 0) {
        std::fprintf(stderr, "Runtime error %d\n", errorcode.ToInt());
    }
    std::exit(errorcode.ToInt());
}

inline void RunError(int errorcode = 0) {
    if (errorcode != 0) {
        std::fprintf(stderr, "Runtime error %d\n", errorcode);
    }
    std::exit(errorcode);
}

// ============================================================================
// Timing Functions
// ============================================================================

inline Int64 GetTickCount64() {
    return Int64(
        std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now().time_since_epoch()
        ).count()
    );
}

inline Integer GetTickCount() {
    auto ticks = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::steady_clock::now().time_since_epoch()
    ).count();
    return Integer(static_cast<int>(ticks & 0xFFFFFFFF));
}

// ============================================================================
// Command Line Parameters
// ============================================================================

// These need to be set by main() before use
namespace internal {
    inline int g_argc = 0;
    inline char** g_argv = nullptr;
    
    // InitializeConsole is now in runtime_console.h/cpp
    
    inline void SetCommandLine(int argc, char** argv) {
        g_argc = argc;
        g_argv = argv;
    }
}

inline Integer ParamCount() {
    return Integer(internal::g_argc - 1);
}

inline String ParamStr(const Integer& index) {
    int idx = index.ToInt();
    if (idx >= 0 && idx < internal::g_argc) {
        return String(internal::g_argv[idx]);
    }
    return String("");
}

inline String ParamStr(int index) {
    if (index >= 0 && index < internal::g_argc) {
        return String(internal::g_argv[index]);
    }
    return String("");
}

// ============================================================================
// Inc/Dec as Functions
// ============================================================================

inline void Inc(Integer& value, const Integer& amount = Integer(1)) {
    value.Inc(amount.ToInt());
}

inline void Dec(Integer& value, const Integer& amount = Integer(1)) {
    value.Dec(amount.ToInt());
}

inline void Inc(Int64& value, const Int64& amount = Int64(1)) {
    value.Inc(amount.ToInt64());
}

inline void Dec(Int64& value, const Int64& amount = Int64(1)) {
    value.Dec(amount.ToInt64());
}

inline void Inc(Cardinal& value, const Cardinal& amount = Cardinal(1)) {
    value.Inc(amount.ToCardinal());
}

inline void Dec(Cardinal& value, const Cardinal& amount = Cardinal(1)) {
    value.Dec(amount.ToCardinal());
}

inline void Inc(Byte& value, int amount = 1) {
    value.Inc(amount);
}

inline void Dec(Byte& value, int amount = 1) {
    value.Dec(amount);
}

inline void Inc(Word& value, int amount = 1) {
    value.Inc(amount);
}

inline void Dec(Word& value, int amount = 1) {
    value.Dec(amount);
}

// ============================================================================
// Pointer Checks
// ============================================================================

template<typename T>
inline Boolean Assigned(T* ptr) {
    return Boolean(ptr != nullptr);
}

inline Boolean Assigned(const void* ptr) {
    return Boolean(ptr != nullptr);
}

// ============================================================================
// Odd Function - Tests if a value is odd
// ============================================================================

inline Boolean Odd(const Integer& value) {
    return Boolean((value.ToInt() & 1) != 0);
}

inline Boolean Odd(const Int64& value) {
    return Boolean((value.ToInt64() & 1) != 0);
}

inline Boolean Odd(const Cardinal& value) {
    return Boolean((value.ToCardinal() & 1) != 0);
}

inline Boolean Odd(const Byte& value) {
    return Boolean((value.ToByte() & 1) != 0);
}

inline Boolean Odd(const Word& value) {
    return Boolean((value.ToWord() & 1) != 0);
}

inline Boolean Odd(const ShortInt& value) {
    return Boolean((value.ToShortInt() & 1) != 0);
}

inline Boolean Odd(const SmallInt& value) {
    return Boolean((value.ToSmallInt() & 1) != 0);
}

inline Boolean Odd(int value) {
    return Boolean((value & 1) != 0);
}

// ============================================================================
// Swap Function - Variable swap (two arguments)
// ============================================================================

template<typename T>
inline void Swap(T& a, T& b) {
    T temp = a;
    a = b;
    b = temp;
}

// ============================================================================
// Swap Function - Byte order swap for 16-bit values (one argument)
// ============================================================================

inline Word Swap(const Word& value) {
    unsigned short v = value.ToWord();
    return Word(((v & 0xFF) << 8) | ((v >> 8) & 0xFF));
}

inline Word Swap(unsigned short value) {
    return Word(((value & 0xFF) << 8) | ((value >> 8) & 0xFF));
}

} // namespace bp
