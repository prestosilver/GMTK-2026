const std = @import("std");
const rl = @import("raylib");

const Dart = @import("Dart.zig");
const Shop = @import("Shop.zig");

const Board = @This();

const MAX_DARTS = 1_000_000;

const BOARD_VALUES = [20]u32{ 20, 1, 18, 4, 13, 6, 10, 15, 2, 13, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5 };

darts_buffer: [MAX_DARTS]Dart = undefined,
darts: std.ArrayList(Dart) = undefined,

pub fn setup(self: *Board) void {
    self.darts = .initBuffer(&self.darts_buffer);
}

pub fn throwDart(self: *Board, shop: *Shop, bounds: rl.Rectangle, position: rl.Vector2) void {
    if (self.darts.items.len >= MAX_DARTS)
        return;

    if (rl.math.vector2DistanceSqr(.{
        .x = bounds.x + bounds.width / 2,
        .y = bounds.y + bounds.height / 2,
    }, .{
        .x = position.x - bounds.x,
        .y = position.y - bounds.y,
    }) < (bounds.width / 2 * 0.028 * 0.5) * (bounds.width / 2 * 0.028 * 0.5))
        std.log.info("Yo bro thats a double bullseye", .{});

    _ = shop;

    self.darts.appendAssumeCapacity(.{
        .position = position,
    });
}

pub fn update(self: *Board, dt: f64, shop: *Shop, bounds: rl.Rectangle) !void {
    if (rl.isMouseButtonPressed(.left))
        self.throwDart(shop, bounds, rl.getMousePosition());

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
