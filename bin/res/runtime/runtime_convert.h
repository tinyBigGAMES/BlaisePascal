/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_convert.h - Blaise Pascal type conversion functions (UTF-16)

#pragma once

#include "runtime_types.h"
#include <string>
#include <format>
#include <stdexcept>
#include <sstream>
#include <iomanip>

namespace bp {

// ============================================================================
// Integer to String Conversions
// ============================================================================

inline String IntToStr(const Integer& value) {
    std::string narrow = std::to_string(value.ToInt());
    return String(narrow.c_str());
}

inline String IntToStr(int value) {
    std::string narrow = std::to_string(value);
    return String(narrow.c_str());
}

inline String IntToStr(const Int64& value) {
    std::string narrow = std::to_string(value.ToInt64());
    return String(narrow.c_str());
}

inline String IntToStr(const Cardinal& value) {
    std::string narrow = std::to_string(value.ToCardinal());
    return String(narrow.c_str());
}

inline String IntToStr(const Byte& value) {
    std::string narrow = std::to_string(value.ToInt());
    return String(narrow.c_str());
}

inline String IntToStr(const Word& value) {
    std::string narrow = std::to_string(value.ToInt());
    return String(narrow.c_str());
}

// ============================================================================
// String to Integer Conversions
// ============================================================================

inline Integer StrToInt(const String& s) {
    try {
        std::string narrow = s.ToNarrow();
        return Integer(std::stoi(narrow));
    } catch (const std::exception&) {
        throw std::runtime_error("Invalid integer string");
    }
}

inline Integer StrToIntDef(const String& s, const Integer& defaultValue) {
    try {
        std::string narrow = s.ToNarrow();
        return Integer(std::stoi(narrow));
    } catch (...) {
        return defaultValue;
    }
}

inline Boolean TryStrToInt(const String& s, Integer& result) {
    try {
        std::string narrow = s.ToNarrow();
        result = Integer(std::stoi(narrow));
        return Boolean(true);
    } catch (...) {
        return Boolean(false);
    }
}

inline Int64 StrToInt64(const String& s) {
    try {
        std::string narrow = s.ToNarrow();
        return Int64(std::stoll(narrow));
    } catch (const std::exception&) {
        throw std::runtime_error("Invalid int64 string");
    }
}

inline Int64 StrToInt64Def(const String& s, const Int64& defaultValue) {
    try {
        std::string narrow = s.ToNarrow();
        return Int64(std::stoll(narrow));
    } catch (...) {
        return defaultValue;
    }
}

inline Boolean TryStrToInt64(const String& s, Int64& result) {
    try {
        std::string narrow = s.ToNarrow();
        result = Int64(std::stoll(narrow));
        return Boolean(true);
    } catch (...) {
        return Boolean(false);
    }
}

// ============================================================================
// Float to String Conversions
// ============================================================================

inline String FloatToStr(const Single& value) {
    std::string narrow = std::to_string(value.ToFloat());
    return String(narrow.c_str());
}

inline String FloatToStr(const Double& value) {
    std::string narrow = std::to_string(value.ToDouble());
    return String(narrow.c_str());
}

inline String FloatToStr(const Extended& value) {
    std::string narrow = std::to_string(value.ToLongDouble());
    return String(narrow.c_str());
}

// ============================================================================
// String to Float Conversions
// ============================================================================

inline Double StrToFloat(const String& s) {
    try {
        std::string narrow = s.ToNarrow();
        return Double(std::stod(narrow));
    } catch (const std::exception&) {
        throw std::runtime_error("Invalid float string");
    }
}

inline Double StrToFloatDef(const String& s, const Double& defaultValue) {
    try {
        std::string narrow = s.ToNarrow();
        return Double(std::stod(narrow));
    } catch (...) {
        return defaultValue;
    }
}

inline Boolean TryStrToFloat(const String& s, Double& result) {
    try {
        std::string narrow = s.ToNarrow();
        result = Double(std::stod(narrow));
        return Boolean(true);
    } catch (...) {
        return Boolean(false);
    }
}

// ============================================================================
// Character Conversions
// ============================================================================

inline Integer Ord(const Char& c) {
    return Integer(static_cast<int>(c.ToChar16()));
}

inline Integer Ord(char16_t c) {
    return Integer(static_cast<int>(c));
}

inline Char Chr(const Integer& value) {
    return Char(static_cast<char16_t>(value.ToInt()));
}

inline Char Chr(int value) {
    return Char(static_cast<char16_t>(value));
}

// ============================================================================
// Succ - Successor (returns next ordinal value)
// ============================================================================

inline Integer Succ(const Integer& value) {
    return Integer(value.ToInt() + 1);
}

inline Integer Succ(int value) {
    return Integer(value + 1);
}

inline Char Succ(const Char& c) {
    return Char(static_cast<char16_t>(c.ToChar16() + 1));
}

inline Byte Succ(const Byte& value) {
    return Byte(value.ToByte() + 1);
}

inline Word Succ(const Word& value) {
    return Word(value.ToWord() + 1);
}

inline Boolean Succ(const Boolean& value) {
    return Boolean(!value.ToBool());
}

// ============================================================================
// Pred - Predecessor (returns previous ordinal value)
// ============================================================================

inline Integer Pred(const Integer& value) {
    return Integer(value.ToInt() - 1);
}

inline Integer Pred(int value) {
    return Integer(value - 1);
}

inline Char Pred(const Char& c) {
    return Char(static_cast<char16_t>(c.ToChar16() - 1));
}

inline Byte Pred(const Byte& value) {
    return Byte(value.ToByte() - 1);
}

inline Word Pred(const Word& value) {
    return Word(value.ToWord() - 1);
}

inline Boolean Pred(const Boolean& value) {
    return Boolean(!value.ToBool());
}

// ============================================================================
// Character Test Functions (ASCII subset for cross-platform)
// ============================================================================

inline Boolean IsDigit(const Char& c) {
    char16_t ch = c.ToChar16();
    return Boolean(ch >= u'0' && ch <= u'9');
}

inline Boolean IsLetter(const Char& c) {
    char16_t ch = c.ToChar16();
    return Boolean((ch >= u'A' && ch <= u'Z') || (ch >= u'a' && ch <= u'z'));
}

inline Boolean IsLetterOrDigit(const Char& c) {
    char16_t ch = c.ToChar16();
    return Boolean((ch >= u'A' && ch <= u'Z') || (ch >= u'a' && ch <= u'z') || (ch >= u'0' && ch <= u'9'));
}

inline Boolean IsWhiteSpace(const Char& c) {
    char16_t ch = c.ToChar16();
    return Boolean(ch == u' ' || ch == u'\t' || ch == u'\n' || ch == u'\r');
}

inline Char UpCase(const Char& c) {
    char16_t ch = c.ToChar16();
    if (ch >= u'a' && ch <= u'z') {
        return Char(static_cast<char16_t>(ch - (u'a' - u'A')));
    }
    return c;
}

inline Char LowCase(const Char& c) {
    char16_t ch = c.ToChar16();
    if (ch >= u'A' && ch <= u'Z') {
        return Char(static_cast<char16_t>(ch + (u'a' - u'A')));
    }
    return c;
}

// ============================================================================
// Boolean to String Conversions
// ============================================================================

inline String BoolToStr(const Boolean& value) {
    return value.ToBool() ? String(u"True") : String(u"False");
}

inline String BoolToStr(const Boolean& value, const Boolean& useBoolStrs) {
    if (useBoolStrs.ToBool()) {
        return value.ToBool() ? String(u"True") : String(u"False");
    } else {
        return value.ToBool() ? String(u"-1") : String(u"0");
    }
}

// ============================================================================
// String to Boolean Conversions
// ============================================================================

inline Boolean StrToBool(const String& s) {
    String upper = UpperCase(s);
    std::u16string upperStr = upper.GetStdU16String();
    std::u16string sStr = s.GetStdU16String();
    
    if (upperStr == u"TRUE" || sStr == u"1" || sStr == u"-1") {
        return Boolean(true);
    } else if (upperStr == u"FALSE" || sStr == u"0") {
        return Boolean(false);
    }
    throw std::runtime_error("Invalid boolean string");
}

inline Boolean StrToBoolDef(const String& s, const Boolean& defaultValue) {
    try {
        return StrToBool(s);
    } catch (...) {
        return defaultValue;
    }
}

inline Boolean TryStrToBool(const String& s, Boolean& result) {
    try {
        result = StrToBool(s);
        return Boolean(true);
    } catch (...) {
        return Boolean(false);
    }
}

// ============================================================================
// Format Function - Uses vformat for runtime format strings
// ============================================================================

// Convert Pascal format specifiers to C++20 format syntax
inline std::string ConvertPascalFormatToCpp(const std::string& pascalFmt) {
    std::string result;
    result.reserve(pascalFmt.size());
    
    for (size_t i = 0; i < pascalFmt.size(); ++i) {
        if (pascalFmt[i] == '%' && i + 1 < pascalFmt.size()) {
            char next = pascalFmt[i + 1];
            
            // Handle %% -> {}
            if (next == '%') {
                result += "%";
                ++i;
                continue;
            }
            
            // Start of format specifier
            ++i; // Skip '%'
            
            std::string flags;
            std::string width;
            std::string precision;
            char typeSpec = '\0';
            
            // Parse flags (-, +, 0, space, #)
            while (i < pascalFmt.size() && (pascalFmt[i] == '-' || pascalFmt[i] == '+' || 
                   pascalFmt[i] == '0' || pascalFmt[i] == ' ' || pascalFmt[i] == '#')) {
                flags += pascalFmt[i++];
            }
            
            // Parse width
            while (i < pascalFmt.size() && std::isdigit(pascalFmt[i])) {
                width += pascalFmt[i++];
            }
            
            // Parse precision (e.g., .2 in %.2d)
            if (i < pascalFmt.size() && pascalFmt[i] == '.') {
                ++i; // Skip '.'
                while (i < pascalFmt.size() && std::isdigit(pascalFmt[i])) {
                    precision += pascalFmt[i++];
                }
            }
            
            // Parse type specifier
            if (i < pascalFmt.size()) {
                typeSpec = pascalFmt[i];
            }
            
            // Build C++20 format specifier
            result += "{:";
            
            // Add flags
            for (char flag : flags) {
                if (flag == '-') result += '<';  // Left align
                else if (flag == '+') result += '+'; // Always show sign
                else if (flag == ' ') result += ' '; // Space for positive
                else if (flag == '#') result += '#'; // Alternate form
                else if (flag == '0') {
                    // Zero padding - only if no precision specified for integers
                    if (precision.empty() && (typeSpec == 'd' || typeSpec == 'i' || 
                        typeSpec == 'u' || typeSpec == 'x' || typeSpec == 'X')) {
                        result += '0';
                    }
                }
            }
            
            // For integer types with precision (%.2d), convert to zero-padded width (02d)
            if (!precision.empty() && (typeSpec == 'd' || typeSpec == 'i' || typeSpec == 'u')) {
                result += '0' + precision;
                typeSpec = 'd'; // Use 'd' for integers
            } else if (!width.empty()) {
                result += width;
            }
            
            // Add precision for floats (.2f format)
            if (!precision.empty() && (typeSpec == 'f' || typeSpec == 'F' || 
                typeSpec == 'e' || typeSpec == 'E' || typeSpec == 'g' || typeSpec == 'G')) {
                result += '.' + precision;
            }
            
            // Add type specifier
            switch (typeSpec) {
                case 'd':
                case 'i':
                case 'u':
                    result += 'd';
                    break;
                case 'x':
                    result += 'x';
                    break;
                case 'X':
                    result += 'X';
                    break;
                case 'f':
                case 'F':
                    result += 'f';
                    break;
                case 'e':
                    result += 'e';
                    break;
                case 'E':
                    result += 'E';
                    break;
                case 'g':
                    result += 'g';
                    break;
                case 'G':
                    result += 'G';
                    break;
                case 's':
                case 'c':
                    // No type specifier needed for strings/chars
                    break;
                case 'p':
                    result += 'p';
                    break;
                default:
                    // Unknown type, leave empty
                    break;
            }
            
            result += "}";
        } else {
            result += pascalFmt[i];
        }
    }
    
    return result;
}

// Helper to convert single argument and store it
template<typename T>
inline auto ConvertFormatArg(T&& arg) {
    using DecayT = std::decay_t<T>;
    
    if constexpr (std::is_same_v<DecayT, String>) {
        return arg.ToNarrow();
    } else if constexpr (std::is_same_v<DecayT, Integer>) {
        return arg.ToInt();
    } else if constexpr (std::is_same_v<DecayT, Int64>) {
        return arg.ToInt64();
    } else if constexpr (std::is_same_v<DecayT, Cardinal>) {
        return static_cast<unsigned int>(arg.ToCardinal());
    } else if constexpr (std::is_same_v<DecayT, Byte>) {
        return static_cast<int>(arg.ToByte());
    } else if constexpr (std::is_same_v<DecayT, Word>) {
        return static_cast<int>(arg.ToWord());
    } else if constexpr (std::is_same_v<DecayT, ShortInt>) {
        return static_cast<int>(arg.ToShortInt());
    } else if constexpr (std::is_same_v<DecayT, SmallInt>) {
        return static_cast<int>(arg.ToSmallInt());
    } else if constexpr (std::is_same_v<DecayT, Single>) {
        return arg.ToFloat();
    } else if constexpr (std::is_same_v<DecayT, Double>) {
        return arg.ToDouble();
    } else if constexpr (std::is_same_v<DecayT, Extended>) {
        return static_cast<double>(arg.ToLongDouble());
    } else if constexpr (std::is_same_v<DecayT, Boolean>) {
        return arg.ToBool();
    } else if constexpr (std::is_same_v<DecayT, Char>) {
        return arg.ToChar();
    } else if constexpr (std::is_same_v<DecayT, Pointer>) {
        return arg.ToVoidPtr();
    } else if constexpr (std::is_convertible_v<DecayT, const wchar_t*>) {
        // Convert wide strings to narrow
        std::string result;
        const wchar_t* p = arg;
        while (*p) {
            result += static_cast<char>(*p++);
        }
        return result;
    } else if constexpr (std::is_convertible_v<DecayT, const char*>) {
        return std::string(arg);
    } else {
        return std::forward<T>(arg);
    }
}

template<typename... Args>
inline String Format(const String& fmt, Args&&... args) {
    std::string narrowFmt = fmt.ToNarrow();
    
    // Convert Pascal format string to C++ format string
    std::string cppFmt = ConvertPascalFormatToCpp(narrowFmt);
    
    // Convert and store arguments in a tuple to ensure they stay alive
    auto convertedArgs = std::make_tuple(ConvertFormatArg(std::forward<Args>(args))...);
    
    // Create format args from the stored tuple elements
    auto formatArgs = std::apply(
        [](auto&... storedArgs) {
            return std::make_format_args(storedArgs...);
        },
        convertedArgs
    );
    
    // Use vformat for runtime format strings
    std::string result = std::vformat(cppFmt, formatArgs);
    
    return String(result.c_str());
}

// ============================================================================
// Hexadecimal Conversions
// ============================================================================

inline String IntToHex(const Integer& value, int digits = 0) {
    std::ostringstream oss;
    oss << std::hex << std::uppercase << value.ToInt();
    std::string result = oss.str();
    
    if (digits > 0 && static_cast<int>(result.length()) < digits) {
        result = std::string(digits - result.length(), '0') + result;
    }
    return String(result.c_str());
}

inline String IntToHex(const Int64& value, int digits = 0) {
    std::ostringstream oss;
    oss << std::hex << std::uppercase << value.ToInt64();
    std::string result = oss.str();
    
    if (digits > 0 && static_cast<int>(result.length()) < digits) {
        result = std::string(digits - result.length(), '0') + result;
    }
    return String(result.c_str());
}

inline String IntToHex(const Byte& value, int digits = 0) {
    std::ostringstream oss;
    oss << std::hex << std::uppercase << static_cast<unsigned int>(value.ToByte());
    std::string result = oss.str();
    
    if (digits > 0 && static_cast<int>(result.length()) < digits) {
        result = std::string(digits - result.length(), '0') + result;
    }
    return String(result.c_str());
}

inline String IntToHex(const Word& value, int digits = 0) {
    std::ostringstream oss;
    oss << std::hex << std::uppercase << value.ToWord();
    std::string result = oss.str();
    
    if (digits > 0 && static_cast<int>(result.length()) < digits) {
        result = std::string(digits - result.length(), '0') + result;
    }
    return String(result.c_str());
}

inline String IntToHex(const Cardinal& value, int digits = 0) {
    std::ostringstream oss;
    oss << std::hex << std::uppercase << value.ToCardinal();
    std::string result = oss.str();
    
    if (digits > 0 && static_cast<int>(result.length()) < digits) {
        result = std::string(digits - result.length(), '0') + result;
    }
    return String(result.c_str());
}

inline String IntToHex(const UInt64& value, int digits = 0) {
    std::ostringstream oss;
    oss << std::hex << std::uppercase << value.ToUInt64();
    std::string result = oss.str();
    
    if (digits > 0 && static_cast<int>(result.length()) < digits) {
        result = std::string(digits - result.length(), '0') + result;
    }
    return String(result.c_str());
}

// Overloads accepting Integer wrapper for digits parameter
inline String IntToHex(const Integer& value, const Integer& digits) {
    return IntToHex(value, digits.ToInt());
}

inline String IntToHex(const Int64& value, const Integer& digits) {
    return IntToHex(value, digits.ToInt());
}

inline String IntToHex(const Byte& value, const Integer& digits) {
    return IntToHex(value, digits.ToInt());
}

inline String IntToHex(const Word& value, const Integer& digits) {
    return IntToHex(value, digits.ToInt());
}

inline String IntToHex(const Cardinal& value, const Integer& digits) {
    return IntToHex(value, digits.ToInt());
}

inline String IntToHex(const UInt64& value, const Integer& digits) {
    return IntToHex(value, digits.ToInt());
}

inline Integer HexToInt(const String& s) {
    try {
        std::string narrow = s.ToNarrow();
        return Integer(std::stoi(narrow, nullptr, 16));
    } catch (const std::exception&) {
        throw std::runtime_error("Invalid hex string");
    }
}

// ============================================================================
// Val - String to numeric conversion with error code
// ============================================================================

// Val for Integer
inline void Val(const String& s, Integer& result, Integer& code) {
    try {
        std::string narrow = s.ToNarrow();
        size_t pos;
        int value = std::stoi(narrow, &pos);
        if (pos == narrow.length()) {
            result = Integer(value);
            code = Integer(0);  // Success
        } else {
            code = Integer(static_cast<int>(pos + 1));  // Error position (1-based)
        }
    } catch (...) {
        code = Integer(1);  // Error at position 1
    }
}

// Val for Double
inline void Val(const String& s, Double& result, Integer& code) {
    try {
        std::string narrow = s.ToNarrow();
        size_t pos;
        double value = std::stod(narrow, &pos);
        if (pos == narrow.length()) {
            result = Double(value);
            code = Integer(0);  // Success
        } else {
            code = Integer(static_cast<int>(pos + 1));  // Error position (1-based)
        }
    } catch (...) {
        code = Integer(1);  // Error at position 1
    }
}

// ============================================================================
// Str - Numeric to string conversion
// ============================================================================

// Str for Integer
inline void Str(const Integer& value, String& result) {
    result = IntToStr(value);
}

inline void Str(int value, String& result) {
    result = IntToStr(value);
}

// Str for Integer with width
inline void Str(const Integer& value, const Integer& width, String& result) {
    std::ostringstream oss;
    oss << std::setw(width.ToInt()) << value.ToInt();
    std::string narrow = oss.str();
    result = String(narrow.c_str());
}

inline void Str(int value, int width, String& result) {
    std::ostringstream oss;
    oss << std::setw(width) << value;
    std::string narrow = oss.str();
    result = String(narrow.c_str());
}

// Str for Double
inline void Str(const Double& value, String& result) {
    result = FloatToStr(value);
}

inline void Str(double value, String& result) {
    result = FloatToStr(Double(value));
}

// Str for Double with width and decimals
inline void Str(const Double& value, const Integer& width, const Integer& decimals, String& result) {
    std::ostringstream oss;
    oss << std::setw(width.ToInt()) << std::fixed << std::setprecision(decimals.ToInt()) << value.ToDouble();
    std::string narrow = oss.str();
    result = String(narrow.c_str());
}

inline void Str(double value, int width, int decimals, String& result) {
    std::ostringstream oss;
    oss << std::setw(width) << std::fixed << std::setprecision(decimals) << value;
    std::string narrow = oss.str();
    result = String(narrow.c_str());
}

// ============================================================================
// UniqueString - Ensure string has unique copy (COW semantics)
// ============================================================================

inline void UniqueString(String& s) {
    // C++ strings are already copy-on-write in most implementations
    // or use move semantics. This is a no-op for modern C++ but
    // provided for compatibility with Delphi semantics.
    // Force a copy by creating temp and assigning back
    String temp = s;
    s = temp;
}

} // namespace bp
