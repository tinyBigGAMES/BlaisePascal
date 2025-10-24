/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_exception.h - Blaise Pascal exception handling

#pragma once

#include "runtime_types.h"
#include <exception>

namespace bp {

// ============================================================================
// Exception Types
// ============================================================================

enum ExceptionType {
    EX_EXCEPTION = 0,
    EX_CONVERT_ERROR = 1,
    EX_IO_ERROR = 2,
    EX_RANGE_ERROR = 3,
    EX_DIV_BY_ZERO = 4,
    EX_OVERFLOW = 5,
    EX_MATH_ERROR = 6,
    EX_ACCESS_VIOLATION = 7,
    EX_INVALID_POINTER = 8,
    EX_OUT_OF_MEMORY = 9,
};

// ============================================================================
// Exception Class
// ============================================================================

class Exception : public std::exception {
private:
    String message;
    int exceptionType;
    mutable std::string narrowMessage;  // Cached narrow conversion for what()

public:
    Exception(int type, const String& msg) 
        : exceptionType(type), message(msg) {}
    
    Exception(const String& msg)
        : exceptionType(EX_EXCEPTION), message(msg) {}
    
    int GetType() const { return exceptionType; }
    String GetMessage() const { return message; }
    
    const char* what() const noexcept override {
        narrowMessage = message.ToUTF8();
        return narrowMessage.c_str();
    }
};

// ============================================================================
// Specific Exception Classes
// ============================================================================

class EConvertError : public Exception {
public:
    EConvertError(const String& msg) 
        : Exception(EX_CONVERT_ERROR, msg) {}
};

class EIOError : public Exception {
public:
    EIOError(const String& msg) 
        : Exception(EX_IO_ERROR, msg) {}
};

class ERangeError : public Exception {
public:
    ERangeError(const String& msg) 
        : Exception(EX_RANGE_ERROR, msg) {}
};

class EDivByZero : public Exception {
public:
    EDivByZero(const String& msg) 
        : Exception(EX_DIV_BY_ZERO, msg) {}
};

class EOverflow : public Exception {
public:
    EOverflow(const String& msg) 
        : Exception(EX_OVERFLOW, msg) {}
};

class EMathError : public Exception {
public:
    EMathError(const String& msg) 
        : Exception(EX_MATH_ERROR, msg) {}
};

class EAccessViolation : public Exception {
public:
    EAccessViolation(const String& msg) 
        : Exception(EX_ACCESS_VIOLATION, msg) {}
};

class EInvalidPointer : public Exception {
public:
    EInvalidPointer(const String& msg) 
        : Exception(EX_INVALID_POINTER, msg) {}
};

class EOutOfMemory : public Exception {
public:
    EOutOfMemory(const String& msg) 
        : Exception(EX_OUT_OF_MEMORY, msg) {}
};

// ============================================================================
// Exception Helper Functions
// ============================================================================

namespace internal {
    // Thread-local storage for current exception message
    inline thread_local String current_exception_message;
}

inline void RaiseException(int type, const String& msg) {
    internal::current_exception_message = msg;  // Store message before throwing
    throw Exception(type, msg);
}

inline void RaiseException(const String& msg) {
    internal::current_exception_message = msg;  // Store message before throwing
    throw Exception(msg);
}

// GetExceptionMessage - Retrieve message from currently handled exception
// Must be called within an except block
inline String GetExceptionMessage() {
    return internal::current_exception_message;
}

inline String ExceptionMessage(const Exception& e) {
    return e.GetMessage();
}

inline int ExceptionType(const Exception& e) {
    return e.GetType();
}

} // namespace bp
