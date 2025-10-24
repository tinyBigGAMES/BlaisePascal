/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_memory.h - Blaise Pascal memory management functions

#pragma once

#include "runtime_types.h"
#include <cstdlib>
#include <cstring>

namespace bp {

// ============================================================================
// Raw Memory Allocation (Delphi var parameter semantics)
// ============================================================================

// GetMem - Allocates memory and assigns to pointer variable (var parameter)
// Delphi: procedure GetMem(var P: Pointer; Size: Integer);
inline void GetMem(Pointer& ptr, const Integer& size) {
    ptr = std::malloc(size.ToInt());
}

inline void GetMem(Pointer& ptr, int size) {
    ptr = std::malloc(size);
}

// FreeMem - Frees memory pointed to by pointer
// Accepts both Pointer and void* for flexibility
inline void FreeMem(Pointer& ptr) {
    std::free(ptr.ToVoidPtr());
    ptr = nullptr;
}

inline void FreeMem(void* ptr) {
    std::free(ptr);
}

// ReallocMem - Reallocates memory and updates pointer (var parameter)
// Delphi: procedure ReallocMem(var P: Pointer; Size: Integer);
inline void ReallocMem(Pointer& ptr, const Integer& newsize) {
    ptr = std::realloc(ptr.ToVoidPtr(), newsize.ToInt());
}

inline void ReallocMem(Pointer& ptr, int newsize) {
    ptr = std::realloc(ptr.ToVoidPtr(), newsize);
}

// AllocMem - Allocates zero-initialized memory (var parameter)
// Delphi: procedure AllocMem(var P: Pointer; Size: Integer);
inline void AllocMem(Pointer& ptr, const Integer& size) {
    ptr = std::malloc(size.ToInt());
    if (ptr.ToVoidPtr()) {
        std::memset(ptr.ToVoidPtr(), 0, size.ToInt());
    }
}

inline void AllocMem(Pointer& ptr, int size) {
    ptr = std::malloc(size);
    if (ptr.ToVoidPtr()) {
        std::memset(ptr.ToVoidPtr(), 0, size);
    }
}

// ============================================================================
// Typed Pointer Allocation
// ============================================================================

template<typename T>
inline T* New() {
    return new T();
}

// Delphi-style New with pointer parameter
template<typename T>
inline void New(T*& ptr) {
    ptr = new typename std::remove_pointer<T>::type();
}

template<typename T>
inline void Dispose(T* ptr) {
    delete ptr;
}

// ============================================================================
// Size Query
// ============================================================================

// Note: SizeOf in Pascal is translated to sizeof() in C++ by the codegen
// This function is kept for compatibility with variables: SizeOf(myVar)
template<typename T>
inline constexpr Integer SizeOf(const T& obj) {
    return Integer(sizeof(T));
}

// ============================================================================
// Block Operations
// ============================================================================

inline void Move(const void* source, void* dest, const Integer& count) {
    std::memmove(dest, source, count.ToInt());
}

inline void Move(const void* source, void* dest, int count) {
    std::memmove(dest, source, count);
}

// Template overloads for arrays and objects (takes address automatically)
template<typename TSource, typename TDest>
inline void Move(const TSource& source, TDest& dest, const Integer& count) {
    std::memmove(&dest, &source, count.ToInt());
}

template<typename TSource, typename TDest>
inline void Move(const TSource& source, TDest& dest, int count) {
    std::memmove(&dest, &source, count);
}

inline void FillChar(void* ptr, const Integer& count, const Byte& value) {
    std::memset(ptr, value.ToByte(), count.ToInt());
}

inline void FillChar(void* ptr, int count, unsigned char value) {
    std::memset(ptr, value, count);
}

inline void FillChar(void* ptr, int count, int value) {
    std::memset(ptr, value, count);
}

// Overload for arrays and objects (takes address automatically)
template<typename T>
inline void FillChar(T& obj, const Integer& count, const Byte& value) {
    std::memset(&obj, value.ToByte(), count.ToInt());
}

template<typename T>
inline void FillChar(T& obj, const Integer& count, const Integer& value) {
    std::memset(&obj, value.ToInt(), count.ToInt());
}

template<typename T>
inline void FillChar(T& obj, const Integer& count, int value) {
    std::memset(&obj, value, count.ToInt());
}

template<typename T>
inline void FillChar(T& obj, int count, int value) {
    std::memset(&obj, value, count);
}

inline void FillByte(void* ptr, const Integer& count, const Byte& value) {
    std::memset(ptr, value.ToByte(), count.ToInt());
}

inline void FillByte(void* ptr, const Integer& count, const Integer& value) {
    std::memset(ptr, value.ToInt(), count.ToInt());
}

inline void FillByte(void* ptr, int count, unsigned char value) {
    std::memset(ptr, value, count);
}

// Template overloads for arrays and objects
template<typename T>
inline void FillByte(T& obj, const Integer& count, const Byte& value) {
    std::memset(&obj, value.ToByte(), count.ToInt());
}

template<typename T>
inline void FillByte(T& obj, const Integer& count, const Integer& value) {
    std::memset(&obj, value.ToInt(), count.ToInt());
}

template<typename T>
inline void FillByte(T& obj, int count, unsigned char value) {
    std::memset(&obj, value, count);
}

template<typename T>
inline void FillWord(T& arr, const Integer& count, const Word& value) {
    Word* ptr = reinterpret_cast<Word*>(&arr);
    for (int i = 0; i < count.ToInt(); i++) {
        ptr[i] = value;
    }
}

template<typename T>
inline void FillWord(T& arr, const Integer& count, const Integer& value) {
    unsigned short* ptr = reinterpret_cast<unsigned short*>(&arr);
    unsigned short fillValue = static_cast<unsigned short>(value.ToInt());
    for (int i = 0; i < count.ToInt(); i++) {
        ptr[i] = fillValue;
    }
}

template<typename T>
inline void FillWord(T& arr, int count, unsigned short value) {
    unsigned short* ptr = reinterpret_cast<unsigned short*>(&arr);
    for (int i = 0; i < count; i++) {
        ptr[i] = value;
    }
}

template<typename T>
inline void FillDWord(T& arr, const Integer& count, const Cardinal& value) {
    Cardinal* ptr = reinterpret_cast<Cardinal*>(&arr);
    for (int i = 0; i < count.ToInt(); i++) {
        ptr[i] = value;
    }
}

template<typename T>
inline void FillDWord(T& arr, const Integer& count, const Integer& value) {
    unsigned int* ptr = reinterpret_cast<unsigned int*>(&arr);
    unsigned int fillValue = static_cast<unsigned int>(value.ToInt());
    for (int i = 0; i < count.ToInt(); i++) {
        ptr[i] = fillValue;
    }
}

template<typename T>
inline void FillDWord(T& arr, int count, unsigned int value) {
    unsigned int* ptr = reinterpret_cast<unsigned int*>(&arr);
    for (int i = 0; i < count; i++) {
        ptr[i] = value;
    }
}

inline void FillZero(void* ptr, const Integer& count) {
    std::memset(ptr, 0, count.ToInt());
}

inline void FillZero(void* ptr, int count) {
    std::memset(ptr, 0, count);
}

// ============================================================================
// Memory Comparison
// ============================================================================

inline Integer CompareMem(const void* ptr1, const void* ptr2, const Integer& count) {
    return Integer(std::memcmp(ptr1, ptr2, count.ToInt()));
}

inline Integer CompareMem(const void* ptr1, const void* ptr2, int count) {
    return Integer(std::memcmp(ptr1, ptr2, count));
}

} // namespace bp
