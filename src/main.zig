// TODO: Make sure this compiles with zig 0.16

const std = @import("std");
const rl = @import("raylib");
const build_options = @import("build_options");

const SCREEN_WIDTH = 1200;
const SCREEN_HEIGHT = 675;

var state: enum { game } = .game;

pub fn sendHighscore(name: [3]u8, score: u32) void {
    switch (@import("builtin").cpu.arch) {
        .wasm32 => {
            // We shouldnt be calling this much
            // keeping the import in local scope to reflect that
            const emasm = @import("emasm.zig");
            emasm.EM_ASM((
                \\sendHighscore(UTF8ToString($0), $1);
            ), .{ &name, score });
        },
        else => |platform| std.log.info("unimplemented: sendHighscore on {s}", .{@tagName(platform)}),
    }
}

pub fn main() !void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, build_options.GAME_NAME);
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.setExitKey(.null);

    // Load a texture
    // const thing_image = try rl.loadTexture("thing.png");
    // defer thing_image.unload();

    sendHighscore("JEF".*, 32);

    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();
        _ = dt;

        // update state
        switch (state) {
            .game => {},
        }

        // draw frame
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        switch (state) {
            .game => {},
        }
    }
}
