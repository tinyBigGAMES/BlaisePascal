/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_types.h - Core Blaise Pascal wrapped types
// All types match Delphi semantics exactly

#pragma once

#include <string>
#include <vector>
#include <array>
#include <bitset>
#include <compare>
#include <iostream>

namespace bp {

// Forward declarations
class Double;
class Extended;

// ============================================================================
// Integer - Wraps int with Pascal semantics
// ============================================================================
class Integer {
private:
    int value;

public:
    // Constructors
    constexpr Integer() : value(0) {}
    constexpr Integer(int v) : value(v) {}
    
    // Assignment
    Integer& operator=(int v) {
        value = v;
        return *this;
    }
    
    // Arithmetic operators
    Integer operator+(const Integer& other) const {
        return Integer(value + other.value);
    }
    
    Integer operator+(int other) const {
        return Integer(value + other);
    }
    
    Integer operator-(const Integer& other) const {
        return Integer(value - other.value);
    }
    
    Integer operator-(int other) const {
        return Integer(value - other);
    }
    
    Integer operator*(const Integer& other) const {
        return Integer(value * other.value);
    }
    
    Integer operator*(int other) const {
        return Integer(value * other);
    }
    
    Double operator*(double other) const;  // Forward declared
    
    // Pascal '/' operator on integers returns Double (Delphi semantic!)
    Double operator/(const Integer& other) const;  // Forward declared
    Double operator/(int other) const;  // Forward declared
    
    // Pascal 'div' operator (integer division)
    Integer Div(const Integer& other) const {
        return Integer(value / other.value);
    }
    
    // Pascal 'mod' operator
    Integer Mod(const Integer& other) const {
        return Integer(value % other.value);
    }
    
    // Bitwise operators (Pascal: and, or, xor, not, shl, shr with integer operands)
    Integer operator&(const Integer& other) const {
        return Integer(value & other.value);
    }
    
    Integer operator|(const Integer& other) const {
        return Integer(value | other.value);
    }
    
    Integer operator^(const Integer& other) const {
        return Integer(value ^ other.value);
    }
    
    Integer operator~() const {
        return Integer(~value);
    }
    
    Integer operator<<(int shift) const {
        return Integer(value << shift);
    }
    
    Integer operator>>(int shift) const {
        return Integer(value >> shift);
    }
    
    // Unary minus
    Integer operator-() const {
        return Integer(-value);
    }
    
    // C++20 spaceship operator - generates all 6 comparison operators!
    auto operator<=>(const Integer& other) const = default;
    bool operator==(const Integer& other) const = default;
    
    // Comparison operators with int
    bool operator<(int other) const { return value < other; }
    bool operator<=(int other) const { return value <= other; }
    bool operator>(int other) const { return value > other; }
    bool operator>=(int other) const { return value >= other; }
    bool operator==(int other) const { return value == other; }
    bool operator!=(int other) const { return value != other; }
    
    // Inc/Dec (Pascal intrinsics)
    void Inc(int amount = 1) { value += amount; }
    void Dec(int amount = 1) { value -= amount; }
    
    // Prefix increment/decrement for C++ for-loops
    Integer& operator++() { ++value; return *this; }
    Integer& operator--() { --value; return *this; }
    
    // Postfix increment/decrement
    Integer operator++(int) { Integer temp = *this; ++value; return temp; }
    Integer operator--(int) { Integer temp = *this; --value; return temp; }
    
    // Conversion
    int ToInt() const { return value; }
    explicit operator int() const { return value; }  // Explicit conversion to prevent ambiguity
    
    // For I/O
    friend std::ostream& operator<<(std::ostream& os, const Integer& i) {
        return os << i.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Integer& i) {
        return is >> i.value;
    }
};

// ============================================================================
// Int64 - 64-bit integer
// ============================================================================
class Int64 {
private:
    long long value;

public:
    constexpr Int64() : value(0) {}
    constexpr Int64(long long v) : value(v) {}
    constexpr Int64(const Integer& i) : value(static_cast<long long>(i.ToInt())) {}
    constexpr Int64(int i) : value(static_cast<long long>(i)) {}
    
    Int64& operator=(long long v) {
        value = v;
        return *this;
    }
    
    Int64& operator=(const Integer& i) {
        value = static_cast<long long>(i.ToInt());
        return *this;
    }
    
    Int64& operator=(int i) {
        value = static_cast<long long>(i);
        return *this;
    }
    
    Int64 operator+(const Int64& other) const {
        return Int64(value + other.value);
    }
    
    Int64 operator+(int other) const {
        return Int64(value + other);
    }
    
    Int64 operator+(long long other) const {
        return Int64(value + other);
    }
    
    Int64 operator-(const Int64& other) const {
        return Int64(value - other.value);
    }
    
    Int64 operator*(const Int64& other) const {
        return Int64(value * other.value);
    }
    
    Int64 operator*(int other) const {
        return Int64(value * other);
    }
    
    Int64 operator*(long long other) const {
        return Int64(value * other);
    }
    
    Double operator*(double other) const;  // Forward declared
    
    Double operator/(const Int64& other) const;  // Forward declared
    Double operator/(int other) const;  // Forward declared
    Double operator/(long long other) const;  // Forward declared
    Double operator/(double other) const;  // Forward declared
    
    Int64 Div(const Int64& other) const {
        return Int64(value / other.value);
    }
    
    Int64 Mod(const Int64& other) const {
        return Int64(value % other.value);
    }
    
    Int64 operator-() const {
        return Int64(-value);
    }
    
    auto operator<=>(const Int64& other) const = default;
    bool operator==(const Int64& other) const = default;
    
    void Inc(long long amount = 1) { value += amount; }
    void Dec(long long amount = 1) { value -= amount; }
    
    long long ToInt64() const { return value; }
    explicit operator long long() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const Int64& i) {
        return os << i.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Int64& i) {
        return is >> i.value;
    }
};

