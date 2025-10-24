/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_string.h - Blaise Pascal string manipulation functions (UTF-16)

#pragma once

#include "runtime_types.h"
#include <algorithm>
#include <cctype>

namespace bp {

// ============================================================================
// String Manipulation Functions
// ============================================================================

inline String Copy(const String& s, int index, int count) {
    return String(s.GetStdU16String().substr(index - 1, count));
}

inline String Copy(const String& s, const Integer& index, const Integer& count) {
    return String(s.GetStdU16String().substr(index.ToInt() - 1, count.ToInt()));
}

inline void Delete(String& s, int index, int count) {
    std::u16string temp = s.GetStdU16String();
    temp.erase(index - 1, count);
    s = temp;
}

inline void Delete(String& s, const Integer& index, const Integer& count) {
    std::u16string temp = s.GetStdU16String();
    temp.erase(index.ToInt() - 1, count.ToInt());
    s = temp;
}

inline void Insert(const String& source, String& dest, int index) {
    std::u16string temp = dest.GetStdU16String();
    temp.insert(index - 1, source.c_str());
    dest = temp;
}

inline void Insert(const String& source, String& dest, const Integer& index) {
    std::u16string temp = dest.GetStdU16String();
    temp.insert(index.ToInt() - 1, source.c_str());
    dest = temp;
}

inline int Pos(const String& substr, const String& str) {
    size_t pos = str.GetStdU16String().find(substr.c_str());
    return (pos == std::u16string::npos) ? 0 : static_cast<int>(pos) + 1;
}

inline String UpperCase(const String& s) {
    // For ASCII characters only (cross-platform compatible)
    std::u16string result = s.GetStdU16String();
    for (char16_t& c : result) {
        if (c >= u'a' && c <= u'z') {
            c = c - (u'a' - u'A');
        }
    }
    return String(result);
}

inline String LowerCase(const String& s) {
    // For ASCII characters only (cross-platform compatible)
    std::u16string result = s.GetStdU16String();
    for (char16_t& c : result) {
        if (c >= u'A' && c <= u'Z') {
            c = c + (u'a' - u'A');
        }
    }
    return String(result);
}

inline String Trim(const String& s) {
    std::u16string str = s.GetStdU16String();
    size_t start = str.find_first_not_of(u" \t\n\r");
    size_t end = str.find_last_not_of(u" \t\n\r");
    
    if (start == std::u16string::npos)
        return String(u"");
    
    return String(str.substr(start, end - start + 1));
}

inline String TrimLeft(const String& s) {
    std::u16string str = s.GetStdU16String();
    size_t start = str.find_first_not_of(u" \t\n\r");
    
    if (start == std::u16string::npos)
        return String(u"");
    
    return String(str.substr(start));
}

inline String TrimRight(const String& s) {
    std::u16string str = s.GetStdU16String();
    size_t end = str.find_last_not_of(u" \t\n\r");
    
    if (end == std::u16string::npos)
        return String(u"");
    
    return String(str.substr(0, end + 1));
}

inline String StringOfChar(const Char& c, int count) {
    return String(std::u16string(count, c.ToChar16()));
}

inline String StringOfChar(const Char& c, const Integer& count) {
    return String(std::u16string(count.ToInt(), c.ToChar16()));
}

inline String StringReplace(const String& s, const String& oldPattern, const String& newPattern) {
    if (oldPattern.Length() == 0) {
        return s;  // Empty pattern returns original string
    }
    
    std::u16string result = s.GetStdU16String();
    std::u16string oldStr = oldPattern.GetStdU16String();
    std::u16string newStr = newPattern.GetStdU16String();
    
    size_t pos = 0;
    while ((pos = result.find(oldStr, pos)) != std::u16string::npos) {
        result.replace(pos, oldStr.length(), newStr);
        pos += newStr.length();
    }
    
    return String(result);
}

inline int CompareStr(const String& s1, const String& s2) {
    std::u16string str1 = s1.GetStdU16String();
    std::u16string str2 = s2.GetStdU16String();
    
    int result = str1.compare(str2);
    if (result < 0) return -1;
    if (result > 0) return 1;
    return 0;
}

inline Integer CompareStr(const String& s1, const String& s2, bool /*dummy*/) {
    return Integer(CompareStr(s1, s2));
}

inline bool SameText(const String& s1, const String& s2) {
    std::u16string str1 = s1.GetStdU16String();
    std::u16string str2 = s2.GetStdU16String();
    
    if (str1.length() != str2.length()) {
        return false;
    }
    
    for (size_t i = 0; i < str1.length(); i++) {
        char16_t c1 = str1[i];
        char16_t c2 = str2[i];
        
        // Convert to uppercase for comparison (ASCII only)
        if (c1 >= u'a' && c1 <= u'z') c1 = c1 - (u'a' - u'A');
        if (c2 >= u'a' && c2 <= u'z') c2 = c2 - (u'a' - u'A');
        
        if (c1 != c2) {
            return false;
        }
    }
    
    return true;
}

inline Boolean SameText(const String& s1, const String& s2, bool /*dummy*/) {
    return Boolean(SameText(s1, s2));
}

inline String QuotedStr(const String& s) {
    std::u16string str = s.GetStdU16String();
    std::u16string result = u"'";
    
    for (char16_t c : str) {
        if (c == u'\'') {
            result += u"''";  // Escape single quotes by doubling them
        } else {
            result += c;
        }
    }
    
    result += u"'";
    return String(result);
}

// ============================================================================
// Array Helper Functions
// ============================================================================

// SetLength - Resize a dynamic array
template<typename T>
inline void SetLength(Array<T>& arr, int newlen) {
    arr.SetLength(newlen);
}

template<typename T>
inline void SetLength(Array<T>& arr, const Integer& newlen) {
    arr.SetLength(newlen.ToInt());
}

// SetLength - Resize a string
inline void SetLength(String& s, int newlen) {
    s.SetLength(newlen);
}

inline void SetLength(String& s, const Integer& newlen) {
    s.SetLength(newlen.ToInt());
}

// Length - Get string length
inline int Length(const String& s) {
    return s.Length();
}

inline Integer Length(const String& s, bool /*dummy*/) {
    return Integer(s.Length());
}

// Length - Get array length
template<typename T>
inline int Length(const Array<T>& arr) {
    return arr.Length();
}

template<typename T>
inline Integer Length(const Array<T>& arr, bool /*dummy*/) {
    return Integer(arr.Length());
}

// High - Get highest valid index
template<typename T>
inline int High(const Array<T>& arr) {
    return arr.High();
}

template<typename T>
inline Integer High(const Array<T>& arr, bool /*dummy*/) {
    return Integer(arr.High());
}

// Low - Get lowest valid index (always 0 for dynamic arrays)
template<typename T>
inline int Low(const Array<T>& arr) {
    return arr.Low();
}

template<typename T>
inline Integer Low(const Array<T>& arr, bool /*dummy*/) {
    return Integer(arr.Low());
}

// Low/High - Get bounds for static arrays
template<typename T, std::size_t N>
inline int Low(const StaticArray<T, N>& arr) {
    return 0;
}

template<typename T, std::size_t N>
inline Integer Low(const StaticArray<T, N>& arr, bool /*dummy*/) {
    return Integer(0);
}

template<typename T, std::size_t N>
inline int High(const StaticArray<T, N>& arr) {
    return static_cast<int>(N - 1);
}

template<typename T, std::size_t N>
inline Integer High(const StaticArray<T, N>& arr, bool /*dummy*/) {
    return Integer(static_cast<int>(N - 1));
}

// Copy - Create a copy of array elements
template<typename T>
inline Array<T> Copy(const Array<T>& arr, int index, int count) {
    // Handle out of bounds gracefully
    int arrLen = arr.Length();
    
    // If index is beyond array bounds, return empty array
    if (index >= arrLen || index < 0) {
        return Array<T>();
    }
    
    // Adjust count if it exceeds array bounds
    int actualCount = count;
    if (index + count > arrLen) {
        actualCount = arrLen - index;
    }
    
    // Ensure count is not negative
    if (actualCount < 0) {
        actualCount = 0;
    }
    
    Array<T> result(actualCount);
    for (int i = 0; i < actualCount; i++) {
        result[i] = arr[index + i];
    }
    return result;
}

template<typename T>
inline Array<T> Copy(const Array<T>& arr, const Integer& index, const Integer& count) {
    return Copy(arr, index.ToInt(), count.ToInt());
}

} // namespace bp
