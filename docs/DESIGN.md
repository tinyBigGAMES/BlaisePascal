# Blaise Pascal-to-C++ Transpiler Design Document

**Version:** 6.1  
**Date:** 2025-10-20  
**Target:** C++23 (LLVM 20.1.8+ with excellent support)  
**Purpose:** Definitive blueprint for transpiler architecture and runtime design

---

## THE LAW

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║  WRAP EVERYTHING THAT CAN BE WRAPPED IN THE C++ RUNTIME       ║
║                                                               ║
║  Make the transpiler DUMB.                                    ║
║  Make the runtime SMART.                                      ║
║                                                               ║
║  All runtime lives in namespace bp { ... }                    ║
║  ALWAYS use fully-qualified names: bp::Integer, bp::WriteLn   ║
║  NEVER use 'using namespace bp;'                              ║
║                                                               ║
║  String concatenation MUST use += for efficiency              ║
║                                                               ║
║  ALL runtime semantics MUST match Delphi exactly              ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### The Principle

Every Pascal type, operator, and function that has specific Pascal semantics is wrapped in a C++ class or function in the `bp` namespace.

**The transpiler is nothing more than a token mapper:**
- Walk AST
- Map Pascal tokens → C++ tokens
- ALWAYS emit fully-qualified `bp::` names
- Emit #line directives
- That's it!

**ALL semantic complexity lives in the C++23 runtime library in namespace bp.**

**NO `using namespace bp;` in generated code** - prevents contamination and makes runtime vs user code crystal clear.

---

## 1. Core Architecture

### Three-Layer Design

```
┌─────────────────────────────────────────┐
│   Pascal Source Code                    │
└─────────────────────────────────────────┘
                    ↓
         ┌──────────────────────┐
         │     DelphiAST        │ (Parsing)
         └──────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│   Transpiler (TOKEN MAPPER ONLY)        │
│   • Walk AST nodes                      │
│   • Map Pascal → C++ tokens             │
│   • Emit fully-qualified bp:: names     │
│   • Emit #line directives               │
│   • NO semantic knowledge               │
│   • NO transformations                  │
│   • NO validation                       │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│   Generated C++ Code                    │
│   • NO 'using namespace bp;'            │
│   • Fully-qualified bp::Integer, etc.   │
│   • Calls bp::WriteLn(), etc.           │
│   • Natural C++ syntax                  │
│   • #line directives                    │
└─────────────────────────────────────────┘
                    ↓
         ┌──────────────────────┐
         │  C++23 Compiler      │ (Validation)
         └──────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│   Runtime Library (ALL SEMANTICS)       │
│   • namespace bp { ... }                │
│   • Wrapped types (classes)             │
│   • C++23 features (<=>, std::println)  │
│   • Operators overloaded                │
│   • Lambda wrappers                     │
│   • ALL Pascal behavior                 │
└─────────────────────────────────────────┘
```

### Key Principles

1. **Wrap Everything Possible**
   - All Pascal types → C++ wrapper classes in `bp` namespace
   - All Pascal operators → C++ operators or methods
   - All control flow with Pascal semantics → Lambda wrappers
   - All Pascal functions → Runtime functions

2. **Transpiler = Dumb Token Mapper**
   - Just syntax transformation
   - No semantic analysis
   - No type checking (C++ compiler does it)
   - No validation (C++ compiler does it)
   - Small, simple, maintainable codebase

3. **Runtime = All Intelligence**
   - Implements ALL Pascal semantics
   - Lives in `namespace bp`
   - Can be complex internally
   - Uses C++23 features (spaceship, std::println, concepts)
   - Uses C++ STL (std::string, std::vector, std::bitset)
   - Tested independently

4. **Error Mapping via #line**
   - C++ errors reference Pascal source
   - Debugger works on Pascal code
   - No need for transpiler validation

5. **Namespace Isolation**
   - All runtime in `namespace bp { ... }`
   - No naming conflicts with external libraries (raylib, SDL, etc.)
   - Generated code uses fully-qualified names (bp::Integer, bp::WriteLn)
   - NEVER emit `using namespace bp;` - prevents any contamination

---

## 2. What Gets Wrapped vs Direct Emission

### Wrapped in Runtime (Pascal Semantics)

✅ **All Pascal primitive types in `namespace bp`:**
- `Integer` → `bp::Integer` class
- `Boolean` → `bp::Boolean` class
- `Single` → `bp::Single` class (32-bit float)
- `Double` → `bp::Double` class (64-bit double)
- `Extended` → `bp::Extended` class (80-bit long double)
- `Char` → `bp::Char` class
- `Byte`/`Word`/etc. → Wrapped classes
- `String` → `bp::String` class
- `array of T` → `bp::Array<T>` template
- `set of T` → `bp::Set` class

✅ **All Pascal-specific operators:**
- `div` → Method on Integer
- `mod` → Method on Integer
- `/` on integers → Returns Double (Delphi semantic!)
- `in` (sets) → Method on Set
- String concatenation → operator+= on String (in-place)

✅ **All control flow with Pascal semantics:**
- `for..to` → `bp::PFor()` (evaluates end once)
- `for..downto` → `bp::PForDownto()` (evaluates end once)
- `repeat..until` → `bp::PRepeatUntil()` (condition inverted)

✅ **All Pascal RTL functions:**
- `WriteLn` → `bp::WriteLn()`
- `IntToStr`, `StrToInt` → Runtime functions
- `Inc`, `Dec` → Methods on wrapped types
- `Length`, `SetLength` → Methods on wrapped types
- File I/O → Runtime functions
- All SysUtils, DateUtils, etc.

### Direct Emission (Pure Structural C++)

❌ **Structural constructs (no special semantics):**
- `record` → `struct` (plain container, fields use wrapped types)
- `if..then..else` → Direct C++ `if/else`
- `while..do` → Direct C++ `while`
- Variable declarations → Direct (with wrapped types)
- Assignment `:=` → Direct C++ `=`
- Simple operators → Direct C++ operators (when no semantic difference)
- Return statements → Direct C++ `return`

---

## 3. Type Mapping - Complete Wrapping in namespace bp

### 3.1 All Primitive Types Are Wrapped

