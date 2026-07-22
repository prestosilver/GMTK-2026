// TODO: Make sure this compiles with zig 0.16

const std = @import("std");
const rl = @import("raylib");

const SCREEN_WIDTH = 1200;
const SCREEN_HEIGHT = 675;
const GAME_TITLE = "GMTK 2026";

var state: enum { game } = .game;

pub fn main() !void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, GAME_TITLE);
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.setExitKey(.null);

    // Load a texture
    // const thing_image = try rl.loadTexture("thing.png");
    // defer thing_image.unload();

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

        switch (state) {
            .game => {},
        }
    }
}