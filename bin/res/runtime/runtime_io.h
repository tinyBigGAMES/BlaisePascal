/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_io.h - Blaise Pascal I/O functions (UTF-16)

#pragma once

#include "runtime_types.h"
#include <iostream>
#include <fstream>
#include <print>
#include <filesystem>
#include <system_error>

namespace bp {

// ============================================================================
// I/O Error Handling
// ============================================================================

// Standard Delphi I/O error codes
namespace IOErrorCode {
    constexpr Integer Success = 0;
    constexpr Integer FileNotFound = 2;
    constexpr Integer PathNotFound = 3;
    constexpr Integer TooManyOpenFiles = 4;
    constexpr Integer FileAccessDenied = 5;
    constexpr Integer InvalidFileHandle = 6;
    constexpr Integer InvalidFileAccessMode = 12;
    constexpr Integer DiskFull = 101;
    constexpr Integer IOError = 103;
    constexpr Integer FileNotOpen = 104;
}

// Thread-local storage for I/O error code
inline thread_local Integer g_IOResult = IOErrorCode::Success;

// IOResult function - returns and clears the last I/O error
inline Integer IOResult() {
    Integer LResult = g_IOResult;
    g_IOResult = IOErrorCode::Success;
    return LResult;
}

// Internal helper to set I/O error code
inline void SetIOError(const Integer ACode) {
    g_IOResult = ACode;
}

// Internal helper to map system errors to Delphi error codes
inline Integer MapSystemError(const std::error_code& AError) {
    if (!AError) {
        return IOErrorCode::Success;
    }
    
    // Map common system errors to Delphi I/O error codes
    switch (AError.value()) {
        case 2:  // ENOENT - No such file or directory
            return IOErrorCode::FileNotFound;
        case 3:  // ESRCH - Path not found
            return IOErrorCode::PathNotFound;
        case 5:  // EIO - I/O error
            return IOErrorCode::IOError;
        case 13: // EACCES - Permission denied
            return IOErrorCode::FileAccessDenied;
        case 24: // EMFILE - Too many open files
            return IOErrorCode::TooManyOpenFiles;
        case 28: // ENOSPC - No space left on device
            return IOErrorCode::DiskFull;
        default:
            return IOErrorCode::IOError;
    }
}

// Forward declarations for file classes
class TextFile;
class BinaryFile;

// ============================================================================
// Console Output
// ============================================================================

// Forward declarations for proper template resolution
template<typename T>
void WriteLn(const T& value);

template<typename T, typename... Args>
void WriteLn(const T& first, const Args&... rest);

// Base case - no arguments
inline void WriteLn() {
    std::cout << std::endl;
}

// Overload for wide string literals - convert to String first (non-template takes priority)
inline void WriteLn(const wchar_t* value) {
    std::cout << String(value) << std::endl;
}

// Single argument version (must come before variadic version)
template<typename T>
void WriteLn(const T& value) {
    std::cout << value << std::endl;
}

// Variadic versions (depend on single-argument versions above)
template<typename... Args>
void WriteLn(const wchar_t* first, const Args&... rest) {
    std::cout << String(first);
    WriteLn(rest...);
}

template<typename T, typename... Args>
void WriteLn(const T& first, const Args&... rest) {
    std::cout << first;
    WriteLn(rest...);
}

// Forward declarations for Write
template<typename T>
void Write(const T& value);

template<typename T, typename... Args>
void Write(const T& first, const Args&... rest);

// Overload for wide string literals - convert to String first (non-template takes priority)
inline void Write(const wchar_t* value) {
    std::cout << String(value);
}

// Single argument version
template<typename T>
void Write(const T& value) {
    std::cout << value;
}

// Variadic versions
template<typename... Args>
void Write(const wchar_t* first, const Args&... rest) {
    std::cout << String(first);
    Write(rest...);
}

template<typename T, typename... Args>
void Write(const T& first, const Args&... rest) {
    std::cout << first;
    Write(rest...);
}

// ============================================================================
// Console Input
// ============================================================================

template<typename T>
void Read(T& value) {
    std::cin >> value;
}

template<typename T, typename... Args>
void Read(T& first, Args&... rest) {
    std::cin >> first;
    Read(rest...);
}

inline void ReadLn(String& s) {
    std::string temp;
    std::getline(std::cin, temp);
    s = String(temp.c_str());
}

template<typename T>
void ReadLn(T& value) {
    std::cin >> value;
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

// ============================================================================
// File I/O - TextFile class
// ============================================================================

class TextFile {
private:
    std::unique_ptr<std::wfstream> file;
    String filename;

public:
    TextFile() : file(std::make_unique<std::wfstream>()) {}
    
    void Assign(const String& fname) { 
        filename = fname;
        SetIOError(IOErrorCode::Success);
    }
    
    void Reset() {
        try {
            file = std::make_unique<std::wfstream>();
            file->open(filename.c_str_wide(), std::ios::in);
            if (!file->is_open()) {
                SetIOError(IOErrorCode::FileNotFound);
            } else {
                file->imbue(std::locale(""));
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Rewrite() {
        try {
            file = std::make_unique<std::wfstream>();
            file->open(filename.c_str_wide(), std::ios::out | std::ios::trunc);
            if (!file->is_open()) {
                SetIOError(IOErrorCode::FileAccessDenied);
            } else {
                file->imbue(std::locale(""));
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Append() {
        try {
            file = std::make_unique<std::wfstream>();
            file->open(filename.c_str_wide(), std::ios::app);
            if (!file->is_open()) {
                SetIOError(IOErrorCode::FileAccessDenied);
            } else {
                file->imbue(std::locale(""));
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Close() {
        try {
            if (file && file->is_open()) {
                file->close();
            }
            SetIOError(IOErrorCode::Success);
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Flush() {
        try {
            file->flush();
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    bool Eof() const {
        if (!file || !file->is_open()) {
            return true;
        }
        return file->peek() == std::char_traits<wchar_t>::eof();
    }
    
    void Erase() {
        try {
            Close();
            std::error_code LError;
            std::filesystem::remove(filename.c_str_wide(), LError);
            SetIOError(MapSystemError(LError));
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Rename(const String& newname) {
        try {
            Close();
            std::error_code LError;
            std::filesystem::rename(filename.c_str_wide(), newname.c_str_wide(), LError);
            if (!LError) {
                filename = newname;
            }
            SetIOError(MapSystemError(LError));
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    template<typename T>
    void Read(T& value) {
        try {
            *file >> value;
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    // Specialized Read overloads for bp wrapped types
    // These are needed because bp types have operator>> for std::istream (narrow)
    // but TextFile uses std::wfstream (wide stream)
    
    void Read(Integer& value) {
        try {
            int LTemp;
            *file >> LTemp;
            value = Integer(LTemp);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(Int64& value) {
        try {
            long long LTemp;
            *file >> LTemp;
            value = Int64(LTemp);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(Cardinal& value) {
        try {
            unsigned int LTemp;
            *file >> LTemp;
            value = Cardinal(LTemp);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(Byte& value) {
        try {
            unsigned int LTemp;
            *file >> LTemp;
            value = Byte(static_cast<unsigned char>(LTemp));
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(Word& value) {
        try {
            unsigned int LTemp;
            *file >> LTemp;
            value = Word(static_cast<unsigned short>(LTemp));
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(ShortInt& value) {
        try {
            int LTemp;
            *file >> LTemp;
            value = ShortInt(static_cast<signed char>(LTemp));
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(SmallInt& value) {
        try {
            int LTemp;
            *file >> LTemp;
            value = SmallInt(static_cast<short>(LTemp));
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(Double& value) {
        try {
            double LTemp;
            *file >> LTemp;
            value = Double(LTemp);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(Single& value) {
        try {
            float LTemp;
            *file >> LTemp;
            value = Single(LTemp);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(Extended& value) {
        try {
            long double LTemp;
            *file >> LTemp;
            value = Extended(LTemp);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(String& value) {
        try {
            std::wstring LTemp;
            *file >> LTemp;
            value = String(LTemp);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Read(Char& value) {
        try {
            wchar_t LTemp;
            // Skip whitespace like stream >> operator does
            *file >> std::ws;  // Skip leading whitespace
            file->get(LTemp);
            value = Char(LTemp);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    template<typename T>
    void Write(const T& value) {
        try {
            *file << value;
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    // Specialized Write for bp::String - writes to wide stream
    void Write(const String& value) {
        try {
            // Write the String to wide stream
            for (int LI = 1; LI <= value.Length(); LI++) {
                file->put(static_cast<wchar_t>(value[LI]));
            }
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    // Specialized Write for wide string literals
    void Write(const wchar_t* value) {
        try {
            // Write character by character to preserve ALL characters including trailing spaces
            // Using file << value can strip trailing spaces depending on locale
            while (*value) {
                file->put(*value++);
            }
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void WriteLn() {
        try {
            *file << std::endl;
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    template<typename T>
    void WriteLn(const T& value) {
        try {
            *file << value << std::endl;
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    // Specialized WriteLn for bp::String
    void WriteLn(const String& value) {
        Write(value);
        WriteLn();
    }
    
    // Specialized WriteLn for wide string literals
    void WriteLn(const wchar_t* value) {
        // Use Write which preserves trailing spaces, then add newline
        Write(value);
        WriteLn();
    }
    
    void ReadLn(String& s) {
        try {
            std::wstring temp;
            std::getline(*file, temp);
            s = String(temp);
            if (file->fail() && !file->eof()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    bool SeekEof() {
        try {
            while (file->peek() == L' ' || file->peek() == L'\t') {
                file->get();
            }
            return file->eof() || file->peek() == WEOF;
        } catch (const std::exception&) {
            return true;
        }
    }
    
    bool SeekEoln() {
        try {
            while (file->peek() == L' ' || file->peek() == L'\t') {
                file->get();
            }
            return file->peek() == L'\n' || file->peek() == L'\r' || file->eof();
        } catch (const std::exception&) {
            return true;
        }
    }
    
    bool Eoln() const {
        try {
            wchar_t LChar = file->peek();
            return LChar == L'\n' || LChar == L'\r' || file->eof();
        } catch (const std::exception&) {
            return true;
        }
    }
    
    const String& GetFilename() const {
        return filename;
    }
};

// ============================================================================
// File I/O - BinaryFile class
// ============================================================================

class BinaryFile {
private:
    std::unique_ptr<std::fstream> file;
    String filename;
    Integer recordSize;  // Record size for typed files (0 = untyped)
    
    // Private helper to set I/O error (for const methods)
    void SetIOError(const Integer ACode) const {
        bp::SetIOError(ACode);
    }

public:
    BinaryFile() : file(std::make_unique<std::fstream>()), recordSize(0) {}
    
    void Assign(const String& fname) { 
        filename = fname;
        recordSize = 0;  // Reset to untyped
        SetIOError(IOErrorCode::Success);
    }
    
    void Reset() {
        try {
            file = std::make_unique<std::fstream>();
            file->open(filename.c_str_wide(), std::ios::in | std::ios::binary);
            if (!file->is_open()) {
                SetIOError(IOErrorCode::FileNotFound);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Reset(const Integer ARecordSize) {
        recordSize = ARecordSize;
        Reset();
    }
    
    void Rewrite() {
        try {
            file = std::make_unique<std::fstream>();
            file->open(filename.c_str_wide(), std::ios::out | std::ios::binary);
            if (!file->is_open()) {
                SetIOError(IOErrorCode::FileAccessDenied);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Rewrite(const Integer ARecordSize) {
        recordSize = ARecordSize;
        Rewrite();
    }
    
    void Close() {
        try {
            if (file && file->is_open()) {
                file->close();
            }
            SetIOError(IOErrorCode::Success);
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Flush() {
        try {
            file->flush();
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    bool Eof() const {
        if (!file || !file->is_open()) {
            return true;
        }
        return file->peek() == std::char_traits<char>::eof();
    }
    
    void Truncate() {
        try {
            auto current_pos = file->tellp();
            file->close();
            std::error_code LError;
            std::filesystem::resize_file(filename.c_str_wide(), static_cast<std::uintmax_t>(current_pos), LError);
            if (!LError) {
                file->open(filename.c_str_wide(), std::ios::in | std::ios::out | std::ios::binary);
                file->seekp(current_pos);
            }
            SetIOError(MapSystemError(LError));
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Erase() {
        try {
            Close();
            std::error_code LError;
            std::filesystem::remove(filename.c_str_wide(), LError);
            SetIOError(MapSystemError(LError));
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Rename(const String& newname) {
        try {
            Close();
            std::error_code LError;
            std::filesystem::rename(filename.c_str_wide(), newname.c_str_wide(), LError);
            if (!LError) {
                filename = newname;
            }
            SetIOError(MapSystemError(LError));
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    template<typename T>
    Integer BlockRead(T& buffer, const Integer count) {
        try {
            // For arrays/containers, calculate total bytes: count * sizeof(element)
            // For single objects, count represents number of bytes
            size_t bytes_to_read;
            
            // Check if T is an array-like type (has operator[])
            if constexpr (requires { buffer[0]; }) {
                // It's an array - count is number of elements
                using ElementType = std::remove_reference_t<decltype(buffer[0])>;
                bytes_to_read = count.ToInt() * sizeof(ElementType);
            } else {
                // It's a single object - count is number of bytes
                bytes_to_read = count.ToInt();
            }
            
            file->read(reinterpret_cast<char*>(&buffer), static_cast<std::streamsize>(bytes_to_read));
            Integer LBytesRead = static_cast<Integer>(file->gcount());
            if (file->fail() && !file->eof()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
            // Return number of records read (bytes / element_size)
            if constexpr (requires { buffer[0]; }) {
                using ElementType = std::remove_reference_t<decltype(buffer[0])>;
                return static_cast<Integer>(LBytesRead.ToInt() / sizeof(ElementType));
            } else {
                return LBytesRead;
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
            return 0;
        }
    }
    
    template<typename T>
    Integer BlockWrite(const T& buffer, const Integer count) {
        try {
            // For arrays/containers, calculate total bytes: count * sizeof(element)
            // For single objects, count represents number of bytes
            size_t bytes_to_write;
            
            // Check if T is an array-like type (has operator[])
            if constexpr (requires { buffer[0]; }) {
                // It's an array - count is number of elements
                using ElementType = std::remove_reference_t<decltype(buffer[0])>;
                bytes_to_write = count.ToInt() * sizeof(ElementType);
            } else {
                // It's a single object - count is number of bytes
                bytes_to_write = count.ToInt();
            }
            
            auto pos_before = file->tellp();
            file->write(reinterpret_cast<const char*>(&buffer), static_cast<std::streamsize>(bytes_to_write));
            auto pos_after = file->tellp();
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
                return 0;
            }
            SetIOError(IOErrorCode::Success);
            // Return number of records written (bytes / element_size)
            Integer bytes_written = static_cast<Integer>(pos_after - pos_before);
            if constexpr (requires { buffer[0]; }) {
                using ElementType = std::remove_reference_t<decltype(buffer[0])>;
                return static_cast<Integer>(bytes_written.ToInt() / sizeof(ElementType));
            } else {
                return bytes_written;
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
            return 0;
        }
    }
    
    template<typename T>
    void Read(T& value) {
        try {
            file->read(reinterpret_cast<char*>(&value), sizeof(T));
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    template<typename T>
    void Write(const T& value) {
        try {
            file->write(reinterpret_cast<const char*>(&value), sizeof(T));
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    void Seek(const Integer position) {
        try {
            // For typed files, position is a record number; for untyped files, it's a byte offset
            std::streamoff byte_position = (recordSize > 0) 
                ? static_cast<std::streamoff>(position.ToInt() * recordSize.ToInt())
                : static_cast<std::streamoff>(position.ToInt());
            
            file->seekg(byte_position, std::ios::beg);
            file->seekp(byte_position, std::ios::beg);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
            } else {
                SetIOError(IOErrorCode::Success);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
        }
    }
    
    Integer FilePos() const {
        try {
            auto byte_pos = file->tellg();
            // For typed files, return record number; for untyped files, return byte position
            if (recordSize > 0) {
                return static_cast<Integer>(byte_pos / recordSize.ToInt());
            } else {
                return static_cast<Integer>(byte_pos);
            }
        } catch (const std::exception&) {
            const_cast<BinaryFile*>(this)->SetIOError(IOErrorCode::IOError);
            return 0;
        }
    }
    
    Integer FileSize() {
        try {
            auto current_pos = file->tellg();
            file->seekg(0, std::ios::end);
            auto byte_size = file->tellg();
            file->seekg(current_pos, std::ios::beg);
            if (file->fail()) {
                SetIOError(IOErrorCode::IOError);
                return 0;
            }
            SetIOError(IOErrorCode::Success);
            // For typed files, return number of records; for untyped files, return byte size
            if (recordSize > 0) {
                return static_cast<Integer>(byte_size / recordSize.ToInt());
            } else {
                return static_cast<Integer>(byte_size);
            }
        } catch (const std::exception&) {
            SetIOError(IOErrorCode::IOError);
            return 0;
        }
    }
    
    const String& GetFilename() const {
        return filename;
    }
};

// ============================================================================
// Untyped File Support (Delphi File type)
// ============================================================================

// In Delphi, an untyped 'File' variable is used for binary/typed file I/O
// Map it to BinaryFile for C++ runtime
using File = BinaryFile;

// Wrapper functions for Delphi-style untyped File operations
// Note: BinaryFile now has built-in overloads for Reset/Rewrite with record size

inline void AssignFile(BinaryFile& f, const String& filename) {
    f.Assign(filename);
}

inline void AssignFile(TextFile& f, const String& filename) {
    f.Assign(filename);
}

inline void CloseFile(BinaryFile& f) {
    f.Close();
}

inline void CloseFile(TextFile& f) {
    f.Close();
}

// BlockRead with count and result parameter
template<typename T>
inline void BlockRead(BinaryFile& f, T& buffer, const Integer count, Integer& result) {
    result = f.BlockRead(buffer, count);
}

// BlockWrite with count and result parameter
template<typename T>
inline void BlockWrite(BinaryFile& f, const T& buffer, const Integer count, Integer& result) {
    result = f.BlockWrite(buffer, count);
}

// ============================================================================
// Global File I/O Functions (Delphi-style semantics)
// ============================================================================

inline void Assign(TextFile& f, const String& filename) {
    f.Assign(filename);
}

inline void Assign(BinaryFile& f, const String& filename) {
    f.Assign(filename);
}

inline void Reset(TextFile& f) {
    f.Reset();
}

inline void Reset(BinaryFile& f) {
    f.Reset();
}

inline void Reset(BinaryFile& f, const Integer recordSize) {
    f.Reset(recordSize);
}

inline void Rewrite(TextFile& f) {
    f.Rewrite();
}

inline void Rewrite(BinaryFile& f) {
    f.Rewrite();
}

inline void Rewrite(BinaryFile& f, const Integer recordSize) {
    f.Rewrite(recordSize);
}

inline void Append(TextFile& f) {
    f.Append();
}

inline void Close(TextFile& f) {
    f.Close();
}

inline void Close(BinaryFile& f) {
    f.Close();
}

inline void Flush(TextFile& f) {
    f.Flush();
}

inline void Flush(BinaryFile& f) {
    f.Flush();
}

inline void Truncate(BinaryFile& f) {
    f.Truncate();
}

inline void Erase(TextFile& f) {
    f.Erase();
}

inline void Erase(BinaryFile& f) {
    f.Erase();
}

inline void Rename(TextFile& f, const String& newname) {
    f.Rename(newname);
}

inline void Rename(BinaryFile& f, const String& newname) {
    f.Rename(newname);
}

template<typename T>
void Write(TextFile& f, const T& value) {
    f.Write(value);
}

template<typename T, typename... Args>
void Write(TextFile& f, const T& first, const Args&... rest) {
    f.Write(first);
    Write(f, rest...);
}

inline void WriteLn(TextFile& f) {
    f.WriteLn();
}

template<typename T>
void WriteLn(TextFile& f, const T& value) {
    f.WriteLn(value);
}

template<typename T, typename... Args>
void WriteLn(TextFile& f, const T& first, const Args&... rest) {
    f.Write(first);
    WriteLn(f, rest...);
}

template<typename T>
void Read(TextFile& f, T& value) {
    f.Read(value);
}

template<typename T, typename... Args>
void Read(TextFile& f, T& first, Args&... rest) {
    f.Read(first);
    Read(f, rest...);
}

inline void ReadLn(TextFile& f, String& s) {
    f.ReadLn(s);
}

inline bool SeekEof(TextFile& f) {
    return f.SeekEof();
}

inline bool SeekEoln(TextFile& f) {
    return f.SeekEoln();
}

inline bool Eoln(const TextFile& f) {
    return f.Eoln();
}

inline bool Eof(const TextFile& f) {
    return f.Eof();
}

template<typename T>
void Read(BinaryFile& f, T& value) {
    f.Read(value);
}

template<typename T, typename... Args>
void Read(BinaryFile& f, T& first, Args&... rest) {
    f.Read(first);
    Read(f, rest...);
}

template<typename T>
void Write(BinaryFile& f, const T& value) {
    f.Write(value);
}

template<typename T, typename... Args>
void Write(BinaryFile& f, const T& first, const Args&... rest) {
    f.Write(first);
    Write(f, rest...);
}

template<typename T>
Integer BlockRead(BinaryFile& f, T& buffer, const Integer count) {
    return f.BlockRead(buffer, count);
}

template<typename T>
Integer BlockWrite(BinaryFile& f, const T& buffer, const Integer count) {
    return f.BlockWrite(buffer, count);
}

inline void Seek(BinaryFile& f, const Integer position) {
    f.Seek(position);
}

inline Integer FilePos(const BinaryFile& f) {
    return f.FilePos();
}

inline Integer FileSize(BinaryFile& f) {
    return f.FileSize();
}

inline bool Eof(const BinaryFile& f) {
    return f.Eof();
}

// ============================================================================
// File System Functions (Unicode path support)
// ============================================================================

inline Boolean FileExists(const String& filename) {
    try {
        std::error_code LError;
        bool LExists = std::filesystem::exists(filename.c_str_wide(), LError);
        if (LError) {
            return Boolean(false);
        }
        return Boolean(LExists && std::filesystem::is_regular_file(filename.c_str_wide(), LError));
    } catch (const std::exception&) {
        return Boolean(false);
    }
}

inline Boolean RemoveFile(const String& filename) {
    try {
        std::error_code LError;
        bool LResult = std::filesystem::remove(filename.c_str_wide(), LError);
        if (LError) {
            SetIOError(MapSystemError(LError));
            return Boolean(false);
        }
        SetIOError(IOErrorCode::Success);
        return Boolean(LResult);
    } catch (const std::exception&) {
        SetIOError(IOErrorCode::IOError);
        return Boolean(false);
    }
}

inline Boolean RenameFile(const String& oldname, const String& newname) {
    try {
        std::error_code LError;
        std::filesystem::rename(oldname.c_str_wide(), newname.c_str_wide(), LError);
        if (LError) {
            SetIOError(MapSystemError(LError));
            return Boolean(false);
        }
        SetIOError(IOErrorCode::Success);
        return Boolean(true);
    } catch (const std::exception&) {
        SetIOError(IOErrorCode::IOError);
        return Boolean(false);
    }
}

inline Boolean DirectoryExists(const String& dirname) {
    try {
        std::error_code LError;
        bool LExists = std::filesystem::exists(dirname.c_str_wide(), LError);
        if (LError) {
            return Boolean(false);
        }
        return Boolean(LExists && std::filesystem::is_directory(dirname.c_str_wide(), LError));
    } catch (const std::exception&) {
        return Boolean(false);
    }
}

inline Boolean CreateDir(const String& dirname) {
    try {
        std::error_code LError;
        bool LResult = std::filesystem::create_directory(dirname.c_str_wide(), LError);
        if (LError) {
            SetIOError(MapSystemError(LError));
            return Boolean(false);
        }
        SetIOError(IOErrorCode::Success);
        return Boolean(LResult);
    } catch (const std::exception&) {
        SetIOError(IOErrorCode::IOError);
        return Boolean(false);
    }
}

inline Boolean RemoveDir(const String& dirname) {
    try {
        std::error_code LError;
        bool LResult = std::filesystem::remove(dirname.c_str_wide(), LError);
        if (LError) {
            SetIOError(MapSystemError(LError));
            return Boolean(false);
        }
        SetIOError(IOErrorCode::Success);
        return Boolean(LResult);
    } catch (const std::exception&) {
        SetIOError(IOErrorCode::IOError);
        return Boolean(false);
    }
}

inline String GetCurrentDir() {
    try {
        std::error_code LError;
        auto LPath = std::filesystem::current_path(LError);
        if (LError) {
            SetIOError(MapSystemError(LError));
            return String(u"");
        }
        SetIOError(IOErrorCode::Success);
        return String(LPath.wstring().c_str());
    } catch (const std::exception&) {
        SetIOError(IOErrorCode::IOError);
        return String(u"");
    }
}

inline Boolean SetCurrentDir(const String& dirname) {
    try {
        std::error_code LError;
        std::filesystem::current_path(dirname.c_str_wide(), LError);
        if (LError) {
            SetIOError(MapSystemError(LError));
            return Boolean(false);
        }
        SetIOError(IOErrorCode::Success);
        return Boolean(true);
    } catch (const std::exception&) {
        SetIOError(IOErrorCode::IOError);
        return Boolean(false);
    }
}

} // namespace bp
