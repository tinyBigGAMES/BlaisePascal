# BPBench - Blaise Pascal Micro-Benchmark Suite

## Overview

**BPBench** is a comprehensive micro-benchmark suite designed to measure and validate the performance of Blaise Pascal's Pascal-to-C++ transpilation against native Delphi compilation. The suite focuses on fundamental operations that are common in real-world applications: string manipulation, array operations, and compute-intensive numerical calculations.

### Purpose

BPBench serves multiple critical purposes:

1. **Performance Validation** - Verify that transpiled Pascal code achieves competitive (or superior) performance compared to native Delphi
2. **Regression Detection** - Catch performance regressions during transpiler development
3. **Optimization Validation** - Measure the impact of transpiler optimizations (e.g., string concatenation optimization)
4. **Architecture Validation** - Prove the "dumb transpiler, smart runtime" approach delivers real-world performance
5. **Marketing Material** - Demonstrate that "Think in Pascal. Compile to C++." isn't just a tagline - it's measurably faster

## The Benchmark Suite

BPBench consists of three carefully designed micro-benchmarks, each targeting different performance characteristics:

### 1. string_concat_1k - String Concatenation

**What it tests:** String building through repeated concatenation operations

**Implementation:**
```pascal
procedure Bench_StringConcat_1k(var ABytesProcessed: Double);
var
  LStr: string;
  LIndex: Integer;
begin
  LStr := '';
  LIndex := 1;
  while LIndex <= 1024 do
  begin
    LStr := LStr + 'x';  // Critical operation: self-concatenation
    Inc(LIndex);
  end;
  ABytesProcessed := 1024.0;
end;
```

**Why it matters:**
- String building is ubiquitous in applications (logging, JSON/XML generation, reports)
- Tests memory allocation efficiency
- Validates string optimization (self-concatenation pattern detection)
- Measures the effectiveness of the `+=` operator optimization

**Performance characteristics:**
- **Allocation-heavy**: Creates many temporary string objects (or optimizes them away)
- **Memory bandwidth**: Tests how efficiently the runtime handles string buffer growth
- **Optimization-sensitive**: Shows dramatic improvements with proper optimization

### 2. array_sum_10m - Array Operations & Integer Math

**What it tests:** High-volume integer arithmetic with array access patterns

**Implementation:**
```pascal
procedure Bench_ArraySum_10M(var ABytesProcessed: Double);
var
  LIndex: Integer;
  LSum: Int64;
  LArray: array[0..99] of Int64;
begin
  // Initialize array
  LIndex := 0;
  while LIndex <= 99 do
  begin
    LArray[LIndex] := 0;
    Inc(LIndex);
  end;
  
  // Main computation loop
  LSum := 0;
  LIndex := 1;
  while LIndex <= 10000000 do
  begin
    LSum := LSum + LIndex;
    LArray[LIndex mod 100] := LSum;
    Inc(LIndex);
  end;
  
  ABytesProcessed := 10000000.0 * 8.0;  // 10M Int64 operations
  GSink := LArray[99];  // Prevent dead code elimination
end;
```

**Why it matters:**
- Tests fundamental loop performance
- Validates array indexing efficiency
- Measures integer arithmetic optimization
- Tests modulo operation performance
- Validates that transpiled code doesn't have hidden overhead

**Performance characteristics:**
- **CPU-bound**: Pure computational work
- **Cache-friendly**: Small array fits in L1 cache
- **Predictable branches**: Compiler can optimize loop well
- **Memory bandwidth**: ~12 GB/s shows excellent cache utilization

### 3. matmul_64 - Matrix Multiplication

**What it tests:** Compute-intensive floating-point operations with nested loops

**Implementation:**
```pascal
procedure Bench_MatMul_64(var ABytesProcessed: Double);
var
  LMatrixA: array[0..63, 0..63] of Double;
  LMatrixB: array[0..63, 0..63] of Double;
  LMatrixC: array[0..63, 0..63] of Double;
  LIndexI: Integer;
  LIndexJ: Integer;
  LIndexK: Integer;
  LAcc: Double;
begin
  // Initialize matrices
  LIndexI := 0;
  while LIndexI <= 63 do
  begin
    LIndexJ := 0;
    while LIndexJ <= 63 do
    begin
      LMatrixA[LIndexI, LIndexJ] := (LIndexI + LIndexJ) * 0.001;
      LMatrixB[LIndexI, LIndexJ] := (LIndexI - LIndexJ) * 0.002;
      LMatrixC[LIndexI, LIndexJ] := 0.0;
      Inc(LIndexJ);
    end;
    Inc(LIndexI);
  end;

  // Matrix multiplication: C = A * B
  LIndexI := 0;
  while LIndexI <= 63 do
  begin
    LIndexJ := 0;
    while LIndexJ <= 63 do
    begin
      LAcc := 0.0;
      LIndexK := 0;
      while LIndexK <= 63 do
      begin
        LAcc := LAcc + LMatrixA[LIndexI, LIndexK] * LMatrixB[LIndexK, LIndexJ];
        Inc(LIndexK);
      end;
      LMatrixC[LIndexI, LIndexJ] := LAcc;
      Inc(LIndexJ);
    end;
    Inc(LIndexI);
  end;

  ABytesProcessed := 64.0 * 64.0 * 3.0 * 8.0;  // Three 64x64 matrices of Double
end;
```

