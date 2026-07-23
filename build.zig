const std = @import("std");
const rlz = @import("raylib_zig");

const GAME_NAME = "gmtk-2026";

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");
    raylib_artifact.root_module.addIncludePath(b.path("src"));

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "raylib", .module = raylib },
        },
    });

    const run_step = b.step("run", "Run the app");

    if (target.query.os_tag == .emscripten) {
        const emsdk = rlz.emsdk;
        const wasm = b.addLibrary(.{
            .name = "index",
            .root_module = exe_mod,
        });

        const install_dir: std.Build.InstallDir = .{ .custom = "web" };
        const emcc_flags = emsdk.emccDefaultFlags(b.allocator, .{ .optimize = optimize });
        const emcc_settings = emsdk.emccDefaultSettings(b.allocator, .{ .optimize = optimize });

        const emcc_step = emsdk.emccStep(b, raylib_artifact, wasm, .{
            .optimize = optimize,
            .flags = emcc_flags,
            .settings = emcc_settings,
            .install_dir = install_dir,
            .shell_file_path = b.path("src/shell.html"),
            .embed_paths = &.{
                // .{
                //     .src_path = "assets/thing.png",
                //     .virtual_path = "thing.png",
                // },
            },
        });
        b.getInstallStep().dependOn(emcc_step);

        const html_filename = try std.fmt.allocPrint(b.allocator, "index.html", .{});
        const emrun_step = emsdk.emrunStep(
            b,
            b.getInstallPath(install_dir, html_filename),
            &.{},
        );

        emrun_step.dependOn(emcc_step);
        run_step.dependOn(emrun_step);
    } else {
        const exe = b.addExecutable(.{
            .name = GAME_NAME,
            .root_module = exe_mod,
        });
        b.installArtifact(exe);

        // Add an image
        // const iconset = b.addInstallFile(b.path("assets/thing.png"), "bin/thing.png");
        // b.getInstallStep().dependOn(&iconset.step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.cwd = b.path("zig-out/bin");

        run_step.dependOn(&run_cmd.step);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
    }

    const exe_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