// ============================================================================
// UInt64 - Unsigned 64-bit integer
// ============================================================================
class UInt64 {
private:
    unsigned long long value;

public:
    constexpr UInt64() : value(0) {}
    constexpr UInt64(unsigned long long v) : value(v) {}
    
    UInt64& operator=(unsigned long long v) {
        value = v;
        return *this;
    }
    
    UInt64 operator+(const UInt64& other) const {
        return UInt64(value + other.value);
    }
    
    UInt64 operator+(int other) const {
        return UInt64(value + other);
    }
    
    UInt64 operator+(const Integer& other) const {
        return UInt64(value + other.ToInt());
    }
    
    UInt64 operator-(const UInt64& other) const {
        return UInt64(value - other.value);
    }
    
    UInt64 operator-(int other) const {
        return UInt64(value - other);
    }
    
    UInt64 operator-(const Integer& other) const {
        return UInt64(value - other.ToInt());
    }
    
    UInt64 operator*(const UInt64& other) const {
        return UInt64(value * other.value);
    }
    
    UInt64 operator*(int other) const {
        return UInt64(value * other);
    }
    
    UInt64 operator*(const Integer& other) const {
        return UInt64(value * other.ToInt());
    }
    
    Double operator/(const UInt64& other) const;  // Forward declared
    
    UInt64 Div(const UInt64& other) const {
        return UInt64(value / other.value);
    }
    
    UInt64 Mod(const UInt64& other) const {
        return UInt64(value % other.value);
    }
    
    auto operator<=>(const UInt64& other) const = default;
    bool operator==(const UInt64& other) const = default;
    
    // Comparison operators with int
    bool operator<(int other) const { return value < static_cast<unsigned long long>(other); }
    bool operator<=(int other) const { return value <= static_cast<unsigned long long>(other); }
    bool operator>(int other) const { return value > static_cast<unsigned long long>(other); }
    bool operator>=(int other) const { return value >= static_cast<unsigned long long>(other); }
    bool operator==(int other) const { return value == static_cast<unsigned long long>(other); }
    bool operator!=(int other) const { return value != static_cast<unsigned long long>(other); }
    
    void Inc(unsigned long long amount = 1) { value += amount; }
    void Dec(unsigned long long amount = 1) { value -= amount; }
    
    unsigned long long ToUInt64() const { return value; }
    explicit operator unsigned long long() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const UInt64& u) {
        return os << u.value;
    }
    
    friend std::istream& operator>>(std::istream& is, UInt64& u) {
        return is >> u.value;
    }
};

// ============================================================================
// Cardinal - Unsigned 32-bit integer
// ============================================================================
class Cardinal {
private:
    unsigned int value;

public:
    constexpr Cardinal() : value(0) {}
    constexpr Cardinal(unsigned int v) : value(v) {}
    
    Cardinal& operator=(unsigned int v) {
        value = v;
        return *this;
    }
    
    Cardinal operator+(const Cardinal& other) const {
        return Cardinal(value + other.value);
    }
    
    Cardinal operator-(const Cardinal& other) const {
        return Cardinal(value - other.value);
    }
    
    Cardinal operator*(const Cardinal& other) const {
        return Cardinal(value * other.value);
    }
    
    Double operator/(const Cardinal& other) const;  // Forward declared
    
    Cardinal Div(const Cardinal& other) const {
        return Cardinal(value / other.value);
    }
    
    Cardinal Mod(const Cardinal& other) const {
        return Cardinal(value % other.value);
    }
    
    auto operator<=>(const Cardinal& other) const = default;
    bool operator==(const Cardinal& other) const = default;
    
    void Inc(unsigned int amount = 1) { value += amount; }
    void Dec(unsigned int amount = 1) { value -= amount; }
    
    unsigned int ToCardinal() const { return value; }
    explicit operator unsigned int() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const Cardinal& c) {
        return os << c.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Cardinal& c) {
        return is >> c.value;
    }
};

// ============================================================================
// Byte - Unsigned 8-bit integer
// ============================================================================
class Byte {
private:
    unsigned char value;

public:
    constexpr Byte() : value(0) {}
    constexpr Byte(unsigned char v) : value(v) {}
    constexpr Byte(int v) : value(static_cast<unsigned char>(v)) {}
    
    Byte& operator=(unsigned char v) {
        value = v;
        return *this;
    }
    
    Byte operator+(const Byte& other) const {
        return Byte(value + other.value);
    }
    
    Byte operator-(const Byte& other) const {
        return Byte(value - other.value);
    }
    
    Byte operator*(const Byte& other) const {
        return Byte(value * other.value);
    }
    
    Double operator/(const Byte& other) const;  // Forward declared
    
    Byte Div(const Byte& other) const {
        return Byte(value / other.value);
    }
    
    Byte Mod(const Byte& other) const {
        return Byte(value % other.value);
    }
    
    auto operator<=>(const Byte& other) const = default;
    bool operator==(const Byte& other) const = default;
    
    void Inc(int amount = 1) { value += amount; }
    void Dec(int amount = 1) { value -= amount; }
    
    unsigned char ToByte() const { return value; }
    int ToInt() const { return static_cast<int>(value); }
    explicit operator unsigned char() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const Byte& b) {
        return os << static_cast<int>(b.value);
    }
    
    friend std::istream& operator>>(std::istream& is, Byte& b) {
        int temp;
        is >> temp;
        b.value = static_cast<unsigned char>(temp);
        return is;
    }
};

// ============================================================================
// Word - Unsigned 16-bit integer
// ============================================================================
class Word {
private:
    unsigned short value;

public:
    constexpr Word() : value(0) {}
    constexpr Word(unsigned short v) : value(v) {}
    constexpr Word(int v) : value(static_cast<unsigned short>(v)) {}
    
    Word& operator=(unsigned short v) {
        value = v;
        return *this;
    }
    
    Word operator+(const Word& other) const {
        return Word(value + other.value);
    }
    
    Word operator-(const Word& other) const {
        return Word(value - other.value);
    }
    
    Word operator*(const Word& other) const {
        return Word(value * other.value);
    }
    
