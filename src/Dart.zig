const Dart = @This();
const rl = @import("raylib");

position: rl.Vector2 = .{ .x = 0, .y = 0 },

pub fn update(self: *Dart, dt: f64) !void {
    _ = self;
    _ = dt;
}

pub fn draw(self: *const Dart) void {
    _ = self;
}
