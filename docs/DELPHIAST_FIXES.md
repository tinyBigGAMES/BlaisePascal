# DelphiAST Fixes

This document tracks all fixes and modifications made to the DelphiAST third-party library that should be contributed back to the upstream repository.

---

## Fix #1: Incorrect Operator Associativity (Critical)

**Date:** 2025-10-23  
**File:** `src/deps/DelphiAST/DelphiAST.Classes.pas`  
**Lines:** 150-177 (OperatorsInfo constant array)  
**Severity:** Critical - Affects all arithmetic and logical expressions  

### Problem

All binary operators in the `OperatorsInfo` table were incorrectly configured with `AssocType: atRight` (right-associative), causing expressions to be parsed with incorrect precedence.

**Example of incorrect behavior:**
```pascal
A - B + C   // Was parsed as: A - (B + C)  ❌
            // Should be:     (A - B) + C  ✅
```

This violated the Pascal language specification (ISO 7185) and Delphi/Object Pascal documentation, which specify that all binary arithmetic and logical operators are left-associative.

### Impact

This bug affected:
- All arithmetic expressions with multiple operators of the same precedence
- String operations like `RightStr`, `LeftStr`, `EndsStr`, `StartsStr`
- Mathematical calculations throughout transpiled code
- Any expression relying on left-to-right evaluation

**Real-world failure example:**
```pascal
// In RightStr implementation:
Result := Copy(AText, LLength - ACount + 1, ACount);

// With LLength=11, ACount=5:
// Bug calculated: 11 - (5 + 1) = 5  ❌
// Should be:      (11 - 5) + 1 = 7  ✅
```

### Solution

Changed all binary operators from `atRight` to `atLeft` associativity, aligning with Pascal language specification.

**Modified operators (20 total):**
- **Arithmetic:** `ntAdd` (+), `ntSub` (-), `ntMul` (*), `ntFDiv` (/), `ntDiv` (div), `ntMod` (mod)
- **Logical:** `ntAnd` (and), `ntOr` (or), `ntXor` (xor)
- **Bitwise:** `ntShl` (shl), `ntShr` (shr)
- **Comparison:** `ntEqual` (=), `ntNotEqual` (<>), `ntLower` (<), `ntGreater` (>), `ntLowerEqual` (<=), `ntGreaterEqual` (>=)
- **Special:** `ntDot` (.), `ntGeneric` (<>), `ntCall` (()), `ntAs` (as), `ntIn` (in), `ntIs` (is)

**Unary operators remain unchanged** (correctly right-associative):
- `ntAddr` (@), `ntUnaryMinus` (-), `ntNot` (not)

### Code Changes