    Double operator/(const Word& other) const;  // Forward declared
    
    Word Div(const Word& other) const {
        return Word(value / other.value);
    }
    
    Word Mod(const Word& other) const {
        return Word(value % other.value);
    }
    
    auto operator<=>(const Word& other) const = default;
    bool operator==(const Word& other) const = default;
    
    void Inc(int amount = 1) { value += amount; }
    void Dec(int amount = 1) { value -= amount; }
    
    unsigned short ToWord() const { return value; }
    int ToInt() const { return static_cast<int>(value); }
    explicit operator unsigned short() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const Word& w) {
        return os << w.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Word& w) {
        return is >> w.value;
    }
};

// ============================================================================
// ShortInt - Signed 8-bit integer
// ============================================================================
class ShortInt {
private:
    signed char value;

public:
    constexpr ShortInt() : value(0) {}
    constexpr ShortInt(signed char v) : value(v) {}
    constexpr ShortInt(int v) : value(static_cast<signed char>(v)) {}
    
    ShortInt& operator=(signed char v) {
        value = v;
        return *this;
    }
    
    ShortInt operator+(const ShortInt& other) const {
        return ShortInt(value + other.value);
    }
    
    ShortInt operator-(const ShortInt& other) const {
        return ShortInt(value - other.value);
    }
    
    ShortInt operator*(const ShortInt& other) const {
        return ShortInt(value * other.value);
    }
    
    Double operator/(const ShortInt& other) const;  // Forward declared
    
    ShortInt Div(const ShortInt& other) const {
        return ShortInt(value / other.value);
    }
    
    ShortInt Mod(const ShortInt& other) const {
        return ShortInt(value % other.value);
    }
    
    ShortInt operator-() const {
        return ShortInt(-value);
    }
    
    auto operator<=>(const ShortInt& other) const = default;
    bool operator==(const ShortInt& other) const = default;
    
    void Inc(int amount = 1) { value += amount; }
    void Dec(int amount = 1) { value -= amount; }
    
    signed char ToShortInt() const { return value; }
    int ToInt() const { return static_cast<int>(value); }
    explicit operator signed char() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const ShortInt& s) {
        return os << static_cast<int>(s.value);
    }
    
    friend std::istream& operator>>(std::istream& is, ShortInt& s) {
        int temp;
        is >> temp;
        s.value = static_cast<signed char>(temp);
        return is;
    }
};

// ============================================================================
// SmallInt - Signed 16-bit integer
// ============================================================================
class SmallInt {
private:
    short value;

public:
    constexpr SmallInt() : value(0) {}
    constexpr SmallInt(short v) : value(v) {}
    constexpr SmallInt(int v) : value(static_cast<short>(v)) {}
    
    SmallInt& operator=(short v) {
        value = v;
        return *this;
    }
    
    SmallInt operator+(const SmallInt& other) const {
        return SmallInt(value + other.value);
    }
    
    SmallInt operator-(const SmallInt& other) const {
        return SmallInt(value - other.value);
    }
    
    SmallInt operator*(const SmallInt& other) const {
        return SmallInt(value * other.value);
    }
    
    Double operator/(const SmallInt& other) const;  // Forward declared
    
    SmallInt Div(const SmallInt& other) const {
        return SmallInt(value / other.value);
    }
    
    SmallInt Mod(const SmallInt& other) const {
        return SmallInt(value % other.value);
    }
    
    SmallInt operator-() const {
        return SmallInt(-value);
    }
    
    auto operator<=>(const SmallInt& other) const = default;
    bool operator==(const SmallInt& other) const = default;
    
    void Inc(int amount = 1) { value += amount; }
    void Dec(int amount = 1) { value -= amount; }
    
    short ToSmallInt() const { return value; }
    int ToInt() const { return static_cast<int>(value); }
    explicit operator short() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const SmallInt& s) {
        return os << s.value;
    }
    
    friend std::istream& operator>>(std::istream& is, SmallInt& s) {
        return is >> s.value;
    }
};

// ============================================================================
// Boolean - Wraps bool with Pascal semantics
// ============================================================================
class Boolean {
private:
    bool value;

public:
    constexpr Boolean() : value(false) {}
    constexpr Boolean(bool v) : value(v) {}
    
    Boolean& operator=(bool v) {
        value = v;
        return *this;
    }
    
    Boolean operator&&(const Boolean& other) const {
        return Boolean(value && other.value);
    }
    
    Boolean operator||(const Boolean& other) const {
        return Boolean(value || other.value);
    }
    
    Boolean operator!() const {
        return Boolean(!value);
    }
    
    // Bitwise operators (for compatibility with integer-style operations)
    Boolean operator&(const Boolean& other) const {
        return Boolean(value & other.value);
    }
    
    Boolean operator|(const Boolean& other) const {
        return Boolean(value | other.value);
    }
    
    Boolean operator^(const Boolean& other) const {
        return Boolean(value != other.value);
    }
    
    Boolean operator~() const {
        return Boolean(!value);
    }
    
    Boolean Xor(const Boolean& other) const {
        return Boolean(value != other.value);
    }
    
    auto operator<=>(const Boolean& other) const = default;
    bool operator==(const Boolean& other) const = default;
    
    bool ToBool() const { return value; }
    explicit operator bool() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const Boolean& b) {
        return os << (b.value ? "True" : "False");
    }
};

// ============================================================================
// Pointer - Wraps void* with Pascal semantics
// ============================================================================
class Pointer {
private:
    void* value;

public:
    constexpr Pointer() : value(nullptr) {}
    constexpr Pointer(void* v) : value(v) {}
    constexpr Pointer(std::nullptr_t) : value(nullptr) {}
    
    // Constructor from Integer (for Pointer(intValue) patterns)
    Pointer(const Integer& intValue) : value(reinterpret_cast<void*>(static_cast<std::uintptr_t>(intValue.ToInt()))) {}
    Pointer(int intValue) : value(reinterpret_cast<void*>(static_cast<std::uintptr_t>(intValue))) {}
    
