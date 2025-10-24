/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_math.h - Blaise Pascal math functions

#pragma once

#include "runtime_types.h"
#include <cmath>
#include <cstdlib>
#include <ctime>

namespace bp {

// ============================================================================
// Absolute Value Functions
// ============================================================================

inline Integer Abs(const Integer& value) {
    return Integer(std::abs(value.ToInt()));
}

inline Int64 Abs(const Int64& value) {
    return Int64(std::abs(value.ToInt64()));
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

// ============================================================================
// Square Functions
// ============================================================================

inline Integer Sqr(const Integer& value) {
    int v = value.ToInt();
    return Integer(v * v);
}

inline Int64 Sqr(const Int64& value) {
    long long v = value.ToInt64();
    return Int64(v * v);
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

// ============================================================================
// Square Root Functions
// ============================================================================

inline Single Sqrt(const Single& value) {
    return Single(std::sqrt(value.ToFloat()));
}

inline Double Sqrt(const Double& value) {
    return Double(std::sqrt(value.ToDouble()));
}

inline Extended Sqrt(const Extended& value) {
    return Extended(std::sqrtl(value.ToLongDouble()));
}

// ============================================================================
// Trigonometric Functions - Sin
// ============================================================================

inline Single Sin(const Single& value) {
    return Single(std::sin(value.ToFloat()));
}

inline Double Sin(const Double& value) {
    return Double(std::sin(value.ToDouble()));
}

inline Extended Sin(const Extended& value) {
    return Extended(std::sinl(value.ToLongDouble()));
}

// ============================================================================
// Trigonometric Functions - Cos
// ============================================================================

inline Single Cos(const Single& value) {
    return Single(std::cos(value.ToFloat()));
}

inline Double Cos(const Double& value) {
    return Double(std::cos(value.ToDouble()));
}

inline Extended Cos(const Extended& value) {
    return Extended(std::cosl(value.ToLongDouble()));
}

// ============================================================================
// Trigonometric Functions - Tan
// ============================================================================

inline Single Tan(const Single& value) {
    return Single(std::tan(value.ToFloat()));
}

inline Double Tan(const Double& value) {
    return Double(std::tan(value.ToDouble()));
}

inline Extended Tan(const Extended& value) {
    return Extended(std::tanl(value.ToLongDouble()));
}

// ============================================================================
// Trigonometric Functions - ArcSin
// ============================================================================

inline Single ArcSin(const Single& value) {
    return Single(std::asin(value.ToFloat()));
}

inline Double ArcSin(const Double& value) {
    return Double(std::asin(value.ToDouble()));
}

inline Extended ArcSin(const Extended& value) {
    return Extended(std::asinl(value.ToLongDouble()));
}

// ============================================================================
// Trigonometric Functions - ArcCos
// ============================================================================

inline Single ArcCos(const Single& value) {
    return Single(std::acos(value.ToFloat()));
}

inline Double ArcCos(const Double& value) {
    return Double(std::acos(value.ToDouble()));
}

inline Extended ArcCos(const Extended& value) {
    return Extended(std::acosl(value.ToLongDouble()));
}

// ============================================================================
// Trigonometric Functions - ArcTan
// ============================================================================

inline Single ArcTan(const Single& value) {
    return Single(std::atan(value.ToFloat()));
}

inline Double ArcTan(const Double& value) {
    return Double(std::atan(value.ToDouble()));
}

inline Extended ArcTan(const Extended& value) {
    return Extended(std::atanl(value.ToLongDouble()));
}

// ============================================================================
// Logarithm Functions
// ============================================================================

inline Single Ln(const Single& value) {
    return Single(std::log(value.ToFloat()));
}

inline Double Ln(const Double& value) {
    return Double(std::log(value.ToDouble()));
}

inline Extended Ln(const Extended& value) {
    return Extended(std::logl(value.ToLongDouble()));
}

// ============================================================================
// Exponential Functions
// ============================================================================

inline Single Exp(const Single& value) {
    return Single(std::exp(value.ToFloat()));
}

inline Double Exp(const Double& value) {
    return Double(std::exp(value.ToDouble()));
}

inline Extended Exp(const Extended& value) {
    return Extended(std::expl(value.ToLongDouble()));
}

// ============================================================================
// Truncate Functions
// ============================================================================

inline Integer Trunc(const Single& value) {
    return Integer(static_cast<int>(value.ToFloat()));
}

inline Integer Trunc(const Double& value) {
    return Integer(static_cast<int>(value.ToDouble()));
}

inline Integer Trunc(const Extended& value) {
    return Integer(static_cast<int>(value.ToLongDouble()));
}

inline Int64 Trunc64(const Single& value) {
    return Int64(static_cast<long long>(value.ToFloat()));
}

inline Int64 Trunc64(const Double& value) {
    return Int64(static_cast<long long>(value.ToDouble()));
}

inline Int64 Trunc64(const Extended& value) {
    return Int64(static_cast<long long>(value.ToLongDouble()));
}

// ============================================================================
// Round Functions
// ============================================================================

inline Integer Round(const Single& value) {
    return Integer(static_cast<int>(std::round(value.ToFloat())));
}

inline Integer Round(const Double& value) {
    return Integer(static_cast<int>(std::round(value.ToDouble())));
}

inline Integer Round(const Extended& value) {
    return Integer(static_cast<int>(std::roundl(value.ToLongDouble())));
}

inline Int64 Round64(const Single& value) {
    return Int64(static_cast<long long>(std::round(value.ToFloat())));
}

inline Int64 Round64(const Double& value) {
    return Int64(static_cast<long long>(std::round(value.ToDouble())));
}

inline Int64 Round64(const Extended& value) {
    return Int64(static_cast<long long>(std::roundl(value.ToLongDouble())));
}

// ============================================================================
// Int and Frac Functions
// ============================================================================

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

// ============================================================================
// Ceil Function - Round up to nearest integer
// ============================================================================

inline Single Ceil(const Single& value) {
    return Single(std::ceil(value.ToFloat()));
}

inline Double Ceil(const Double& value) {
    return Double(std::ceil(value.ToDouble()));
}

inline Extended Ceil(const Extended& value) {
    return Extended(std::ceill(value.ToLongDouble()));
}

// ============================================================================
// Floor Function - Round down to nearest integer
// ============================================================================

inline Single Floor(const Single& value) {
    return Single(std::floor(value.ToFloat()));
}

inline Double Floor(const Double& value) {
    return Double(std::floor(value.ToDouble()));
}

inline Extended Floor(const Extended& value) {
    return Extended(std::floorl(value.ToLongDouble()));
}

// ============================================================================
// Power Function
// ============================================================================

inline Single Power(const Single& base, const Single& exponent) {
    return Single(std::pow(base.ToFloat(), exponent.ToFloat()));
}

inline Double Power(const Double& base, const Double& exponent) {
    return Double(std::pow(base.ToDouble(), exponent.ToDouble()));
}

inline Extended Power(const Extended& base, const Extended& exponent) {
    return Extended(std::powl(base.ToLongDouble(), exponent.ToLongDouble()));
}

// ============================================================================
// Random Number Functions
// ============================================================================

inline void Randomize() {
    std::srand(static_cast<unsigned int>(std::time(nullptr)));
}

inline Integer Random(const Integer& range) {
    return Integer(std::rand() % range.ToInt());
}

inline Double Random() {
    return Double(static_cast<double>(std::rand()) / RAND_MAX);
}

// ============================================================================
// Min/Max Functions
// ============================================================================

inline Integer Min(const Integer& a, const Integer& b) {
    return Integer(std::min(a.ToInt(), b.ToInt()));
}

inline Int64 Min(const Int64& a, const Int64& b) {
    return Int64(std::min(a.ToInt64(), b.ToInt64()));
}

inline Single Min(const Single& a, const Single& b) {
    return Single(std::min(a.ToFloat(), b.ToFloat()));
}

inline Double Min(const Double& a, const Double& b) {
    return Double(std::min(a.ToDouble(), b.ToDouble()));
}

inline Extended Min(const Extended& a, const Extended& b) {
    return Extended(std::min(a.ToLongDouble(), b.ToLongDouble()));
}

inline Integer Max(const Integer& a, const Integer& b) {
    return Integer(std::max(a.ToInt(), b.ToInt()));
}

inline Int64 Max(const Int64& a, const Int64& b) {
    return Int64(std::max(a.ToInt64(), b.ToInt64()));
}

inline Single Max(const Single& a, const Single& b) {
    return Single(std::max(a.ToFloat(), b.ToFloat()));
}

inline Double Max(const Double& a, const Double& b) {
    return Double(std::max(a.ToDouble(), b.ToDouble()));
}

inline Extended Max(const Extended& a, const Extended& b) {
    return Extended(std::max(a.ToLongDouble(), b.ToLongDouble()));
}

// ============================================================================
// Sign Functions
// ============================================================================

inline Integer Sign(const Integer& value) {
    int v = value.ToInt();
    if (v > 0) return Integer(1);
    if (v < 0) return Integer(-1);
    return Integer(0);
}

inline Integer Sign(const Single& value) {
    float v = value.ToFloat();
    if (v > 0.0f) return Integer(1);
    if (v < 0.0f) return Integer(-1);
    return Integer(0);
}

inline Integer Sign(const Double& value) {
    double v = value.ToDouble();
    if (v > 0.0) return Integer(1);
    if (v < 0.0) return Integer(-1);
    return Integer(0);
}

inline Integer Sign(const Extended& value) {
    long double v = value.ToLongDouble();
    if (v > 0.0L) return Integer(1);
    if (v < 0.0L) return Integer(-1);
    return Integer(0);
}

// ============================================================================
// Pi Constant Function
// ============================================================================

inline Double Pi() {
    return Double(3.14159265358979323846);
}

// ============================================================================
// ArcTan2 Function - Two-argument arctangent
// ============================================================================

inline Single ArcTan2(const Single& y, const Single& x) {
    return Single(std::atan2(y.ToFloat(), x.ToFloat()));
}

inline Double ArcTan2(const Double& y, const Double& x) {
    return Double(std::atan2(y.ToDouble(), x.ToDouble()));
}

inline Extended ArcTan2(const Extended& y, const Extended& x) {
    return Extended(std::atan2l(y.ToLongDouble(), x.ToLongDouble()));
}

// ============================================================================
// Hyperbolic Functions - Sinh
// ============================================================================

inline Single Sinh(const Single& value) {
    return Single(std::sinh(value.ToFloat()));
}

inline Double Sinh(const Double& value) {
    return Double(std::sinh(value.ToDouble()));
}

inline Extended Sinh(const Extended& value) {
    return Extended(std::sinhl(value.ToLongDouble()));
}

// ============================================================================
// Hyperbolic Functions - Cosh
// ============================================================================

inline Single Cosh(const Single& value) {
    return Single(std::cosh(value.ToFloat()));
}

inline Double Cosh(const Double& value) {
    return Double(std::cosh(value.ToDouble()));
}

inline Extended Cosh(const Extended& value) {
    return Extended(std::coshl(value.ToLongDouble()));
}

// ============================================================================
// Hyperbolic Functions - Tanh
// ============================================================================

inline Single Tanh(const Single& value) {
    return Single(std::tanh(value.ToFloat()));
}

inline Double Tanh(const Double& value) {
    return Double(std::tanh(value.ToDouble()));
}

inline Extended Tanh(const Extended& value) {
    return Extended(std::tanhl(value.ToLongDouble()));
}

// ============================================================================
// Inverse Hyperbolic Functions - ArcSinh
// ============================================================================

inline Single ArcSinh(const Single& value) {
    return Single(std::asinh(value.ToFloat()));
}

inline Double ArcSinh(const Double& value) {
    return Double(std::asinh(value.ToDouble()));
}

inline Extended ArcSinh(const Extended& value) {
    return Extended(std::asinhl(value.ToLongDouble()));
}

// ============================================================================
// Inverse Hyperbolic Functions - ArcCosh
// ============================================================================

inline Single ArcCosh(const Single& value) {
    return Single(std::acosh(value.ToFloat()));
}

inline Double ArcCosh(const Double& value) {
    return Double(std::acosh(value.ToDouble()));
}

inline Extended ArcCosh(const Extended& value) {
    return Extended(std::acoshl(value.ToLongDouble()));
}

// ============================================================================
// Inverse Hyperbolic Functions - ArcTanh
// ============================================================================

inline Single ArcTanh(const Single& value) {
    return Single(std::atanh(value.ToFloat()));
}

inline Double ArcTanh(const Double& value) {
    return Double(std::atanh(value.ToDouble()));
}

inline Extended ArcTanh(const Extended& value) {
    return Extended(std::atanhl(value.ToLongDouble()));
}

// ============================================================================
// Logarithm Functions - Log10
// ============================================================================

inline Single Log10(const Single& value) {
    return Single(std::log10(value.ToFloat()));
}

inline Double Log10(const Double& value) {
    return Double(std::log10(value.ToDouble()));
}

inline Extended Log10(const Extended& value) {
    return Extended(std::log10l(value.ToLongDouble()));
}

// ============================================================================
// Logarithm Functions - Log2
// ============================================================================

inline Single Log2(const Single& value) {
    return Single(std::log2(value.ToFloat()));
}

inline Double Log2(const Double& value) {
    return Double(std::log2(value.ToDouble()));
}

inline Extended Log2(const Extended& value) {
    return Extended(std::log2l(value.ToLongDouble()));
}

// ============================================================================
// Logarithm Functions - LogN (Base-N logarithm)
// ============================================================================

inline Single LogN(const Single& base, const Single& value) {
    return Single(std::log(value.ToFloat()) / std::log(base.ToFloat()));
}

inline Double LogN(const Double& base, const Double& value) {
    return Double(std::log(value.ToDouble()) / std::log(base.ToDouble()));
}

inline Extended LogN(const Extended& base, const Extended& value) {
    return Extended(std::logl(value.ToLongDouble()) / std::logl(base.ToLongDouble()));
}

} // namespace bp