| Pascal Type | C++ Type (fully-qualified) | Internal Storage |
|-------------|----------------------------|------------------|
| `Integer` | `bp::Integer` | `int` |
| `Int64` | `bp::Int64` | `long long` |
| `Cardinal` | `bp::Cardinal` | `unsigned int` |
| `Byte` | `bp::Byte` | `unsigned char` |
| `Word` | `bp::Word` | `unsigned short` |
| `ShortInt` | `bp::ShortInt` | `signed char` |
| `SmallInt` | `bp::SmallInt` | `short` |
| `Boolean` | `bp::Boolean` | `bool` |
| `Single` | `bp::Single` | `float` |
| `Double` | `bp::Double` | `double` |
| `Extended` | `bp::Extended` | `long double` |
| `Char` | `bp::Char` | `char` |
| `String` | `bp::String` | `std::string` |

### 3.2 Floating-Point Type Semantics

**Modern Delphi has three floating-point types (NO Real type):**

| Type | Size | Precision | Significant Digits | Range |
|------|------|-----------|-------------------|-------|
| `Single` | 4 bytes | 32-bit IEEE-754 | ~7-8 digits | 1.5E-45 to 3.4E38 |
| `Double` | 8 bytes | 64-bit IEEE-754 | ~15-16 digits | 5.0E-324 to 1.7E308 |
| `Extended` | 10 bytes | 80-bit x87 FPU | ~19-20 digits | 3.6E-4951 to 1.1E4932 |

**Why Separate Classes:**
1. **Preserves Pascal type semantics** - Each type has distinct precision
2. **Correct precision in calculations** - Single stays Single, Double stays Double
3. **Memory efficiency** - Single arrays are half the size of Double arrays
4. **C library interop** - OpenGL/game engines expect `float*` for Single
5. **Performance** - Single operations are faster on some hardware

**Type Promotion Rules (matching Delphi):**
- Single → Double (widening, implicit, safe)
- Single → Extended (widening, implicit, safe)
- Double → Extended (widening, implicit, safe)
- Double → Single (narrowing, explicit cast required)
- Extended → Double (narrowing, explicit cast required)
- Extended → Single (narrowing, explicit cast required)

**Mixed-Type Arithmetic:**
When mixing types in expressions, Delphi promotes to the wider type:
- Single + Double → Double
- Single + Extended → Extended
- Double + Extended → Extended

**Integer Division Behavior:**
In Delphi, the `/` operator on integers returns `Double`:
```pascal
var
  a, b: Integer;
  r: Double;
begin
  a := 7;
  b := 2;
  r := a / b;  // r = 3.5 (Double result)
end.
```

This is implemented in `bp::Integer::operator/` returning `bp::Double`.

**Note on Extended:**
- On x86/x64 with proper compiler flags, `long double` is 80-bit
- On ARM and MSVC x64, `long double` may be 64-bit (same as `double`)
- The transpiler assumes target platform supports true 80-bit Extended
- Platform-specific handling may be needed for ARM targets

### 3.3 Structured Types

| Pascal Type | C++ Type | Notes |
|-------------|----------|-------|
| `array[N..M] of T` | `T[M-N+1]` | Static array, elements are wrapped |
| `array of T` | `bp::Array<T>` | Dynamic array, wrapped class |
| `record ... end` | `struct { ... }` | Plain struct, fields are wrapped |
| `set of T` | `bp::Set` | Wrapped class |
| `TextFile` | `bp::TextFile` | Wrapped class |
| `^T` | `T*` | Pointer (may wrap if needed) |

---

## 4. Complete Runtime Library (C++23)

### C++23 Features Used

**Key C++23 Features:**
- `std::print` / `std::println` - Cleaner than std::format + iostream
- `std` module support
- All C++20 features (spaceship, concepts, designated initializers)
- Better Unicode support in std::print

### 4.1 Namespace Declaration

```cpp
// runtime.h
#pragma once

#include <string>
#include <vector>
#include <bitset>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <print>    // C++23
#include <format>   // C++20

namespace bp {
    // All runtime types and functions here
}
```

### 4.2 Integer Class (C++23 with Spaceship)

```cpp
namespace bp {

class Integer {
private:
    int value;

public:
    // Constructors
    Integer() : value(0) {}
    Integer(int v) : value(v) {}
    
    // Assignment
    Integer& operator=(int v) {
        value = v;
        return *this;
    }
    
    // Arithmetic operators
    Integer operator+(const Integer& other) const {
        return Integer(value + other.value);
    }
    
    Integer operator-(const Integer& other) const {
        return Integer(value - other.value);
    }
    
    Integer operator*(const Integer& other) const {
        return Integer(value * other.value);
    }
    
    // Pascal '/' operator on integers returns Double (Delphi semantic!)
    Double operator/(const Integer& other) const;  // Forward declared
    
    // Pascal 'div' operator (integer division)
    Integer Div(const Integer& other) const {
        return Integer(value / other.value);
    }
    
    // Pascal 'mod' operator
    Integer Mod(const Integer& other) const {
        return Integer(value % other.value);
    }
    
    // Unary minus
    Integer operator-() const {
        return Integer(-value);
    }
    
    // C++20 spaceship operator - generates all 6 comparison operators!
    auto operator<=>(const Integer& other) const = default;
    bool operator==(const Integer& other) const = default;
    
    // Inc/Dec (Pascal intrinsics)
    void Inc(int amount = 1) { value += amount; }
    void Dec(int amount = 1) { value -= amount; }
    
    // Conversion
    int ToInt() const { return value; }
    operator int() const { return value; }  // Implicit conversion when needed
    
    // For I/O
    friend std::ostream& operator<<(std::ostream& os, const Integer& i) {
        return os << i.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Integer& i) {
        return is >> i.value;
    }
};

} // namespace bp
```

### 4.3 Boolean Class (C++23)

```cpp
namespace bp {

class Boolean {
private:
    bool value;

public:
    // Constructors
    Boolean() : value(false) {}
    Boolean(bool v) : value(v) {}
    
    // Assignment
    Boolean& operator=(bool v) {
        value = v;
        return *this;
    }
    
    // Logical operators
    Boolean operator&&(const Boolean& other) const {
        return Boolean(value && other.value);
    }
    
    Boolean operator||(const Boolean& other) const {
        return Boolean(value || other.value);
    }
    
    Boolean operator!() const {
        return Boolean(!value);
    }
    
    // XOR (Pascal xor operator)
    Boolean Xor(const Boolean& other) const {
        return Boolean(value != other.value);
    }
    
    // C++20 spaceship operator
    auto operator<=>(const Boolean& other) const = default;
    bool operator==(const Boolean& other) const = default;
    
    // Conversion
    bool ToBool() const { return value; }
    operator bool() const { return value; }  // For if statements
    
    // For I/O
    friend std::ostream& operator<<(std::ostream& os, const Boolean& b) {
        return os << (b.value ? "True" : "False");
    }
};

} // namespace bp
```