    // Constructor from UInt64 (for Pointer(uint64Value) patterns - no truncation on 64-bit)
    Pointer(const UInt64& uint64Value) : value(reinterpret_cast<void*>(static_cast<std::uintptr_t>(uint64Value.ToUInt64()))) {}
    Pointer(unsigned long long uint64Value) : value(reinterpret_cast<void*>(static_cast<std::uintptr_t>(uint64Value))) {}
    
    Pointer& operator=(void* v) {
        value = v;
        return *this;
    }
    
    Pointer& operator=(std::nullptr_t) {
        value = nullptr;
        return *this;
    }
    
    // Comparison operators
    bool operator==(const Pointer& other) const {
        return value == other.value;
    }
    
    bool operator!=(const Pointer& other) const {
        return value != other.value;
    }
    
    bool operator==(std::nullptr_t) const {
        return value == nullptr;
    }
    
    bool operator!=(std::nullptr_t) const {
        return value != nullptr;
    }
    
    // Spaceship operator for ordering
    auto operator<=>(const Pointer& other) const {
        return value <=> other.value;
    }
    
    // Dereference operator (Pascal Ptr^ syntax)
    // Returns a reference to Byte for generic pointer dereferencing
    Byte& operator*() const {
        return *static_cast<Byte*>(value);
    }
    
    // Pointer arithmetic (for Integer(Ptr) + offset patterns)
    Pointer operator+(int offset) const {
        return Pointer(static_cast<char*>(value) + offset);
    }
    
    Pointer operator+(const Integer& offset) const {
        return Pointer(static_cast<char*>(value) + offset.ToInt());
    }
    
    Pointer operator-(int offset) const {
        return Pointer(static_cast<char*>(value) - offset);
    }
    
    Pointer operator-(const Integer& offset) const {
        return Pointer(static_cast<char*>(value) - offset.ToInt());
    }
    
    // Pointer arithmetic with UInt64 (for 64-bit safe pointer arithmetic)
    Pointer operator+(const UInt64& offset) const {
        return Pointer(static_cast<char*>(value) + offset.ToUInt64());
    }
    
    Pointer operator-(const UInt64& offset) const {
        return Pointer(static_cast<char*>(value) - offset.ToUInt64());
    }
    
    // Conversion
    void* ToVoidPtr() const { return value; }
    
    // Conversion to Integer (for Integer(Ptr) patterns - gets pointer address as integer)
    // NOTE: On 64-bit systems, this may truncate the address, but it matches Delphi behavior
    // where Integer is 32-bit. For full address, Delphi would use NativeInt.
    operator Integer() const { 
        return Integer(static_cast<int>(reinterpret_cast<std::uintptr_t>(value))); 
    }
    
    // Conversion to UInt64 (for UInt64(Ptr) patterns - NO truncation on 64-bit systems)
    operator UInt64() const {
        return UInt64(reinterpret_cast<std::uintptr_t>(value));
    }
    
    // CRITICAL: Implicit conversion to void* (Delphi Pointer semantics)
    // This allows Pointer to be passed to functions expecting void*
    operator void*() const { return value; }
    
    explicit operator bool() const { return value != nullptr; }
    
    friend std::ostream& operator<<(std::ostream& os, const Pointer& p) {
        if (p.value == nullptr) {
            os << "nil";
        } else {
            os << p.value;
        }
        return os;
    }
};

// ============================================================================
// Single - 32-bit floating point (Pascal Single type)
// ============================================================================
class Single {
private:
    float value;

public:
    Single() : value(0.0f) {}
    Single(float v) : value(v) {}
    Single(int v) : value(static_cast<float>(v)) {}
    
    Single& operator=(float v) {
        value = v;
        return *this;
    }
    
    Single operator+(const Single& other) const {
        return Single(value + other.value);
    }
    
    Single operator-(const Single& other) const {
        return Single(value - other.value);
    }
    
    Single operator*(const Single& other) const {
        return Single(value * other.value);
    }
    
    Single operator/(const Single& other) const {
        return Single(value / other.value);
    }
    
    Single operator-() const {
        return Single(-value);
    }
    
    auto operator<=>(const Single& other) const = default;
    bool operator==(const Single& other) const = default;
    
    float ToFloat() const { return value; }
    explicit operator float() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const Single& s) {
        return os << s.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Single& s) {
        return is >> s.value;
    }
};

// ============================================================================
// Double - 64-bit floating point (Pascal Double type)
// ============================================================================
class Double {
private:
    double value;

public:
    Double() : value(0.0) {}
    Double(double v) : value(v) {}
    Double(int v) : value(static_cast<double>(v)) {}
    Double(float v) : value(static_cast<double>(v)) {}
    Double(long long v) : value(static_cast<double>(v)) {}
    Double(const Integer& i) : value(static_cast<double>(i.ToInt())) {}
    Double(const Int64& i) : value(static_cast<double>(i.ToInt64())) {}
    
    Double& operator=(double v) {
        value = v;
        return *this;
    }
    
    Double& operator=(int v) {
        value = static_cast<double>(v);
        return *this;
    }
    
    Double& operator=(long long v) {
        value = static_cast<double>(v);
        return *this;
    }
    
    Double& operator=(const Integer& i) {
        value = static_cast<double>(i.ToInt());
        return *this;
    }
    
    Double& operator=(const Int64& i) {
        value = static_cast<double>(i.ToInt64());
        return *this;
    }
    
    Double operator+(const Double& other) const {
        return Double(value + other.value);
    }
    
    Double operator+(int other) const {
        return Double(value + static_cast<double>(other));
    }
    
    Double operator+(double other) const {
        return Double(value + other);
    }
    
    Double operator-(const Double& other) const {
        return Double(value - other.value);
    }
    
    Double operator-(int other) const {
        return Double(value - static_cast<double>(other));
    }
    
    Double operator-(double other) const {
        return Double(value - other);
    }
    
    Double operator*(const Double& other) const {
        return Double(value * other.value);
    }
    
