const std = @import("std");
const rl = @import("raylib");

const Dart = @import("Dart.zig");
const Shop = @import("Shop.zig");

const Board = @This();

const MAX_DARTS = 1_000_000;

const BOARD_VALUES = [20]u32{ 20, 1, 18, 4, 13, 6, 10, 15, 2, 13, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5 };

const BULL_RADIUS = 0.071;
const DOUBLE_BULL_RADIUS = 0.028;

const INNER_DOUBLE_RING = 0.72;
const OUTER_DOUBLE_RING = 0.75;

const INNER_TRIPLE_RING = 0.44;
const OUTER_TRIPLE_RING = 0.47;

darts_buffer: [MAX_DARTS]Dart = undefined,
darts: std.ArrayList(Dart) = undefined,

pub fn setup(self: *Board) void {
    self.darts = .initBuffer(&self.darts_buffer);
}

pub fn throwDart(self: *Board, shop: *Shop, bounds: rl.Rectangle, position: rl.Vector2) void {
    if (self.darts.items.len >= MAX_DARTS)
        return;

    var points: u32 = 10;

    const center: rl.Vector2 = .{
        .x = bounds.x + bounds.width / 2,
        .y = bounds.y + bounds.height / 2,
    };

    const dart_distance = rl.math.vector2Distance(center, .{
        .x = position.x - bounds.x,
        .y = position.y - bounds.y,
    });

    const twenty_angle = -0.5 / 20.0 * std.math.pi * 2.0;

    const dart_angle = rl.math.vector2Angle(.{
        .x = @sin(twenty_angle) * bounds.width * 0.5,
        .y = @cos(twenty_angle) * bounds.height * 0.5,
    }, .{
        .x = center.x - position.x,
        .y = center.y - position.y,
    });

    const dart_sector: u32 = @mod(@as(u32, @intFromFloat(dart_angle / std.math.pi / 2.0 * 20 + 21)), 20);

    points = BOARD_VALUES[dart_sector];

    if (dart_distance < (bounds.width / 2 * BULL_RADIUS))
        points = 25;

    if (dart_distance < (bounds.width / 2 * DOUBLE_BULL_RADIUS))
        points = 50;

    if (dart_distance >= (bounds.width / 2 * INNER_TRIPLE_RING) and
        dart_distance <= (bounds.width / 2 * OUTER_TRIPLE_RING))
        points *= 3;

    if (dart_distance >= (bounds.width / 2 * INNER_DOUBLE_RING) and
        dart_distance <= (bounds.width / 2 * OUTER_DOUBLE_RING))
        points *= 2;

    std.log.debug("Scord {} points", .{points});

    shop.money += points;

    self.darts.appendAssumeCapacity(.{
        .position = position,
    });
}

pub fn update(self: *Board, dt: f64, shop: *Shop, bounds: rl.Rectangle) !void {
    const mouse = rl.getMousePosition();

    if (rl.checkCollisionPointRec(mouse, bounds))
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
            const angle = (@as(f32, @floatFromInt(div)) - 0.5) / 20.0 * std.math.pi * 2.0;
            rl.drawLineV(center, .{
                .x = bounds.width * 0.5 + @sin(angle) * bounds.width * 0.5,
                .y = bounds.height * 0.5 - @cos(angle) * bounds.height * 0.5,
            }, .black);
        }

        rl.drawCircleLinesV(center, bounds.width * 0.5 * INNER_DOUBLE_RING, .black);
        rl.drawCircleLinesV(center, bounds.width * 0.5 * OUTER_DOUBLE_RING, .black);

        rl.drawCircleLinesV(center, bounds.width * 0.5 * INNER_TRIPLE_RING, .black);
        rl.drawCircleLinesV(center, bounds.width * 0.5 * OUTER_TRIPLE_RING, .black);

        rl.drawCircleLinesV(center, bounds.width * 0.5 * BULL_RADIUS, .black);
        rl.drawCircleLinesV(center, bounds.width * 0.5 * DOUBLE_BULL_RADIUS, .black);
    }

    for (self.darts.items) |dart|
        dart.draw();
}