### 4.4 Single Class (C++23 - 32-bit Float)

```cpp
namespace bp {

class Single {
private:
    float value;

public:
    // Constructors
    Single() : value(0.0f) {}
    Single(float v) : value(v) {}
    Single(int v) : value(static_cast<float>(v)) {}
    
    // Assignment
    Single& operator=(float v) {
        value = v;
        return *this;
    }
    
    // Arithmetic operators
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
    
    // C++20 spaceship operator
    auto operator<=>(const Single& other) const = default;
    bool operator==(const Single& other) const = default;
    
    // Conversion
    float ToFloat() const { return value; }
    operator float() const { return value; }
    
    // For I/O
    friend std::ostream& operator<<(std::ostream& os, const Single& s) {
        return os << s.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Single& s) {
        return is >> s.value;
    }
};

} // namespace bp
```

### 4.5 Double Class (C++23 - 64-bit Float)

```cpp
namespace bp {

class Double {
private:
    double value;

public:
    // Constructors
    Double() : value(0.0) {}
    Double(double v) : value(v) {}
    Double(int v) : value(static_cast<double>(v)) {}
    Double(float v) : value(static_cast<double>(v)) {}  // Promotion from Single
    
    // Assignment
    Double& operator=(double v) {
        value = v;
        return *this;
    }
    
    // Arithmetic operators
    Double operator+(const Double& other) const {
        return Double(value + other.value);
    }
    
    Double operator-(const Double& other) const {
        return Double(value - other.value);
    }
    
    Double operator*(const Double& other) const {
        return Double(value * other.value);
    }
    
    Double operator/(const Double& other) const {
        return Double(value / other.value);
    }
    
    Double operator-() const {
        return Double(-value);
    }
    
    // C++20 spaceship operator
    auto operator<=>(const Double& other) const = default;
    bool operator==(const Double& other) const = default;
    
    // Conversion
    double ToDouble() const { return value; }
    operator double() const { return value; }
    
    // For I/O
    friend std::ostream& operator<<(std::ostream& os, const Double& d) {
        return os << d.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Double& d) {
        return is >> d.value;
    }
};

// Now we can define Integer::operator/ (returns Double, matching Delphi!)
inline Double Integer::operator/(const Integer& other) const {
    return Double(static_cast<double>(value) / static_cast<double>(other.value));
}

} // namespace bp
```

### 4.6 Extended Class (C++23 - 80-bit Float)

```cpp
namespace bp {

class Extended {
private:
    long double value;

public:
    // Constructors
    Extended() : value(0.0L) {}
    Extended(long double v) : value(v) {}
    Extended(double v) : value(static_cast<long double>(v)) {}  // Promotion from Double
    Extended(float v) : value(static_cast<long double>(v)) {}   // Promotion from Single
    Extended(int v) : value(static_cast<long double>(v)) {}
    
    // Assignment
    Extended& operator=(long double v) {
        value = v;
        return *this;
    }
    
    // Arithmetic operators
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
    
    // C++20 spaceship operator
    auto operator<=>(const Extended& other) const = default;
    bool operator==(const Extended& other) const = default;
    
    // Conversion
    long double ToLongDouble() const { return value; }
    operator long double() const { return value; }
    
    // For I/O
    friend std::ostream& operator<<(std::ostream& os, const Extended& e) {
        return os << e.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Extended& e) {
        return is >> e.value;
    }
};

// Mixed-type operations (Delphi type promotion rules)

// Single + Double → Double
inline Double operator+(const Single& a, const Double& b) {
    return Double(a.ToFloat()) + b;
}

inline Double operator+(const Double& a, const Single& b) {
    return a + Double(b.ToFloat());
}

// Single + Extended → Extended
inline Extended operator+(const Single& a, const Extended& b) {
    return Extended(a.ToFloat()) + b;
}

inline Extended operator+(const Extended& a, const Single& b) {
    return a + Extended(b.ToFloat());
}

// Double + Extended → Extended
inline Extended operator+(const Double& a, const Extended& b) {
    return Extended(a.ToDouble()) + b;
}

inline Extended operator+(const Extended& a, const Double& b) {
    return a + Extended(b.ToDouble());
}

// Similar operators for -, *, / would follow the same pattern

} // namespace bp
```

### 4.7 Char Class (C++23)

```cpp
namespace bp {

class Char {
private:
    char value;

public:
    // Constructors
    Char() : value('\0') {}
    Char(char v) : value(v) {}
    
    // Assignment
    Char& operator=(char v) {
        value = v;
        return *this;
    }
    
    // C++20 spaceship operator
    auto operator<=>(const Char& other) const = default;
    bool operator==(const Char& other) const = default;
    
    // Conversion
    char ToChar() const { return value; }
    operator char() const { return value; }
    
    // For I/O
    friend std::ostream& operator<<(std::ostream& os, const Char& c) {
        return os << c.value;
    }
    
    friend std::istream& operator>>(std::istream& is, Char& c) {
        return is >> c.value;
    }
};

} // namespace bp
```

### 4.8 String Class (C++23 with 1-based indexing and Optimization)