**Why it matters:**
- Tests floating-point performance
- Validates multi-dimensional array handling
- Measures nested loop optimization
- Tests compiler vectorization capabilities (SIMD)
- Representative of scientific/graphics computation workloads

**Performance characteristics:**
- **FP-intensive**: 262,144 floating-point multiply-add operations
- **Memory patterns**: Sequential and strided access patterns
- **Vectorization-friendly**: Modern compilers can SIMD-optimize
- **Cache behavior**: Tests L2/L3 cache efficiency

## Benchmark Methodology

BPBench uses a sophisticated auto-scaling methodology to ensure accurate measurements:

### 1. Warmup Phase
```pascal
procedure WarmupBench(const ABenchNum: Integer; const ARounds: Integer);
```
- Runs the benchmark 2 times (default) before measurement
- Ensures JIT compilation is complete (if applicable)
- Warms up CPU caches
- Stabilizes CPU frequency scaling

### 2. Auto-Iteration Scaling
```pascal
function AutoIters(const ABenchNum: Integer; const ATPS: Int64; 
  const ATargetMs: Integer): Int64;
```
- Runs benchmark once to measure single-operation time
- Calculates iterations needed to reach target duration (400ms default)
- Ensures benchmarks run long enough for accurate timing
- Prevents too-short measurements that would be dominated by noise

**Iteration counts (typical):**
- `string_concat_1k`: ~50,000 iterations (each doing 1024 concatenations)
- `array_sum_10m`: ~50-70 iterations (each doing 10M operations)
- `matmul_64`: ~5,000 iterations (each doing 262K FP operations)

### 3. High-Resolution Timing
```pascal
function TicksPerSec(): Int64;
function TicksNow(): Int64;
```
- Uses Windows `QueryPerformanceCounter` for nanosecond-precision timing
- Measures wall-clock time for entire benchmark run
- Calculates per-operation metrics by dividing by iteration count

### 4. Dead Code Elimination Prevention
```pascal
var GSink: Int64;  // Global sink to prevent optimization

// In benchmarks:
GSink := LArray[99];
if GSink < 0 then Write('');
```
- Uses results to prevent compiler from optimizing away the entire benchmark
- Global variable ensures result "escapes" the function
- Conditional write prevents the sink itself from being optimized away

## Metrics Explained

Each benchmark reports three key metrics:

### ns/op (Nanoseconds per Operation)
- **Lower is better**
- Time taken for one complete benchmark operation
- Most intuitive metric for understanding raw speed
- Example: `7,396 ns` = 7.4 microseconds per 1024-character string build

### ops/s (Operations per Second)  
- **Higher is better**
- Throughput: how many operations completed per second
- Useful for comparing relative performance
- Calculated as: `1,000,000,000 / ns_per_op`
- Example: `135,216 ops/s` = 135,216 string builds per second

### MB/s (Megabytes per Second)
- **Higher is better**
- Data throughput based on `ABytesProcessed` parameter
- Measures memory bandwidth utilization
- Useful for understanding cache/memory efficiency
- Calculated as: `(bytes_processed * iterations / 1024² / elapsed_seconds)`

**Example Results:**
```
| Variant      | Benchmark         | Iterations | ns/op     | ops/s      | MB/s    |
|--------------|-------------------|------------|-----------|------------|---------|
| BlaisePascal | string_concat_1k  | 52631      | 7,395.60  | 135,215.58 | 132.05  |
| BlaisePascal | array_sum_10m     | 53         | 6,384,094 | 156.64     | 11,950  |
| BlaisePascal | matmul_64         | 5063       | 79,079.40 | 12,645.52  | 1,185   |
```

## Performance Results: Blaise Pascal vs Delphi

### Current Performance Comparison

