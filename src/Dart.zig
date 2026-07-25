const std = @import("std");
const rl = @import("raylib");

const Dart = @This();

const DART_WIDTH = 36;
const DART_HEIGHT = 72;

pub var dart_sprite: rl.Texture = undefined;

position: rl.Vector2 = .{ .x = 0, .y = 0 },

pub fn update(self: *Dart, dt: f64) !void {
    _ = self;
    _ = dt;
}

pub fn draw(self: *const Dart, offset: rl.Vector2) void {
    dart_sprite.drawPro(.{ .x = 0, .y = 0, .width = 9, .height = 18 }, .{
        .x = offset.x + self.position.x - DART_WIDTH * 0.5,
        .y = offset.y + self.position.y,
        .width = DART_WIDTH,
        .height = DART_HEIGHT,
    }, .{ .x = 0, .y = 0 }, 0, .white);

    //rl.drawRectangleRec(.{
    //    .x = self.position.x - DART_WIDTH * 0.5,
    //    .y = self.position.y,
    //    .width = DART_WIDTH,
    //    .height = DART_HEIGHT,
    //}, .blue);
}