```cpp
namespace bp {

class String {
private:
    std::string data;

public:
    // Constructors
    String() = default;
    String(const char* s) : data(s) {}
    String(const std::string& s) : data(s) {}
    String(char c) : data(1, c) {}
    
    // Assignment
    String& operator=(const char* s) {
        data = s;
        return *this;
    }
    
    String& operator=(const std::string& s) {
        data = s;
        return *this;
    }
    
    String& operator=(char c) {
        data = std::string(1, c);
        return *this;
    }
    
    // Concatenation (binary + for occasional use)
    String operator+(const String& other) const {
        return String(data + other.data);
    }
    
    String operator+(const char* other) const {
        return String(data + other);
    }
    
    String operator+(char c) const {
        return String(data + c);
    }
    
    // OPTIMIZED: In-place concatenation (PREFERRED!)
    String& operator+=(const String& other) {
        data += other.data;  // std::string's efficient append
        return *this;
    }
    
    String& operator+=(const char* other) {
        data += other;
        return *this;
    }
    
    String& operator+=(char c) {
        data += c;
        return *this;
    }
    
    // C++20 spaceship operator
    auto operator<=>(const String& other) const = default;
    bool operator==(const String& other) const = default;
    
    // 1-based indexing (CRITICAL: Pascal semantics!)
    char& operator[](int index) {
        return data[index - 1];
    }
    
    const char& operator[](int index) const {
        return data[index - 1];
    }
    
    // Properties
    int Length() const { return static_cast<int>(data.length()); }
    
    void SetLength(int newlen) {
        data.resize(newlen);
    }
    
    // C API interop
    const char* c_str() const { return data.c_str(); }
    
    // Access internal std::string
    const std::string& GetStdString() const { return data; }
    
    // For I/O
    friend std::ostream& operator<<(std::ostream& os, const String& s) {
        return os << s.data;
    }
    
    friend std::istream& operator>>(std::istream& is, String& s) {
        return is >> s.data;
    }
};

// String manipulation functions
inline String Copy(const String& s, int index, int count) {
    return String(s.GetStdString().substr(index - 1, count));
}

inline void Delete(String& s, int index, int count) {
    std::string temp = s.GetStdString();
    temp.erase(index - 1, count);
    s = temp;
}

inline void Insert(const String& source, String& dest, int index) {
    std::string temp = dest.GetStdString();
    temp.insert(index - 1, source.c_str());
    dest = temp;
}

inline int Pos(const String& substr, const String& str) {
    size_t pos = str.GetStdString().find(substr.c_str());
    return (pos == std::string::npos) ? 0 : static_cast<int>(pos) + 1;  // 1-based
}

inline String UpperCase(const String& s) {
    std::string result = s.GetStdString();
    std::transform(result.begin(), result.end(), result.begin(), ::toupper);
    return String(result);
}

inline String LowerCase(const String& s) {
    std::string result = s.GetStdString();
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    return String(result);
}

} // namespace bp
```

### String Optimization Rules

**CRITICAL:** String concatenation MUST use `+=` for in-place operations to avoid unnecessary copies.

**Generated Code Pattern:**

```cpp
// Pascal: s := s + ' ' + name + '!';

// WRONG (creates temporary copies):
s = s + " " + name + "!";

// CORRECT (in-place operations):
s += " ";
s += name;
s += "!";
```

**Transpiler Rule:**
When encountering Pascal concatenation chains like `s := s + a + b + c`, the transpiler must generate:
```cpp
s += a;
s += b;
s += c;
```

NOT:
```cpp
s = s + a + b + c;  // Inefficient!
```

### 4.9 Array<T> Template (C++23)

```cpp
namespace bp {

template<typename T>
class Array {
private:
    std::vector<T> data;

public:
    // Constructors
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
    
    // C++20 spaceship
    auto operator<=>(const Array<T>& other) const = default;
    bool operator==(const Array<T>& other) const = default;
};

// Array copy
template<typename T>
inline Array<T> Copy(const Array<T>& arr, int index, int count) {
    Array<T> result(count);
    for (int i = 0; i < count; i++) {
        result[i] = arr[index + i];
    }
    return result;
}

} // namespace bp
```

### 4.10 Set Class (C++23)

```cpp
namespace bp {

class Set {
private:
    std::bitset<256> bits;

public:
    // Constructors
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
    Set operator+(const Set& other) const {  // Union
        Set result;
        result.bits = bits | other.bits;
        return result;
    }
    
    Set operator*(const Set& other) const {  // Intersection
        Set result;
        result.bits = bits & other.bits;
        return result;
    }
    
    Set operator-(const Set& other) const {  // Difference
        Set result;
        result.bits = bits & ~other.bits;
        return result;
    }
    
    // C++20 spaceship
    auto operator<=>(const Set& other) const = default;
    bool operator==(const Set& other) const = default;
    
    // Subset/Superset
    bool IsSubsetOf(const Set& other) const {
        return (bits & ~other.bits).none();
    }
    
    bool IsSupersetOf(const Set& other) const {
        return (other.bits & ~bits).none();
    }
};

// Set construction helpers
inline Set MakeSet(std::initializer_list<int> elements) {
    Set s;
    for (int e : elements) s.Include(e);
    return s;
}

inline Set MakeSetRange(int low, int high) {
    Set s;
    for (int i = low; i <= high; i++) s.Include(i);
    return s;
}

} // namespace bp
```

### 4.11 Control Flow Wrappers (C++23 Lambda)

```cpp
namespace bp {

// For loop (evaluates end expression ONCE - critical Pascal semantic)
template<typename BodyFunc>
void PFor(int start, int end, BodyFunc body) {
    int loop_end = end;  // Evaluate once!
    for (int i = start; i <= loop_end; i++) {
        body(i);
    }
}

// For-downto loop
template<typename BodyFunc>
void PForDownto(int start, int end, BodyFunc body) {
    int loop_end = end;  // Evaluate once!
    for (int i = start; i >= loop_end; i--) {
        body(i);
    }
}

// Repeat-until loop (condition is inverted!)
template<typename BodyFunc, typename CondFunc>
void PRepeatUntil(BodyFunc body, CondFunc condition) {
    do {
        body();
    } while (!condition());  // Note: inverted!
}

} // namespace bp
```

### 4.12 Exception Handling (C++23)

```cpp
namespace bp {

// Exception class
class Exception : public std::exception {
private:
    String message;
    int exceptionType;

public:
    Exception(int type, const String& msg) 
        : exceptionType(type), message(msg) {}
    
    int GetType() const { return exceptionType; }
    String GetMessage() const { return message; }
    
    const char* what() const noexcept override {
        return message.c_str();
    }
};

// Exception types
enum ExceptionType {
    EX_EXCEPTION = 0,
    EX_CONVERT_ERROR = 1,
    EX_IO_ERROR = 2,
    EX_RANGE_ERROR = 3,
    EX_DIV_BY_ZERO = 4,
    EX_OVERFLOW = 5,
    EX_MATH_ERROR = 6,
};

// Raise exception
inline void RaiseException(int type, const String& msg) {
    throw Exception(type, msg);
}

inline String ExceptionMessage(const Exception& e) {
    return e.GetMessage();
}

inline int ExceptionType(const Exception& e) {
    return e.GetType();
}

} // namespace bp
```

### 4.13 I/O Functions (C++23 with std::println)

