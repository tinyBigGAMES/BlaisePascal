const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = .ReleaseSmall;

    // Create module for C++ sources
    const module = b.addModule("core_basic_window", .{
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
        .file = b.path("../../../res/runtime/runtime.cpp"),
        .flags = &cpp_flags,
    });

    // Add registered C++ source files
    module.addCSourceFile(.{
        .file = b.path("generated/core_basic_window.cpp"),
        .flags = &cpp_flags,
    });
    module.addCSourceFile(.{
        .file = b.path("generated/raylib.cpp"),
        .flags = &cpp_flags,
    });

    module.addIncludePath(b.path("../../../res/runtime"));
    module.addIncludePath(b.path("../../../res/libs/raylib/inc"));

    // Create executable
    const exe = b.addExecutable(.{
        .name = "core_basic_window",
        .root_module = module,
    });

    // Link C++ standard library
    exe.linkLibCpp();

    exe.addLibraryPath(b.path("../../../res/libs/raylib/lib"));

    exe.addObjectFile(b.path("../../../res/libs/raylib/lib/libraylib.a"));
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("winmm");
    exe.linkSystemLibrary("gdi32");

    b.installArtifact(exe);
}
