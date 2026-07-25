const std = @import("std");
const rl = @import("raylib");
const build_options = @import("build_options");
const Button = @import("Button.zig");

const OnClickCallbackType = *const fn () void;

const Leaderboard = @This();
btn: Button = .{
    .text = "Play Again",
},

const FONT_SIZE = 20;
const TEXT_PADDING = 20;

const BUTTON_DIMS: rl.Vector2 = .{ .x = 150, .y = 100 };
const BUTTON_BOUNDS: rl.Rectangle = .{
    .x = build_options.SCREEN_WIDTH / 2 - (BUTTON_DIMS.x / 2),
    .y = build_options.SCREEN_HEIGHT - 200,
    .width = BUTTON_DIMS.x,
    .height = BUTTON_DIMS.y,
};

pub fn update(self: *Leaderboard, dt: f32) !void {
    _ = dt;
    self.btn.update(BUTTON_BOUNDS);
}

pub fn draw(self: *const Leaderboard, bounds: rl.Rectangle) void {
    _ = bounds;

    //Leaderboard Background
    self.btn.draw(BUTTON_BOUNDS);
}