```cpp
namespace bp {

// Console output - using C++23 std::println (preferred!)
inline void WriteLn() {
    std::println("");
}

template<typename T>
void WriteLn(const T& value) {
    std::println("{}", value);
}

template<typename T, typename... Args>
void WriteLn(const T& first, const Args&... rest) {
    std::print("{}", first);
    WriteLn(rest...);
}

template<typename T>
void Write(const T& value) {
    std::print("{}", value);
}

template<typename T, typename... Args>
void Write(const T& first, const Args&... rest) {
    std::print("{}", first);
    Write(rest...);
}

// File I/O
class TextFile {
private:
    std::fstream file;
    String filename;

public:
    void Assign(const String& fname) { filename = fname; }
    void Reset() { file.open(filename.c_str(), std::ios::in); }
    void Rewrite() { file.open(filename.c_str(), std::ios::out); }
    void Append() { file.open(filename.c_str(), std::ios::app); }
    void Close() { file.close(); }
    
    bool Eof() const { return file.eof(); }
    
    template<typename T>
    void Read(T& value) { file >> value; }
    
    template<typename T>
    void Write(const T& value) { file << value; }
    
    void WriteLn() { file << std::endl; }
    
    template<typename T>
    void WriteLn(const T& value) {
        file << value << std::endl;
    }
};

} // namespace bp
```

### 4.14 Type Conversion Functions (C++23 with std::format)

```cpp
namespace bp {

// Integer to string
inline String IntToStr(const Integer& value) {
    return String(std::to_string(value.ToInt()));
}

inline String IntToStr(int value) {
    return String(std::to_string(value));
}

// String to integer
inline Integer StrToInt(const String& s) {
    return Integer(std::stoi(s.c_str()));
}

inline Integer StrToIntDef(const String& s, const Integer& defaultValue) {
    try {
        return Integer(std::stoi(s.c_str()));
    } catch (...) {
        return defaultValue;
    }
}

inline Boolean TryStrToInt(const String& s, Integer& result) {
    try {
        result = Integer(std::stoi(s.c_str()));
        return Boolean(true);
    } catch (...) {
        return Boolean(false);
    }
}

// Float to string (overloaded for all float types)
inline String FloatToStr(const Single& value) {
    return String(std::to_string(value.ToFloat()));
}

inline String FloatToStr(const Double& value) {
    return String(std::to_string(value.ToDouble()));
}

inline String FloatToStr(const Extended& value) {
    return String(std::to_string(value.ToLongDouble()));
}

// String to float (returns Double by default, matching Delphi)
inline Double StrToFloat(const String& s) {
    return Double(std::stod(s.c_str()));
}

// C++20 std::format for Pascal Format() function
template<typename... Args>
inline String Format(const String& fmt, Args... args) {
    return String(std::format(fmt.c_str(), args...));
}

// Character functions
inline Boolean IsDigit(const Char& c) {
    return Boolean(std::isdigit(c.ToChar()));
}

inline Boolean IsLetter(const Char& c) {
    return Boolean(std::isalpha(c.ToChar()));
}

inline Char UpCase(const Char& c) {
    return Char(std::toupper(c.ToChar()));
}

} // namespace bp
```

### 4.15 System Functions (C++23)

```cpp
namespace bp {

// Program control
inline void Halt(const Integer& exitcode = Integer(0)) {
    exit(exitcode.ToInt());
}

// Timing (C++20 chrono)
inline Int64 GetTickCount64() {
    return Int64(
        std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now().time_since_epoch()
        ).count()
    );
}

// Command line
inline Integer ParamCount() {
    extern int __argc;
    return Integer(__argc - 1);
}

inline String ParamStr(const Integer& index) {
    extern char** __argv;
    int idx = index.ToInt();
    if (idx >= 0 && idx < __argc) {
        return String(__argv[idx]);
    }
    return String("");
}

// Math functions (overloaded for all numeric types)

// Abs
inline Integer Abs(const Integer& value) {
    return Integer(std::abs(value.ToInt()));
}

inline Single Abs(const Single& value) {
    return Single(std::fabs(value.ToFloat()));
}

inline Double Abs(const Double& value) {
    return Double(std::fabs(value.ToDouble()));
}

inline Extended Abs(const Extended& value) {
    return Extended(std::fabsl(value.ToLongDouble()));
}

// Sqr
inline Integer Sqr(const Integer& value) {
    int v = value.ToInt();
    return Integer(v * v);
}

inline Single Sqr(const Single& value) {
    float v = value.ToFloat();
    return Single(v * v);
}

inline Double Sqr(const Double& value) {
    double v = value.ToDouble();
    return Double(v * v);
}

inline Extended Sqr(const Extended& value) {
    long double v = value.ToLongDouble();
    return Extended(v * v);
}

// Sqrt (returns same type as input)
inline Single Sqrt(const Single& value) {
    return Single(std::sqrt(value.ToFloat()));
}

inline Double Sqrt(const Double& value) {
    return Double(std::sqrt(value.ToDouble()));
}

inline Extended Sqrt(const Extended& value) {
    return Extended(std::sqrtl(value.ToLongDouble()));
}

// Trigonometric functions (overloaded)
inline Single Sin(const Single& value) {
    return Single(std::sin(value.ToFloat()));
}

inline Double Sin(const Double& value) {
    return Double(std::sin(value.ToDouble()));
}

inline Extended Sin(const Extended& value) {
    return Extended(std::sinl(value.ToLongDouble()));
}

inline Single Cos(const Single& value) {
    return Single(std::cos(value.ToFloat()));
}

inline Double Cos(const Double& value) {
    return Double(std::cos(value.ToDouble()));
}

inline Extended Cos(const Extended& value) {
    return Extended(std::cosl(value.ToLongDouble()));
}

inline Single ArcTan(const Single& value) {
    return Single(std::atan(value.ToFloat()));
}

inline Double ArcTan(const Double& value) {
    return Double(std::atan(value.ToDouble()));
}

inline Extended ArcTan(const Extended& value) {
    return Extended(std::atanl(value.ToLongDouble()));
}

// Logarithm and exponential
inline Single Ln(const Single& value) {
    return Single(std::log(value.ToFloat()));
}

inline Double Ln(const Double& value) {
    return Double(std::log(value.ToDouble()));
}

inline Extended Ln(const Extended& value) {
    return Extended(std::logl(value.ToLongDouble()));
}

inline Single Exp(const Single& value) {
    return Single(std::exp(value.ToFloat()));
}

inline Double Exp(const Double& value) {
    return Double(std::exp(value.ToDouble()));
}

inline Extended Exp(const Extended& value) {
    return Extended(std::expl(value.ToLongDouble()));
}

// Type conversions (return Integer)
inline Integer Trunc(const Single& value) {
    return Integer(static_cast<int>(value.ToFloat()));
}

inline Integer Trunc(const Double& value) {
    return Integer(static_cast<int>(value.ToDouble()));
}

inline Integer Trunc(const Extended& value) {
    return Integer(static_cast<int>(value.ToLongDouble()));
}

inline Integer Round(const Single& value) {
    return Integer(static_cast<int>(std::round(value.ToFloat())));
}

inline Integer Round(const Double& value) {
    return Integer(static_cast<int>(std::round(value.ToDouble())));
}

inline Integer Round(const Extended& value) {
    return Integer(static_cast<int>(std::roundl(value.ToLongDouble())));
}

// Int and Frac (return same type as input)
inline Single Int(const Single& value) {
    return Single(std::floor(value.ToFloat()));
}

inline Double Int(const Double& value) {
    return Double(std::floor(value.ToDouble()));
}

inline Extended Int(const Extended& value) {
    return Extended(std::floorl(value.ToLongDouble()));
}

inline Single Frac(const Single& value) {
    float v = value.ToFloat();
    return Single(v - std::floor(v));
}

inline Double Frac(const Double& value) {
    double v = value.ToDouble();
    return Double(v - std::floor(v));
}

inline Extended Frac(const Extended& value) {
    long double v = value.ToLongDouble();
    return Extended(v - std::floorl(v));
}

// Character conversions
inline Integer Ord(const Char& c) {
    return Integer(static_cast<int>(c.ToChar()));
}

inline Char Chr(const Integer& value) {
    return Char(static_cast<char>(value.ToInt()));
}

// Random numbers (return Double by default, matching Delphi)
inline void Randomize() {
    srand(static_cast<unsigned int>(time(nullptr)));
}

inline Integer Random(const Integer& range) {
    return Integer(rand() % range.ToInt());
}

inline Double Random() {
    return Double(static_cast<double>(rand()) / RAND_MAX);
}

// Pointer checks
template<typename T>
inline Boolean Assigned(T* ptr) {
    return Boolean(ptr != nullptr);
}

// Inc/Dec as functions
inline void Inc(Integer& value, const Integer& amount = Integer(1)) {
    value.Inc(amount.ToInt());
}

inline void Dec(Integer& value, const Integer& amount = Integer(1)) {
    value.Dec(amount.ToInt());
}

} // namespace bp
```