    Double operator*(int other) const {
        return Double(value * static_cast<double>(other));
    }
    
    Double operator*(double other) const {
        return Double(value * other);
    }
    
    Double operator/(const Double& other) const {
        return Double(value / other.value);
    }
    
    Double operator/(int other) const {
        return Double(value / static_cast<double>(other));
    }
    
    Double operator/(double other) const {
        return Double(value / other);
    }
    
    Double operator-() const {
        return Double(-value);
    }
    
    auto operator<=>(const Double& other) const = default;
    bool operator==(const Double& other) const = default;
    
    double ToDouble() const { return value; }
    explicit operator double() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const Double& d) {
        return os << d.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Double& d) {
        return is >> d.value;
    }
};

// Now define Integer::operator/ (returns Double)
inline Double Integer::operator/(const Integer& other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other.value));
}

inline Double Integer::operator/(int other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other));
}

inline Double Integer::operator*(double other) const {
    return Double(static_cast<double>(value) * other);
}

inline Double Int64::operator/(const Int64& other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other.value));
}

inline Double Int64::operator/(int other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other));
}

inline Double Int64::operator/(long long other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other));
}

inline Double Int64::operator/(double other) const {
    return Double(static_cast<double>(value) / other);
}

inline Double Int64::operator*(double other) const {
    return Double(static_cast<double>(value) * other);
}

inline Double Cardinal::operator/(const Cardinal& other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other.value));
}

inline Double Byte::operator/(const Byte& other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other.value));
}

inline Double Word::operator/(const Word& other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other.value));
}

inline Double ShortInt::operator/(const ShortInt& other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other.value));
}

inline Double SmallInt::operator/(const SmallInt& other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other.value));
}

inline Double UInt64::operator/(const UInt64& other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other.value));
}

// ============================================================================
// Extended - 80-bit floating point (Pascal Extended type)
// ============================================================================
class Extended {
private:
    long double value;

public:
    Extended() : value(0.0L) {}
    Extended(long double v) : value(v) {}
    Extended(double v) : value(static_cast<long double>(v)) {}
    Extended(float v) : value(static_cast<long double>(v)) {}
    Extended(int v) : value(static_cast<long double>(v)) {}
    
    Extended& operator=(long double v) {
        value = v;
        return *this;
    }
    
    Extended operator+(const Extended& other) const {
        return Extended(value + other.value);
    }
    
    Extended operator-(const Extended& other) const {
        return Extended(value - other.value);
    }
    
    Extended operator*(const Extended& other) const {
        return Extended(value * other.value);
    }
    
    Extended operator/(const Extended& other) const {
        return Extended(value / other.value);
    }
    
    Extended operator-() const {
        return Extended(-value);
    }
    
    auto operator<=>(const Extended& other) const = default;
    bool operator==(const Extended& other) const = default;
    
    long double ToLongDouble() const { return value; }
    explicit operator long double() const { return value; }
    
    friend std::ostream& operator<<(std::ostream& os, const Extended& e) {
        return os << e.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Extended& e) {
        return is >> e.value;
    }
};

// Mixed-type operations (Delphi type promotion rules)
inline Double operator+(const Single& a, const Double& b) {
    return Double(a.ToFloat()) + b;
}

inline Double operator+(const Double& a, const Single& b) {
    return a + Double(b.ToFloat());
}

inline Extended operator+(const Single& a, const Extended& b) {
    return Extended(a.ToFloat()) + b;
}

inline Extended operator+(const Extended& a, const Single& b) {
    return a + Extended(b.ToFloat());
}

inline Extended operator+(const Double& a, const Extended& b) {
    return Extended(a.ToDouble()) + b;
}

inline Extended operator+(const Extended& a, const Double& b) {
    return a + Extended(b.ToDouble());
}

// Mixed-type operations for Double with Integer types
inline Double operator+(const Double& a, const Integer& b) {
    return Double(a.ToDouble() + static_cast<double>(b.ToInt()));
}

inline Double operator+(const Integer& a, const Double& b) {
    return Double(static_cast<double>(a.ToInt()) + b.ToDouble());
}

inline Double operator+(const Double& a, const Int64& b) {
    return Double(a.ToDouble() + static_cast<double>(b.ToInt64()));
}

inline Double operator+(const Int64& a, const Double& b) {
    return Double(static_cast<double>(a.ToInt64()) + b.ToDouble());
}

inline Double operator-(const Double& a, const Integer& b) {
    return Double(a.ToDouble() - static_cast<double>(b.ToInt()));
}

inline Double operator-(const Integer& a, const Double& b) {
    return Double(static_cast<double>(a.ToInt()) - b.ToDouble());
}

inline Double operator-(const Double& a, const Int64& b) {
    return Double(a.ToDouble() - static_cast<double>(b.ToInt64()));
}

inline Double operator-(const Int64& a, const Double& b) {
    return Double(static_cast<double>(a.ToInt64()) - b.ToDouble());
}

inline Double operator*(const Double& a, const Integer& b) {
    return Double(a.ToDouble() * static_cast<double>(b.ToInt()));
}

inline Double operator*(const Integer& a, const Double& b) {
    return Double(static_cast<double>(a.ToInt()) * b.ToDouble());
}

inline Double operator*(const Double& a, const Int64& b) {
    return Double(a.ToDouble() * static_cast<double>(b.ToInt64()));
}

inline Double operator*(const Int64& a, const Double& b) {
    return Double(static_cast<double>(a.ToInt64()) * b.ToDouble());
}

inline Double operator/(const Double& a, const Integer& b) {
    return Double(a.ToDouble() / static_cast<double>(b.ToInt()));
}

inline Double operator/(const Integer& a, const Double& b) {
    return Double(static_cast<double>(a.ToInt()) / b.ToDouble());
}

inline Double operator/(const Double& a, const Int64& b) {
    return Double(a.ToDouble() / static_cast<double>(b.ToInt64()));
}

inline Double operator/(const Int64& a, const Double& b) {
    return Double(static_cast<double>(a.ToInt64()) / b.ToDouble());
}