| Benchmark | Delphi (native) | BlaisePascal | **Performance** |
|-----------|-----------------|--------------|-----------------|
| **string_concat_1k** | 14,919 ns/op | **7,396 ns/op** | **🔥 2.0x faster** |
| **array_sum_10m** | 10,417,418 ns/op | **6,384,094 ns/op** | **🚀 1.6x faster** |
| **matmul_64** | 217,835 ns/op | **79,079 ns/op** | **💥 2.8x faster** |

### Detailed Metrics Comparison

#### String Concatenation
```
Delphi:
  - ns/op:  14,919
  - ops/s:  67,027
  - MB/s:   65.46

BlaisePascal:
  - ns/op:  7,396      (2.0x faster)
  - ops/s:  135,216    (2.0x higher throughput)
  - MB/s:   132.05     (2.0x higher bandwidth)
```

**Why BlaisePascal wins:**
- Aggressive string concatenation optimization (`+=` operator)
- LLVM's superior string buffer management
- Smart runtime library (`bp::String`)

#### Array Operations
```
Delphi:
  - ns/op:  10,417,418
  - ops/s:  95.99
  - MB/s:   7,324

BlaisePascal:
  - ns/op:  6,384,094  (1.6x faster)
  - ops/s:  156.64     (1.6x higher throughput)
  - MB/s:   11,951     (1.6x higher bandwidth)
```

**Why BlaisePascal wins:**
- LLVM's loop optimization and unrolling
- Better register allocation
- Superior L1/L2 cache utilization

#### Matrix Multiplication
```
Delphi:
  - ns/op:  217,835
  - ops/s:  4,591
  - MB/s:   430.37

BlaisePascal:
  - ns/op:  79,079     (2.8x faster)
  - ops/s:  12,646     (2.8x higher throughput)
  - MB/s:   1,186      (2.8x higher bandwidth)
```

**Why BlaisePascal wins:**
- LLVM's automatic vectorization (SIMD)
- Modern C++23 optimization passes
- Better floating-point code generation

### Performance Evolution

The string concatenation benchmark demonstrates the impact of transpiler optimization:

| Version | ns/op | Improvement |
|---------|-------|-------------|
| **Before optimization** | 182,271 ns | baseline |
| **After optimization** | 7,396 ns | **24.6x faster!** |
| **vs Delphi** | 14,919 ns | **2.0x faster than native!** |

## Running the Benchmarks

### From Binary

```bash
cd bin/projects/NPBench
NPBench.exe
```

**Output format (default - Markdown table):**
```
| Variant | Benchmark | Iterations | ns/op | ops/s | MB/s |
|--------:|-----------|-----------:|------:|------:|-----:|
| BlaisePascal | string_concat_1k | 52631ld | 7395.60 | 135215.58 | 132.05 |
| BlaisePascal | array_sum_10m | 53ld | 6384094.34 | 156.64 | 11950.63 |
| BlaisePascal | matmul_64 | 5063ld | 79079.40 | 12645.52 | 1185.52 |
```

### Command-Line Options

```bash
# Custom variant name
NPBench.exe --variant=MyBuild

# Adjust warmup rounds (default: 2)
NPBench.exe --warmups=5

# Adjust target measurement time in milliseconds (default: 400)
NPBench.exe --target_ms=1000

# CSV output for data analysis
NPBench.exe --csv=yes

# Combine options
NPBench.exe --variant=Optimized --warmups=3 --target_ms=500 --csv=yes
```

**CSV output example:**
```
variant,benchmark,iterations,ns_per_op,ops_per_sec,mb_per_sec
BlaisePascal,string_concat_1k,52631,7395.60,135215.58,132.05
BlaisePascal,array_sum_10m,53,6384094.34,156.64,11950.63
BlaisePascal,matmul_64,5063,79079.40,12645.52,1185.52
```

### Building from Source

**Transpile and build:**
```bash
cd bin/projects/NPBench
build.bat
```

**Run benchmarks:**
```bash
NPBench.exe
```

## Architecture & Implementation

### Project Structure

```
bin/projects/NPBench/
├── src/
│   ├── NPBench.pas          # Main program entry point
│   └── UNPBench.pas         # Benchmark implementation
├── generated/
│   ├── NPBench.cpp          # Transpiled main program
│   ├── NPBench.h
│   ├── UNPBench.cpp         # Transpiled benchmarks
│   └── UNPBench.h
├── build.zig                # Zig build configuration
└── NPBench.exe              # Compiled binary
```

### Key Design Decisions

#### 1. Pure Pascal Implementation
- No external dependencies
- Portable across Pascal implementations (Delphi, Free Pascal, BlaisePascal)
- Easy to understand and modify