### 4.16 Memory Management

```cpp
namespace bp {

// Memory allocation
inline void* GetMem(const Integer& size) {
    return malloc(size.ToInt());
}

inline void FreeMem(void* ptr) {
    free(ptr);
}

inline void* ReallocMem(void* ptr, const Integer& newsize) {
    return realloc(ptr, newsize.ToInt());
}

// Typed pointer allocation
template<typename T>
inline T* New() {
    return new T();
}

template<typename T>
inline void Dispose(T* ptr) {
    delete ptr;
}

// Block operations
inline void Move(const void* source, void* dest, const Integer& count) {
    memmove(dest, source, count.ToInt());
}

inline void FillChar(void* ptr, const Integer& count, const Byte& value) {
    memset(ptr, value.ToInt(), count.ToInt());
}

} // namespace bp
```

### 4.17 Runtime File Organization

The runtime library is organized into logical modules for maintainability:

**Header Files:**
- `runtime_types.h` - Core wrapped types (Integer, Boolean, Single, Double, Extended, Char, String, Array, Set)
- `runtime_io.h` - I/O functions (WriteLn, Write, TextFile)
- `runtime_string.h` - String operations (Copy, Pos, UpperCase, LowerCase, etc.)
- `runtime_math.h` - Math functions (Abs, Sqrt, Sin, Cos, etc.)
- `runtime_system.h` - System functions (Halt, GetTickCount64, ParamCount, etc.)
- `runtime_memory.h` - Memory management (GetMem, FreeMem, New, Dispose)
- `runtime_control.h` - Control flow wrappers (PFor, PForDownto, PRepeatUntil)
- `runtime_convert.h` - Type conversions (IntToStr, StrToInt, FloatToStr, etc.)
- `runtime_exception.h` - Exception handling (Exception class, RaiseException)

**Implementation Files:**
- `runtime_types.cpp` - Type implementations (if needed, otherwise header-only)
- `runtime_io.cpp` - I/O implementations
- `runtime_string.cpp` - String operation implementations
- `runtime_math.cpp` - Math function implementations
- `runtime_system.cpp` - System function implementations
- `runtime_memory.cpp` - Memory management implementations
- `runtime_control.cpp` - Control flow implementations (if needed, otherwise header-only)
- `runtime_convert.cpp` - Type conversion implementations
- `runtime_exception.cpp` - Exception implementations

**Master Aggregation Files:**
- `runtime.h` - Includes ALL `runtime_*.h` headers
- `runtime.cpp` - Includes ALL `runtime_*.cpp` implementations

**Usage in Generated Code:**
```cpp
#include "runtime.h"  // Single include gets everything

int main() {
    bp::Integer x = 42;  // Fully-qualified
    bp::WriteLn("Value: ", x);
    return 0;
}
```

**Benefits:**
- Logical organization by functionality
- Easier maintenance and navigation
- Clear separation of concerns
- Single point of reference for users (`runtime.h` / `runtime.cpp`)

---

## 5. Generated Code Structure

### 5.1 Simple Program

**Pascal:**
```pascal
program Test;
var
  i: Integer;
  s: String;
begin
  i := 42;
  s := IntToStr(i);
  WriteLn(s);
end.
```

**Generated C++:**
```cpp
#include "runtime.h"

void ProgramMain() {
#line 3 "Test.pas"
    bp::Integer i;
#line 4 "Test.pas"
    bp::String s;
    
#line 6 "Test.pas"
    i = 42;
#line 7 "Test.pas"
    s = bp::IntToStr(i);
#line 8 "Test.pas"
    bp::WriteLn(s);
}

int main(int argc, char** argv) {
    ProgramMain();
    return 0;
}
```

### 5.2 With Records

**Pascal:**
```pascal
type
  TPoint = record
    X, Y: Integer;
  end;

var
  p: TPoint;
begin
  p.X := 10;
  p.Y := 20;
  WriteLn(p.X + p.Y);
end.
```

**Generated C++ (with C++20 designated initializers):**
```cpp
#include "runtime.h"

#line 2 "test.pas"
struct TPoint {
    bp::Integer X;
    bp::Integer Y;
};

void ProgramMain() {
#line 7 "test.pas"
    TPoint p;
    
#line 9 "test.pas"
    p.X = 10;
#line 10 "test.pas"
    p.Y = 20;
#line 11 "test.pas"
    bp::WriteLn(p.X + p.Y);
    
    // C++20 allows: TPoint p2 = {.X = 10, .Y = 20};
}
```

