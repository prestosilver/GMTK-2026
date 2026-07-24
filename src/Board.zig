const std = @import("std");
const rl = @import("raylib");

const Board = @This();

pub fn update(self: *Board, dt: f64) !void {
    _ = self;
    _ = dt;
}

pub fn draw(self: *const Board, bounds: rl.Rectangle) void {
    _ = self;

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
}
