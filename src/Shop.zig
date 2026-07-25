const std = @import("std");
const rl = @import("raylib");

const Shop = @This();
money: u64 = 0,

pub fn update(self: *Shop, dt: f64) !void {
    _ = self;
    _ = dt;
}

pub fn draw(self: *const Shop, bounds: rl.Rectangle) void {
    _ = self;
    _ = bounds;
}