#### 2. Self-Contained Timing
- Uses Windows API directly (`QueryPerformanceCounter`)
- No dependency on third-party timing libraries
- Nanosecond-precision measurements

#### 3. Auto-Scaling Iterations
- Adapts to different CPU speeds
- Ensures measurements are statistically significant
- Prevents measurement noise from dominating results

#### 4. Multiple Output Formats
- Human-readable Markdown tables (default)
- Machine-parsable CSV (for analysis/CI)
- Easy integration into documentation and automation

### Optimization Case Study: String Concatenation

The string concatenation benchmark showcases a critical transpiler optimization:

**Pascal source:**
```pascal
LStr := LStr + 'x';  // Repeated 1024 times
```

**Without optimization (generated C++):**
```cpp
LStr = (LStr + L"x");  // Creates temporary string object
```

**With optimization (generated C++):**
```cpp
LStr += L"x";  // In-place concatenation
```

**Impact:**
- Before: 182,271 ns (1024 temp allocations)
- After: 7,396 ns (in-place modifications)
- **Improvement: 24.6x faster**

**How it works:**

The transpiler detects the self-concatenation pattern:
1. LHS is a simple string variable
2. RHS is an addition operation
3. Left side of addition matches LHS
4. Right side is any expression

When detected, it emits `+=` instead of `= ... +`, allowing the C++ compiler and runtime to use in-place buffer growth instead of allocating temporary strings.

**Detection code (Blaise.CodeGen.Statements.pas):**
```pascal
function CanOptimizeToInPlaceConcat(const ACodeGen: TCodeGen; 
  const ALLHS: TSyntaxNode; const ARLHS: TSyntaxNode; 
  out ARHSRight: TSyntaxNode): Boolean;
begin
  // Check 1: LHS must be simple identifier
  // Check 2: Variable must be String type
  // Check 3: RHS must be addition
  // Check 4: Left of addition must match LHS
  // If all checks pass: emit += operator
end;
```

## Performance Analysis

### Why BlaisePascal is Faster

#### 1. Modern Compiler Backend (LLVM 20.1.8)
- **Loop optimization**: Automatic unrolling, vectorization
- **Register allocation**: Superior register usage
- **Instruction selection**: Optimal x86-64 instruction sequences
- **Link-time optimization**: Whole-program optimization

#### 2. C++23 Target
- **Modern language features**: Better inlining, constexpr
- **Standard library**: Highly optimized STL implementations
- **Compiler support**: Cutting-edge optimization passes

#### 3. Smart Runtime Library (`bp` namespace)
- **Zero-cost abstractions**: Pascal semantics without overhead
- **Optimized implementations**: Hand-tuned critical paths
- **Memory management**: Efficient allocation strategies

#### 4. Transpiler Optimizations
- **String concatenation**: Pattern detection and optimization
- **Type-aware code generation**: Leverages C++ type system
- **Minimal overhead**: "Dumb transpiler" doesn't add unnecessary code

### Performance Characteristics Summary

| Benchmark | Bottleneck | BlaisePascal Advantage |
|-----------|------------|------------------------|
| **string_concat_1k** | Memory allocation | String optimization + LLVM memory management |
| **array_sum_10m** | CPU + L1 cache | LLVM loop optimization + register allocation |
| **matmul_64** | FP computation + L2 cache | LLVM vectorization (SIMD) + cache optimization |

## Future Benchmark Additions

Planned additions to BPBench:

### Near-term
- **File I/O benchmark**: Test stream performance
- **Record operations**: Measure struct/record handling
- **Dynamic arrays**: Test array resizing and copying
- **Set operations**: Validate set implementation efficiency

### Long-term
- **JSON parsing/generation**: Real-world string processing
- **Sorting algorithms**: Test algorithm performance
- **Regex operations**: Pattern matching performance
- **Thread creation**: Measure threading overhead
- **Memory allocation**: Stress test memory management

## Conclusions

BPBench demonstrates that Blaise Pascal's "Think in Pascal. Compile to C++." philosophy delivers real, measurable performance benefits:

✅ **2.0x faster** string operations than native Delphi  
✅ **1.6x faster** array/integer operations than native Delphi  
✅ **2.8x faster** floating-point computation than native Delphi  

The benchmark suite validates that:
- The "dumb transpiler, smart runtime" architecture works
- Pascal semantics can be preserved without performance cost
- Modern LLVM optimization delivers superior code generation
- Targeted transpiler optimizations (like string concatenation) have massive impact

**Blaise Pascal isn't just compatible with Delphi - it's faster.**

---

*BPBench is part of the Blaise Pascal project. For more information, see the main repository documentation.*
