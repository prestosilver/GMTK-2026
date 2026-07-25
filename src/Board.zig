const std = @import("std");
const rl = @import("raylib");

const Dart = @import("Dart.zig");

const Board = @This();

const MAX_DARTS = 1_000_000;

darts_buffer: [MAX_DARTS]Dart = undefined,
darts: std.ArrayList(Dart) = undefined,

pub fn setup(self: *Board) void {
    self.darts = .initBuffer(&self.darts_buffer);
}

pub fn throwDart(self: *Board, position: rl.Vector2) void {
    self.darts.appendAssumeCapacity(.{
        .position = position,
    });
}

pub fn update(self: *Board, dt: f64) !void {
    if (rl.isMouseButtonPressed(.left))
        self.throwDart(rl.getMousePosition());

    for (self.darts.items) |*dart|
        try dart.update(dt);
}

pub fn draw(self: *const Board, bounds: rl.Rectangle) void {
    {
        // TODO: replace with a real sprite
        const center: rl.Vector2 = .{
            .x = bounds.x + bounds.width * 0.5,
            .y = bounds.y + bounds.width * 0.5,
        };

        rl.drawCircleV(center, bounds.width * 0.5, .black);
        rl.drawCircleV(center, bounds.width * 0.5 * 0.75, .dark_green);
        rl.drawCircleV(center, bounds.width * 0.5 * 0.028, .red);

        for (0..20) |div| {
            const angle = (@as(f32, @floatFromInt(div)) + 0.5) / 20.0 * std.math.pi * 2.0;
            rl.drawLineV(center, .{
                .x = bounds.width * 0.5 + @sin(angle) * bounds.width * 0.5,
                .y = bounds.width * 0.5 + @cos(angle) * bounds.width * 0.5,
            }, .black);
        }

        rl.drawCircleLinesV(center, bounds.width * 0.5 * 0.75, .black);
        rl.drawCircleLinesV(center, bounds.width * 0.5 * 0.47, .black);

        rl.drawCircleLinesV(center, bounds.width * 0.5 * 0.44, .black);
        rl.drawCircleLinesV(center, bounds.width * 0.5 * 0.72, .black);

        rl.drawCircleLinesV(center, bounds.width * 0.5 * 0.071, .black);
        rl.drawCircleLinesV(center, bounds.width * 0.5 * 0.028, .black);
    }

    for (self.darts.items) |dart|
        dart.draw();
}
