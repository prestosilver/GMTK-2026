const std = @import("std");
const rl = @import("raylib");

const Dart = @This();

const DART_WIDTH = 30;
const DART_HEIGHT = 80;

position: rl.Vector2 = .{ .x = 0, .y = 0 },

pub fn update(self: *Dart, dt: f64) !void {
    _ = self;
    _ = dt;
}

pub fn draw(self: *const Dart) void {
    rl.drawRectangleRec(.{
        .x = self.position.x - DART_WIDTH * 0.5,
        .y = self.position.y,
        .width = DART_WIDTH,
        .height = DART_HEIGHT,
    }, .blue);
}
