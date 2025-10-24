/*******************************************************************************
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
*******************************************************************************/

// runtime_control.h - Blaise Pascal control flow wrappers

#pragma once

#include "runtime_types.h"

namespace bp {

// ============================================================================
// For Loop - Evaluates end expression ONCE (critical Pascal semantic)
// ============================================================================

template<typename BodyFunc>
void PFor(int start, int end, BodyFunc body) {
    int loop_end = end;  // Evaluate once!
    for (int i = start; i <= loop_end; i++) {
        body(i);
    }
}

template<typename BodyFunc>
void PFor(const Integer& start, const Integer& end, BodyFunc body) {
    int loop_start = start.ToInt();
    int loop_end = end.ToInt();  // Evaluate once!
    for (int i = loop_start; i <= loop_end; i++) {
        body(i);
    }
}

// ============================================================================
// For-Downto Loop
// ============================================================================

template<typename BodyFunc>
void PForDownto(int start, int end, BodyFunc body) {
    int loop_end = end;  // Evaluate once!
    for (int i = start; i >= loop_end; i--) {
        body(i);
    }
}

template<typename BodyFunc>
void PForDownto(const Integer& start, const Integer& end, BodyFunc body) {
    int loop_start = start.ToInt();
    int loop_end = end.ToInt();  // Evaluate once!
    for (int i = loop_start; i >= loop_end; i--) {
        body(i);
    }
}

// ============================================================================
// Repeat-Until Loop - Condition is inverted!
// ============================================================================

template<typename BodyFunc, typename CondFunc>
void PRepeatUntil(BodyFunc body, CondFunc condition) {
    do {
        body();
    } while (!condition());  // Note: inverted!
}

} // namespace bp
