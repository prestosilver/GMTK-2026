const std = @import("std");
const rl = @import("raylib");
const Button = @import("Button.zig");

const OnClickCallbackType = *const fn () void;

const Leaderboard = @This();
btn: Button = .{
    .text = "Play Again",
},

const FONT_SIZE = 20;
const TEXT_PADDING = 20;


const BUTTON_BOUNDS : rl.Rectangle = .{.x=};

pub fn update(self: *Leaderboard, bounds: rl.Rectangle) !void {
    self.btn.update();
}

pub fn draw(self: *const Leaderboard, bounds: rl.Rectangle) void {
    //Leaderboard Background
    self.btn.draw(.{
        .x = bounds.width / 2,
        .y = 800,
        .width = bounds.width / 2,
        .height = 300,
    });
}