### 5.3 Floating-Point Example (Delphi Semantics)

**Pascal:**
```pascal
var
  s: Single;
  d: Double;
  e: Extended;
  i: Integer;
begin
  s := 3.14;
  d := s * 2.0;     // Single promoted to Double
  i := 7;
  d := i / 2;       // Integer division returns Double!
  e := d * 2.0;     // Double promoted to Extended
  WriteLn(s, d, e);
end.
```

**Generated C++:**
```cpp
#include "runtime.h"

void ProgramMain() {
    bp::Single s;
    bp::Double d;
    bp::Extended e;
    bp::Integer i;
    
    s = 3.14f;
    d = s * 2.0;          // Implicit promotion via constructors
    i = 7;
    d = i / 2;            // operator/ returns bp::Double!
    e = d * 2.0;          // Implicit promotion via constructors
    bp::WriteLn(s, ", ", d, ", ", e);
}
```

### 5.4 With External Library (No Conflict!)

**Pascal calling OpenGL:**
```pascal
program GLTest;

var
  vertices: array[0..8] of Single;  // OpenGL expects float!
begin
  vertices[0] := 0.0;
  vertices[1] := 0.5;
  vertices[2] := 0.0;
  // ... more vertices
  
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, @vertices);
end.
```

**Generated C++:**
```cpp
#include "runtime.h"
#include <GL/gl.h>

void ProgramMain() {
    bp::Single vertices[9];  // bp::Single wraps float!
    
    vertices[0] = 0.0f;
    vertices[1] = 0.5f;
    vertices[2] = 0.0f;
    // ... more vertices
    
    // &vertices[0] is float*, exactly what OpenGL expects!
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, &vertices[0]);
}
```

**Perfect isolation and correct C interop!**

### 5.5 String Concatenation Example

**Pascal:**
```pascal
var
  s, name: String;
begin
  name := 'World';
  s := 'Hello' + ' ' + name + '!';
  WriteLn(s);
end.
```

**Generated C++ (OPTIMIZED):**
```cpp
#include "runtime.h"

void ProgramMain() {
    bp::String s;
    bp::String name;
    
    name = "World";
    
    // Optimized: in-place concatenation
    s = "Hello";
    s += " ";
    s += name;
    s += "!";
    
    bp::WriteLn(s);
}
```

---

## 6. Transpiler Implementation - Token Mapping Only

### 6.1 The Algorithm

```
For each Pascal source file:
    1. Parse with DelphiAST → AST tree
    2. Emit: #include "runtime.h"
    3. Walk AST recursively
    4. For each node:
        a. Emit #line directive (file:line)
        b. Map Pascal token → C++ token with bp:: prefix
        c. Recurse into children
    5. Write output C++ file
```

### 6.2 Type Name Mapping

| Pascal Type | C++ Type (fully-qualified) |
|-------------|----------------------------|
| `Integer` | `bp::Integer` |
| `Boolean` | `bp::Boolean` |
| `Single` | `bp::Single` |
| `Double` | `bp::Double` |
| `Extended` | `bp::Extended` |
| `Char` | `bp::Char` |
| `String` | `bp::String` |
| `Byte` | `bp::Byte` |
| `Word` | `bp::Word` |
| `Cardinal` | `bp::Cardinal` |
| `Int64` | `bp::Int64` |
| `array of T` | `bp::Array<T>` |
| `set of T` | `bp::Set` |

### 6.3 Operator Mapping

| Pascal | C++ | Notes |
|--------|-----|-------|
| `:=` | `=` | Assignment |
| `+` | `+` or `+=` | Use += for s := s + x patterns |
| `-` | `-` | Works via operator overload |
| `*` | `*` | Works via operator overload |
| `/` | `/` | On Integer returns Double! |
| `div` | `.Div()` | Method call |
| `mod` | `.Mod()` | Method call |
| `=` | `==` | Comparison |
| `<>` | `!=` | Inequality |
| `and` | `&&` | Logical AND |
| `or` | `||` | Logical OR |
| `not` | `!` | Logical NOT |
| `xor` | `.Xor()` | Method call |
| `in` | `.Contains()` | Method call |

---

## 7. Records - Plain Structs

Records are NOT wrapped - they're just containers with wrapped field types.

**Pascal:**
```pascal
type
  TData = record
    Name: String;
    Value: Integer;
    Temperature: Single;
    Active: Boolean;
  end;
```

**C++:**
```cpp
struct TData {
    bp::String Name;        // bp::String
    bp::Integer Value;      // bp::Integer
    bp::Single Temperature; // bp::Single
    bp::Boolean Active;     // bp::Boolean
};
```

---

## 8. C++23 Benefits Summary

### std::println (C++23)
- Cleaner than std::format + iostream
- Better Unicode support
- Type-safe like std::format
- Perfect for implementing WriteLn()

### Spaceship Operator (C++20, still in C++23)
- One line generates all 6 comparison operators
- Reduces boilerplate dramatically

### Designated Initializers (C++20)
- `TPoint p = {.X = 10, .Y = 20};`
- Closer to Pascal syntax

### std::format (C++20)
- Easy implementation of Pascal Format() function
- Type-safe formatting

### Concepts (C++20+)
- Can constrain templates to work only with bp types
- Better error messages

### Ranges (C++20+)
- Easier array/collection manipulation
- Functional-style operations

---

## 9. Testing Strategy

### 9.1 Runtime Tests

```cpp
#include "runtime.h"

void TestInteger() {
    bp::Integer a = 10;
    bp::Integer b = 20;
    bp::Integer c = a + b;
    assert(c.ToInt() == 30);
    assert((a < b) == true);  // C++20 spaceship!
}

void TestString() {
    bp::String s = "Hello";
    assert(s[1] == 'H');  // 1-based
    assert(s.Length() == 5);
}

void TestFloatingPoint() {
    bp::Single s = 3.14f;
    bp::Double d = 3.14159;
    bp::Extended e = 3.141592653589793L;
    
    // Test precision
    assert(sizeof(s.ToFloat()) == 4);
    assert(sizeof(d.ToDouble()) == 8);
    assert(sizeof(e.ToLongDouble()) >= 8);  // At least 8, up to 16
    
    // Test integer division returns Double
    bp::Integer i1 = 7;
    bp::Integer i2 = 2;
    bp::Double result = i1 / i2;  // Must be Double, not Integer!
    assert(result.ToDouble() == 3.5);
}
```