// Mixed-type operations for Integer and Int64
inline Int64 operator+(const Integer& a, const Int64& b) {
    return Int64(static_cast<long long>(a.ToInt()) + b.ToInt64());
}

inline Int64 operator+(const Int64& a, const Integer& b) {
    return Int64(a.ToInt64() + static_cast<long long>(b.ToInt()));
}

inline Int64 operator-(const Integer& a, const Int64& b) {
    return Int64(static_cast<long long>(a.ToInt()) - b.ToInt64());
}

inline Int64 operator-(const Int64& a, const Integer& b) {
    return Int64(a.ToInt64() - static_cast<long long>(b.ToInt()));
}

inline Int64 operator*(const Integer& a, const Int64& b) {
    return Int64(static_cast<long long>(a.ToInt()) * b.ToInt64());
}

inline Int64 operator*(const Int64& a, const Integer& b) {
    return Int64(a.ToInt64() * static_cast<long long>(b.ToInt()));
}

// ============================================================================
// Char - Wraps char16_t with Pascal semantics (UTF-16, cross-platform)
// ============================================================================
class Char {
private:
    char16_t value;

public:
    Char() : value(u'\0') {}
    Char(char16_t v) : value(v) {}
    
    // Support narrow char for compatibility
    Char(char v) : value(static_cast<char16_t>(v)) {}
    
    // Support wchar_t for platform interop
    Char(wchar_t v) : value(static_cast<char16_t>(v)) {}
    
    // Support wide string literals - takes first character (Pascal string-to-char conversion)
    Char(const wchar_t* s) : value(s && s[0] ? static_cast<char16_t>(s[0]) : u'\0') {}
    
    // Support int for Char(integer_expression) patterns
    Char(int v) : value(static_cast<char16_t>(v)) {}
    
    // Support bp::Integer for Char(Integer_expression) patterns
    Char(const Integer& v) : value(static_cast<char16_t>(v.ToInt())) {}
    
    Char& operator=(char16_t v) {
        value = v;
        return *this;
    }
    
    Char& operator=(char v) {
        value = static_cast<char16_t>(v);
        return *this;
    }
    
    Char& operator=(wchar_t v) {
        value = static_cast<char16_t>(v);
        return *this;
    }
    
    Char& operator=(const wchar_t* s) {
        value = (s && s[0]) ? static_cast<char16_t>(s[0]) : u'\0';
        return *this;
    }
    
    auto operator<=>(const Char& other) const = default;
    bool operator==(const Char& other) const = default;
    
    // Comparison with wchar_t* string literals (takes first character)
    bool operator==(const wchar_t* s) const {
        return (s && s[0]) ? (value == static_cast<char16_t>(s[0])) : (value == u'\0');
    }
    
    bool operator!=(const wchar_t* s) const {
        return !(*this == s);
    }
    
    // Comparison with narrow char
    bool operator==(char c) const {
        return value == static_cast<char16_t>(c);
    }
    
    bool operator!=(char c) const {
        return value != static_cast<char16_t>(c);
    }
    
    char16_t ToChar16() const { return value; }
    explicit operator char16_t() const { return value; }
    
    // Legacy narrow char support
    char ToChar() const { return static_cast<char>(value); }
    
    // Platform wchar_t support - implicit conversion for runtime compatibility
    operator wchar_t() const { return static_cast<wchar_t>(value); }
    wchar_t ToWChar() const { return static_cast<wchar_t>(value); }
    
    friend std::ostream& operator<<(std::ostream& os, const Char& c) {
        os << static_cast<char>(c.value);
        return os;
    }
};

// ============================================================================
// String - Wraps std::u16string with Pascal 1-based indexing (UTF-16, cross-platform)
// ============================================================================
class String {
private:
    std::u16string data;
    mutable std::wstring wideCache;  // For c_str_wide() platform interop

public:
    String() = default;
    String(const char16_t* s) : data(s) {}
    String(const std::u16string& s) : data(s) {}
    String(char16_t c) : data(1, c) {}
    
    // Support narrow string literals for compatibility (ASCII subset)
    String(const char* s) {
        data.reserve(strlen(s));
        for (size_t i = 0; s[i] != '\0'; ++i) {
            data += static_cast<char16_t>(static_cast<unsigned char>(s[i]));
        }
    }
    
    // Support wide string literals for platform interop
    String(const wchar_t* s) {
        while (*s) {
            data += static_cast<char16_t>(*s++);
        }
    }
    
    String(const std::wstring& s) {
        data.reserve(s.length());
        for (wchar_t wc : s) {
            data += static_cast<char16_t>(wc);
        }
    }
    
    String& operator=(const char16_t* s) {
        data = s;
        return *this;
    }
    
    String& operator=(const std::u16string& s) {
        data = s;
        return *this;
    }
    
    String& operator=(char16_t c) {
        data = std::u16string(1, c);
        return *this;
    }
    
    String& operator=(const char* s) {
        data.clear();
        data.reserve(strlen(s));
        for (size_t i = 0; s[i] != '\0'; ++i) {
            data += static_cast<char16_t>(static_cast<unsigned char>(s[i]));
        }
        return *this;
    }
    
    // Concatenation (binary + for occasional use)
    String operator+(const String& other) const {
        return String(data + other.data);
    }
    
    String operator+(const char16_t* other) const {
        return String(data + other);
    }
    
    String operator+(char16_t c) const {
        return String(data + c);
    }
    
    // OPTIMIZED: In-place concatenation (PREFERRED!)
    String& operator+=(const String& other) {
        data += other.data;
        return *this;
    }
    
    String& operator+=(const char16_t* other) {
        data += other;
        return *this;
    }
    
    String& operator+=(char16_t c) {
        data += c;
        return *this;
    }
    
    // Friend operators for literal + String (handles L"...", u"...", and "..." literals)
    friend String operator+(const wchar_t* lhs, const String& rhs) {
        String result(lhs);
        result.data += rhs.data;
        return result;
    }
    
