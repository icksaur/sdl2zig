const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // The `TranslateC` step is used to translate C header files into Zig code.
    const translate_c = std.Build.Step.TranslateC.create(b, .{
        .link_libc = true,
        .root_source_file = .{ .cwd_relative = "/usr/include/SDL2/SDL.h" },
        .target = target,
        .optimize = optimize,
    });

    const sdl_module = translate_c.createModule(); // create the sdl module

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sdl2", .module = sdl_module }, // import and name the module "sdl2"
        },
    });

    const exe = b.addExecutable(.{
        .name = "sdl2zig",
        .root_module = exe_mod,
    });

    // Link the SDL2 library.
    exe.linkSystemLibrary("SDL2");

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