### 9.2 Transpiler Tests

Simple Pascal → C++ → Compile → Run → Verify

### 9.3 External Library Integration

Test with raylib, SDL, OpenGL, etc. to ensure no conflicts.

---

## 10. Development Phases

### Phase 1: C++23 Runtime Library
- Implement all bp namespace types
- Use C++23 features (std::println, spaceship, etc.)
- Test independently

### Phase 2: Token Mapper Transpiler
- Parse with DelphiAST
- Emit fully-qualified bp:: names
- Map tokens
- Emit #line directives

### Phase 3: Control Flow
- For/repeat wrappers
- Test with loops

### Phase 4: Functions
- Declarations and calls
- Parameters

### Phase 5: Units
- Multiple files
- Initialization/finalization

### Phase 6: Bootstrap RTL
- Transpile System.pas
- Transpile SysUtils.pas

---

## 11. Success Criteria

V1.0 succeeds when:

1. ✅ All `bp::` types implemented with C++23
2. ✅ Transpiler is simple token mapper
3. ✅ Programs compile and run correctly
4. ✅ #line directives work
5. ✅ No conflicts with external libraries (total namespace isolation)
6. ✅ Can transpile System.pas and SysUtils.pas
7. ✅ Can write real programs using transpiled RTL
8. ✅ Generated C++ is clean and readable
9. ✅ String concatenation is optimized with +=
10. ✅ Floating-point semantics match Delphi exactly

---

## 12. Build Toolchain

### Compiler: Zig + Clang C++

**Toolchain:** Zig (latest released version, currently 0.15.2+)

**Why Zig:**
- Bundles Clang C++ compiler (Clang 19+ in Zig 0.15.2)
- Full C++23 support with LLVM 20.1.8+
- No external compiler dependencies
- Built-in cross-compilation
- Reproducible builds
- Fast compilation
- Excellent error messages

### Build Process

```
Pascal Source (.pas)
        ↓
    DelphiAST (parsing)
        ↓
  Blaise Transpiler (Delphi executable)
        ↓
  Generated C++23 (.cpp)
        ↓
    zig c++ -std=c++23 (Clang backend)
        ↓
   Native Executable
```

### Build Commands

**Compile single file:**
```bash
zig c++ -std=c++23 -o program.exe program.cpp runtime.cpp
```

**With optimizations:**
```bash
zig c++ -std=c++23 -O3 -o program.exe program.cpp runtime.cpp
```

**Cross-compile (e.g., for Windows from Linux):**
```bash
zig c++ -std=c++23 -target x86_64-windows -o program.exe program.cpp runtime.cpp
```

**Cross-compile for Linux:**
```bash
zig c++ -std=c++23 -target x86_64-linux -o program program.cpp runtime.cpp
```

**Debug build:**
```bash
zig c++ -std=c++23 -g -o program.exe program.cpp runtime.cpp
```

### Runtime Library Compilation

The `runtime.cpp` needs to be compiled once and can be linked:

```bash
# Compile runtime to object file
zig c++ -std=c++23 -c -o runtime.o runtime.cpp

# Link with generated code
zig c++ -std=c++23 -o program.exe program.cpp runtime.o
```

Or use header-only implementation (all inline in `runtime.h`).

### Integration with Blaise Transpiler

```bash
# Full pipeline
Blaise.exe source.pas           # Generates source.cpp
zig c++ -std=c++23 -o source.exe source.cpp runtime.cpp
./source.exe                    # Run
```

### Build Script Example

```bash
#!/bin/bash
# build.sh - Complete build pipeline

PASCAL_FILE=$1
BASE_NAME=$(basename "$PASCAL_FILE" .pas)

echo "Transpiling $PASCAL_FILE..."
Blaise.exe "$PASCAL_FILE" || exit 1

echo "Compiling with zig c++..."
zig c++ -std=c++23 -O3 \
    -o "${BASE_NAME}.exe" \
    "${BASE_NAME}.cpp" \
    runtime.cpp || exit 1

echo "Build complete: ${BASE_NAME}.exe"
```

### Advantages of Zig Backend

1. **No Compiler Installation** - Zig bundles everything
2. **Consistent Everywhere** - Same clang version on all platforms
3. **Cross-Compilation** - Target any platform from any platform
4. **Fast** - Clang is known for compilation speed
5. **Future-Proof** - Always use latest released Zig version
6. **Standard Compliant** - Full C++23 support with LLVM 20.1.8+

### Version Policy

**Blaise always targets the latest released version of Zig.**

This ensures:
- Latest C++ standard support (C++23)
- Latest optimizations
- Latest bug fixes
- Latest platform support

Users simply need to install the current Zig release.

---

## 13. Key Principles Summary

### THE LAW
**WRAP EVERYTHING IN namespace bp { ... }**
**ALWAYS use fully-qualified bp:: names**
**NEVER use 'using namespace bp;'**
**ALL runtime semantics MUST match Delphi exactly**

### Technology
- **C++23** for latest features (std::println, etc.)
- **namespace bp** for total isolation
- **Fully-qualified names** (bp::Integer, bp::WriteLn, etc.)
- **Spaceship operator** for less boilerplate
- **std::println** for I/O (C++23, cleaner than std::format + iostream)
- **std::format** for string formatting (C++20)
- **String optimization** with += for in-place concatenation

### Architecture
- **Transpiler:** Dumb token mapper
- **Runtime:** Smart, all semantics
- **C++ Compiler:** Validation
- **Modular runtime:** Logical file organization

### Floating-Point Semantics
- **Single, Double, Extended** - Separate classes for each precision
- **Type promotions** - Match Delphi rules exactly
- **Integer division** - Returns Double (Delphi behavior)
- **C interop** - Single → float for OpenGL/game engines

### Philosophy
- Keep it simple
- Leverage C++23
- Test continuously
- Start small, grow incrementally
- Optimize for performance (string +=)
- **Match Delphi semantics exactly**

---

**Document Status:** ACTIVE

**Target:** C++23 via Zig (latest release, LLVM 20.1.8+ with excellent C++23 support)

**Compiler:** Zig bundled Clang (Clang 20+ in latest Zig)

**Last Updated:** 2025-10-20 (C++23 + namespace bp + fully-qualified names + string optimization + runtime modularization + Real type removed + floating-point semantics documented)