    friend String operator+(const char16_t* lhs, const String& rhs) {
        String result(lhs);
        result.data += rhs.data;
        return result;
    }
    
    friend String operator+(const char* lhs, const String& rhs) {
        String result(lhs);
        result.data += rhs.data;
        return result;
    }
    
    auto operator<=>(const String& other) const = default;
    bool operator==(const String& other) const = default;
    
    // 1-based indexing (CRITICAL: Pascal semantics!)
    // Returns Char by value to enable comparison operators
    Char operator[](int index) const {
        return Char(data[index - 1]);
    }
    
    Char operator[](const Integer& index) const {
        return Char(data[index.ToInt() - 1]);
    }
    
    // For write access, provide SetChar method
    void SetChar(int index, const Char& ch) {
        data[index - 1] = ch.ToChar16();
    }
    
    void SetChar(int index, char16_t ch) {
        data[index - 1] = ch;
    }
    
    // Properties
    int Length() const { return static_cast<int>(data.length()); }
    
    void SetLength(int newlen) {
        data.resize(newlen);
    }
    
    // Cross-platform API interop - returns wchar_t* for platform-specific APIs
    const wchar_t* c_str_wide() const {
#ifdef _WIN32
        // On Windows, wchar_t is 16-bit, direct cast is safe
        return reinterpret_cast<const wchar_t*>(data.c_str());
#else
        // On Linux/macOS, wchar_t is 32-bit, need conversion
        wideCache.clear();
        wideCache.reserve(data.size());
        for (char16_t ch : data) {
            wideCache += static_cast<wchar_t>(ch);
        }
        return wideCache.c_str();
#endif
    }
    
    // UTF-16 pointer (cross-platform consistent)
    const char16_t* c_str() const { return data.c_str(); }
    
    // UTF-8 conversion for proper console/exception output
    std::string ToUTF8() const {
        std::string result;
        size_t i = 0;
        while (i < data.size()) {
            uint32_t codepoint = data[i];
            
            // Handle surrogate pairs
            if (codepoint >= 0xD800 && codepoint <= 0xDBFF && i + 1 < data.size()) {
                uint32_t high = codepoint;
                uint32_t low = data[i + 1];
                if (low >= 0xDC00 && low <= 0xDFFF) {
                    codepoint = 0x10000 + ((high - 0xD800) << 10) + (low - 0xDC00);
                    i += 2;
                } else {
                    i++;
                    continue;
                }
            } else {
                i++;
            }
            
            // Convert codepoint to UTF-8
            if (codepoint <= 0x7F) {
                result += static_cast<char>(codepoint);
            } else if (codepoint <= 0x7FF) {
                result += static_cast<char>(0xC0 | (codepoint >> 6));
                result += static_cast<char>(0x80 | (codepoint & 0x3F));
            } else if (codepoint <= 0xFFFF) {
                result += static_cast<char>(0xE0 | (codepoint >> 12));
                result += static_cast<char>(0x80 | ((codepoint >> 6) & 0x3F));
                result += static_cast<char>(0x80 | (codepoint & 0x3F));
            } else {
                result += static_cast<char>(0xF0 | (codepoint >> 18));
                result += static_cast<char>(0x80 | ((codepoint >> 12) & 0x3F));
                result += static_cast<char>(0x80 | ((codepoint >> 6) & 0x3F));
                result += static_cast<char>(0x80 | (codepoint & 0x3F));
            }
        }
        return result;
    }
    
    // C API interop - returns const char* (UTF-8) for C APIs that expect narrow strings
    // Uses thread-local storage to keep the string alive during the function call
    const char* ToCharPtr() const;
    
    // Legacy narrow string support (converts on demand, ASCII subset)
    std::string ToNarrow() const {
        std::string result;
        result.reserve(data.length());
        for (char16_t c : data) {
            result += static_cast<char>(c);
        }
        return result;
    }
    
    // Access internal std::u16string
    const std::u16string& GetStdU16String() const { return data; }
    std::u16string& GetStdU16String() { return data; }
    
    friend std::ostream& operator<<(std::ostream& os, const String& s) {
        os << s.ToUTF8();
        return os;
    }
};

// ============================================================================
// Array<T> - Dynamic array template with Pascal semantics
// ============================================================================
template<typename T>
class Array {
private:
    std::vector<T> data;

public:
    Array() = default;
    explicit Array(int size) : data(size) {}
    Array(int size, const T& initial_value) : data(size, initial_value) {}
    
    // Element access (0-based - Pascal dynamic arrays are 0-based)
    T& operator[](int index) {
        return data[index];
    }
    
    const T& operator[](int index) const {
        return data[index];
    }
    
    // Overloads for wrapped integer types (implicit conversion support)
    T& operator[](const Integer& index) {
        return data[index.ToInt()];
    }
    
    const T& operator[](const Integer& index) const {
        return data[index.ToInt()];
    }
    
    T& operator[](const Int64& index) {
        return data[static_cast<int>(index.ToInt64())];
    }
    
    const T& operator[](const Int64& index) const {
        return data[static_cast<int>(index.ToInt64())];
    }
    
    T& operator[](const Cardinal& index) {
        return data[static_cast<int>(index.ToCardinal())];
    }
    
    const T& operator[](const Cardinal& index) const {
        return data[static_cast<int>(index.ToCardinal())];
    }
    
    T& operator[](const Byte& index) {
        return data[index.ToInt()];
    }
    
    const T& operator[](const Byte& index) const {
        return data[index.ToInt()];
    }
    
    T& operator[](const Word& index) {
        return data[index.ToInt()];
    }
    
    const T& operator[](const Word& index) const {
        return data[index.ToInt()];
    }
    
    T& operator[](const ShortInt& index) {
        return data[index.ToInt()];
    }
    
    const T& operator[](const ShortInt& index) const {
        return data[index.ToInt()];
    }
    
    T& operator[](const SmallInt& index) {
        return data[index.ToInt()];
    }
    
    const T& operator[](const SmallInt& index) const {
        return data[index.ToInt()];
    }
    
