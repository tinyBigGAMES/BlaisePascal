const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = .ReleaseFast;

    // Create module for C++ sources
    const module = b.addModule("BPBench", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // C++ compiler flags
    const cpp_flags = [_][]const u8{
        "-std=c++23",
    };

    // Add runtime source
    module.addCSourceFile(.{
        .file = b.path("../../res/runtime/runtime.cpp"),
        .flags = &cpp_flags,
    });

    // Add registered C++ source files
    module.addCSourceFile(.{
        .file = b.path("generated/BPBench.cpp"),
        .flags = &cpp_flags,
    });
    module.addCSourceFile(.{
        .file = b.path("generated/UBPBench.cpp"),
        .flags = &cpp_flags,
    });

    module.addIncludePath(b.path("../../res/runtime"));
    module.addIncludePath(b.path("../../res/libs/raylib/inc"));

    // Create executable
    const exe = b.addExecutable(.{
        .name = "BPBench",
        .root_module = module,
    });

    // Link C++ standard library
    exe.linkLibCpp();

    b.installArtifact(exe);
}
