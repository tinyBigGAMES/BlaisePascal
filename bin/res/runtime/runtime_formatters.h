/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_formatters.h - std::formatter specializations for bp:: types
// Enables C++20 std::format to work with Blaise Pascal wrapped types

#pragma once

#include "runtime_types.h"
#include <format>

// ============================================================================
// std::formatter Specializations for bp:: Types
// These specializations allow bp:: types to be used with std::format
// ============================================================================

// Helper macro to reduce boilerplate for integral types
#define BP_DEFINE_INTEGRAL_FORMATTER(TYPE, CONVERTER) \
template<> \
struct std::formatter<bp::TYPE> : std::formatter<std::remove_cvref_t<decltype(std::declval<bp::TYPE>().CONVERTER())>> { \
    auto format(const bp::TYPE& value, std::format_context& ctx) const { \
        return std::formatter<std::remove_cvref_t<decltype(value.CONVERTER())>>::format(value.CONVERTER(), ctx); \
    } \
}

// Helper macro for floating-point types
#define BP_DEFINE_FLOAT_FORMATTER(TYPE, CONVERTER) \
template<> \
struct std::formatter<bp::TYPE> : std::formatter<std::remove_cvref_t<decltype(std::declval<bp::TYPE>().CONVERTER())>> { \
    auto format(const bp::TYPE& value, std::format_context& ctx) const { \
        return std::formatter<std::remove_cvref_t<decltype(value.CONVERTER())>>::format(value.CONVERTER(), ctx); \
    } \
}

// Integer Types
BP_DEFINE_INTEGRAL_FORMATTER(Integer, ToInt);
BP_DEFINE_INTEGRAL_FORMATTER(Int64, ToInt64);
BP_DEFINE_INTEGRAL_FORMATTER(Cardinal, ToCardinal);
BP_DEFINE_INTEGRAL_FORMATTER(Byte, ToByte);
BP_DEFINE_INTEGRAL_FORMATTER(Word, ToWord);
BP_DEFINE_INTEGRAL_FORMATTER(ShortInt, ToShortInt);
BP_DEFINE_INTEGRAL_FORMATTER(SmallInt, ToSmallInt);

// Floating-Point Types
BP_DEFINE_FLOAT_FORMATTER(Single, ToFloat);
BP_DEFINE_FLOAT_FORMATTER(Double, ToDouble);
BP_DEFINE_FLOAT_FORMATTER(Extended, ToLongDouble);

// Boolean Type
template<>
struct std::formatter<bp::Boolean> : std::formatter<std::string_view> {
    auto format(const bp::Boolean& value, std::format_context& ctx) const {
        return std::formatter<std::string_view>::format(value.ToBool() ? "True" : "False", ctx);
    }
};

// Char Type - format as a single character
template<>
struct std::formatter<bp::Char> : std::formatter<char> {
    auto format(const bp::Char& value, std::format_context& ctx) const {
        return std::formatter<char>::format(value.ToChar(), ctx);
    }
};

// String Type - format as string using narrow conversion
template<>
struct std::formatter<bp::String> : std::formatter<std::string_view> {
    auto format(const bp::String& value, std::format_context& ctx) const {
        return std::formatter<std::string_view>::format(value.ToNarrow(), ctx);
    }
};

// Pointer Type - format as void* address
template<>
struct std::formatter<bp::Pointer> : std::formatter<const void*> {
    auto format(const bp::Pointer& value, std::format_context& ctx) const {
        return std::formatter<const void*>::format(value.ToVoidPtr(), ctx);
    }
};

// Clean up helper macros
#undef BP_DEFINE_INTEGRAL_FORMATTER
#undef BP_DEFINE_FLOAT_FORMATTER