    T& operator[](const UInt64& index) {
        return data[static_cast<int>(index.ToUInt64())];
    }
    
    const T& operator[](const UInt64& index) const {
        return data[static_cast<int>(index.ToUInt64())];
    }
    
    // Array properties
    int Length() const { return static_cast<int>(data.size()); }
    int High() const { return static_cast<int>(data.size()) - 1; }
    int Low() const { return 0; }
    
    // Resize
    void SetLength(int newlen) {
        data.resize(newlen);
    }
    
    void SetLength(int newlen, const T& value) {
        data.resize(newlen, value);
    }
    
    // Access internal vector if needed
    std::vector<T>& GetVector() { return data; }
    const std::vector<T>& GetVector() const { return data; }
    
    auto operator<=>(const Array<T>& other) const = default;
    bool operator==(const Array<T>& other) const = default;
};

// ============================================================================
// StaticArray<T, N> - Static array wrapper with Pascal semantics
// Wraps std::array but provides operator[] overloads for wrapped integer types
// ============================================================================
template<typename T, std::size_t N>
class StaticArray : public std::array<T, N> {
public:
    using std::array<T, N>::operator[];  // Inherit base operator[]
    
    // Overloads for wrapped integer types (implicit conversion support)
    T& operator[](const Integer& index) {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    const T& operator[](const Integer& index) const {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    T& operator[](const Int64& index) {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt64()));
    }
    
    const T& operator[](const Int64& index) const {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt64()));
    }
    
    T& operator[](const Cardinal& index) {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToCardinal()));
    }
    
    const T& operator[](const Cardinal& index) const {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToCardinal()));
    }
    
    T& operator[](const Byte& index) {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    const T& operator[](const Byte& index) const {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    T& operator[](const Word& index) {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    const T& operator[](const Word& index) const {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    T& operator[](const ShortInt& index) {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    const T& operator[](const ShortInt& index) const {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    T& operator[](const SmallInt& index) {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    const T& operator[](const SmallInt& index) const {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToInt()));
    }
    
    T& operator[](const UInt64& index) {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToUInt64()));
    }
    
    const T& operator[](const UInt64& index) const {
        return std::array<T, N>::operator[](static_cast<std::size_t>(index.ToUInt64()));
    }
};

// ============================================================================
// Set - Wraps std::bitset with Pascal set semantics
// Template parameters Low and High define the set range (currently unused,
// but required for transpiler compatibility: bp::Set<0, 9>)
// ============================================================================
template<int Low = 0, int High = 255>
class Set {
private:
    std::bitset<256> bits;

public:
    Set() = default;
    
    // Include/Exclude
    void Include(int element) {
        if (element >= 0 && element < 256)
            bits.set(element);
    }
    
    void Exclude(int element) {
        if (element >= 0 && element < 256)
            bits.reset(element);
    }
    
    // Test membership (Pascal 'in' operator)
    bool Contains(int element) const {
        if (element >= 0 && element < 256)
            return bits.test(element);
        return false;
    }
    
    // Set operators
    Set operator+(const Set& other) const {
        Set result;
        result.bits = bits | other.bits;
        return result;
    }
    
    Set operator*(const Set& other) const {
        Set result;
        result.bits = bits & other.bits;
        return result;
    }
    
    Set operator-(const Set& other) const {
        Set result;
        result.bits = bits & ~other.bits;
        return result;
    }
    
    // Comparison operators - manual implementation since std::bitset doesn't support <=>
    bool operator==(const Set& other) const {
        return bits == other.bits;
    }
    
    bool operator!=(const Set& other) const {
        return bits != other.bits;
    }
    
    bool operator<(const Set& other) const {
        // Lexicographic comparison of bitsets
        for (int i = 255; i >= 0; --i) {
            if (bits[i] != other.bits[i]) {
                return other.bits[i];  // true if other has bit, this doesn't
            }
        }
        return false;  // Equal sets
    }
    
    bool operator<=(const Set& other) const {
        return !(other < *this);
    }
    
    bool operator>(const Set& other) const {
        return other < *this;
    }
    
    bool operator>=(const Set& other) const {
        return !(*this < other);
    }
    
    // Subset/Superset
    bool IsSubsetOf(const Set& other) const {
        return (bits & ~other.bits).none();
    }
    
    bool IsSupersetOf(const Set& other) const {
        return (other.bits & ~bits).none();
    }
};

// Set construction helpers
template<int Low = 0, int High = 255>
inline Set<Low, High> MakeSet(std::initializer_list<int> elements) {
    Set<Low, High> s;
    for (int e : elements) s.Include(e);
    return s;
}

template<int Low = 0, int High = 255>
inline Set<Low, High> MakeSetRange(int low, int high) {
    Set<Low, High> s;
    for (int i = low; i <= high; i++) s.Include(i);
    return s;
}

// ============================================================================
// Free function wrappers for Pascal-style set operations
// These match the transpiler's generated code:
//   bp::Include(s, 1)  ->  s.Include(1)
//   bp::Exclude(s, 3)  ->  s.Exclude(3)
//   bp::InSet(s, 5)    ->  s.Contains(5)
// ============================================================================
template<int Low, int High>
inline void Include(Set<Low, High>& s, int element) {
    s.Include(element);
}

template<int Low, int High>
inline void Exclude(Set<Low, High>& s, int element) {
    s.Exclude(element);
}

template<int Low, int High>
inline bool InSet(const Set<Low, High>& s, int element) {
    return s.Contains(element);
}

// Overloads for bp::Integer to reduce ambiguity in transpiled code
template<int Low, int High>
inline void Include(Set<Low, High>& s, const Integer& element) {
    s.Include(element.ToInt());
}

template<int Low, int High>
inline void Exclude(Set<Low, High>& s, const Integer& element) {
    s.Exclude(element.ToInt());
}

template<int Low, int High>
inline bool InSet(const Set<Low, High>& s, const Integer& element) {
    return s.Contains(element.ToInt());
}

} // namespace bp