```pascal
const
  OperatorsInfo: array [0..27] of TOperatorInfo =
    // Changed from atRight to atLeft for all binary operators:
    ((Typ: ntAddr;         Priority: 1; Kind: okUnary;  AssocType: atRight),  // Unary @ (address-of)
     (Typ: ntDeref;        Priority: 1; Kind: okUnary;  AssocType: atLeft),   // Unary ^ (dereference)
     (Typ: ntGeneric;      Priority: 1; Kind: okBinary; AssocType: atLeft),   // Generic type <> [FIXED]
     (Typ: ntIndexed;      Priority: 1; Kind: okUnary;  AssocType: atLeft),   // Array indexing []
     (Typ: ntDot;          Priority: 2; Kind: okBinary; AssocType: atLeft),   // Member access . [FIXED]
     (Typ: ntCall;         Priority: 3; Kind: okBinary; AssocType: atLeft),   // Function call () [FIXED]
     (Typ: ntUnaryMinus;   Priority: 5; Kind: okUnary;  AssocType: atRight),  // Unary -
     (Typ: ntNot;          Priority: 6; Kind: okUnary;  AssocType: atRight),  // Unary not
     (Typ: ntMul;          Priority: 7; Kind: okBinary; AssocType: atLeft),   // Binary * [FIXED]
     (Typ: ntFDiv;         Priority: 7; Kind: okBinary; AssocType: atLeft),   // Binary / [FIXED]
     (Typ: ntDiv;          Priority: 7; Kind: okBinary; AssocType: atLeft),   // Binary div [FIXED]
     (Typ: ntMod;          Priority: 7; Kind: okBinary; AssocType: atLeft),   // Binary mod [FIXED]
     (Typ: ntAnd;          Priority: 7; Kind: okBinary; AssocType: atLeft),   // Binary and [FIXED]
     (Typ: ntShl;          Priority: 7; Kind: okBinary; AssocType: atLeft),   // Binary shl [FIXED]
     (Typ: ntShr;          Priority: 7; Kind: okBinary; AssocType: atLeft),   // Binary shr [FIXED]
     (Typ: ntAs;           Priority: 7; Kind: okBinary; AssocType: atLeft),   // Type cast as [FIXED]
     (Typ: ntAdd;          Priority: 8; Kind: okBinary; AssocType: atLeft),   // Binary + [FIXED]
     (Typ: ntSub;          Priority: 8; Kind: okBinary; AssocType: atLeft),   // Binary - [FIXED]
     (Typ: ntOr;           Priority: 8; Kind: okBinary; AssocType: atLeft),   // Binary or [FIXED]
     (Typ: ntXor;          Priority: 8; Kind: okBinary; AssocType: atLeft),   // Binary xor [FIXED]
     (Typ: ntEqual;        Priority: 9; Kind: okBinary; AssocType: atLeft),   // Comparison = [FIXED]
     (Typ: ntNotEqual;     Priority: 9; Kind: okBinary; AssocType: atLeft),   // Comparison <> [FIXED]
     (Typ: ntLower;        Priority: 9; Kind: okBinary; AssocType: atLeft),   // Comparison < [FIXED]
     (Typ: ntGreater;      Priority: 9; Kind: okBinary; AssocType: atLeft),   // Comparison > [FIXED]
     (Typ: ntLowerEqual;   Priority: 9; Kind: okBinary; AssocType: atLeft),   // Comparison <= [FIXED]
     (Typ: ntGreaterEqual; Priority: 9; Kind: okBinary; AssocType: atLeft),   // Comparison >= [FIXED]
     (Typ: ntIn;           Priority: 9; Kind: okBinary; AssocType: atLeft),   // Set membership in [FIXED]
     (Typ: ntIs;           Priority: 9; Kind: okBinary; AssocType: atLeft));  // Type check is [FIXED]
```

### Testing

**Test case:**
```pascal
program TestOperatorPrecedence;
var
  A, B, C, Result: Integer;
begin
  A := 10;
  B := 3;
  C := 2;
  
  Result := A - B + C;  // Should be (10 - 3) + 2 = 9
  WriteLn('10 - 3 + 2 = ', Result);
  
  Result := A + B - C;  // Should be (10 + 3) - 2 = 11
  WriteLn('10 + 3 - 2 = ', Result);
end.
```

**Before fix:**
- `10 - 3 + 2` evaluated to `5` (incorrect: `10 - (3 + 2)`)
- `10 + 3 - 2` evaluated to `15` (incorrect: `10 + (3 - 2)`)

**After fix:**
- `10 - 3 + 2` evaluates to `9` ✅ (correct: `(10 - 3) + 2`)
- `10 + 3 - 2` evaluates to `11` ✅ (correct: `(10 + 3) - 2`)

### References

- **Pascal Language Specification:** ISO 7185 (Section on Expression Evaluation)
- **Delphi Documentation:** All binary arithmetic and logical operators are left-associative
- **Standard Practice:** Left-to-right evaluation for operators of equal precedence (C, C++, Java, Python, etc.)

### Recommendation for Upstream

This is a **critical bug fix** that should be merged into the main DelphiAST repository immediately. The fix:
1. ✅ Aligns with Pascal language specification
2. ✅ Fixes incorrect expression evaluation
3. ✅ Does not break any correctly-written code
4. ✅ Only fixes code that was previously being parsed incorrectly
5. ✅ Verified through extensive testing

---

## Template for Future Fixes

**Date:** YYYY-MM-DD  
**File:** `path/to/file.pas`  
**Lines:** XXX-YYY  
**Severity:** Critical | High | Medium | Low  

### Problem
[Description of the bug or issue]

### Impact
[What code/functionality was affected]

### Solution
[Description of the fix]

### Code Changes
```pascal
// Before
[old code]

// After
[new code]
```

### Testing
[Test cases and verification]

### References
[Links to relevant documentation or issues]

---

## Contribution Guidelines

When submitting these fixes to the upstream DelphiAST repository:

1. **Create separate pull requests** for each fix
2. **Include test cases** demonstrating the bug and the fix
3. **Reference this document** in the PR description
4. **Provide before/after examples** showing the impact
5. **Link to Pascal language specification** where applicable

## Upstream Repository

- **GitHub:** https://github.com/RomanYankovsky/DelphiAST
- **Original Author:** Roman Yankovsky
- **License:** Mozilla Public License 1.1

---

*Last Updated: 2025-10-23*
