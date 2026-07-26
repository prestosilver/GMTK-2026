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

darts_order_buffer: [MAX_DARTS]usize = undefined,
darts_buffer: [MAX_DARTS]Dart = undefined,

darts_order: std.ArrayList(usize) = undefined,
darts: std.ArrayList(Dart) = undefined,
sprite: rl.Texture = undefined,
throwing_dart: Dart = .{},
throw_count: u32 = 1,
focus: f32 = 1.0,
score: u32 = 301,
games: u32 = 0,

dart_monkey_per_second: f32 = 0.0,
dart_monkey_counter: f64 = 0.0,
dart_monkey_spread: u32 = 1,
dart_monkey_radius: f32 = 1.0,

pub fn setup(self: *Board) void {
    self.* = .{
        .darts = .initBuffer(&self.darts_buffer),
        .darts_order = .initBuffer(&self.darts_order_buffer),
    };

    self.throwing_dart.throw_timer = Dart.THROW_TIME;
    self.throwing_dart.fall = true;
}

pub fn throwDart(
    self: *Board,
    shop: *Shop,
    bounds: rl.Rectangle,
    start: rl.Vector2,
    peak: rl.Vector2,
    position: rl.Vector2,
) void {
    if (self.darts.items.len >= MAX_DARTS)
        return;

    var points: u32 = 0;
    const center: rl.Vector2 = .{
        .x = bounds.x + bounds.width / 2,
        .y = bounds.y + bounds.height / 2,
    };

    const dart_distance = rl.math.vector2Distance(center, .{
        .x = position.x,
        .y = position.y,
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

    if (dart_distance > (bounds.width / 2 * OUTER_DOUBLE_RING))
        points = 0;

    if (dart_distance >= (bounds.width / 2 * INNER_TRIPLE_RING) and
        dart_distance <= (bounds.width / 2 * OUTER_TRIPLE_RING))
        points *= 3;

    if (dart_distance >= (bounds.width / 2 * INNER_DOUBLE_RING) and
        dart_distance <= (bounds.width / 2 * OUTER_DOUBLE_RING))
        points *= 2;

    const old = self.score;

    if (points == self.score) {
        self.score = 301;
        self.games += 1;
    } else if (self.score > points)
        self.score -= points;

    if (self.score == 1)
        self.score = old;

    shop.money += points;

    self.darts.appendAssumeCapacity(.{
        .toss_start = start,
        .peak = peak,
        .position = position,
    });

    // 1000 darts visible
    if (self.darts.items.len > 100) {
        self.darts.items[self.darts.items.len - 100].fall = true;
        self.darts.items[self.darts.items.len - 100].rot_vel = @as(f32, @floatFromInt(rl.getRandomValue(0, 100))) / 100.0 - 0.5;
    }

    if (points == 0) {
        self.darts.items[self.darts.items.len - 1].throw_timer = Dart.THROW_TIME;
        self.darts.items[self.darts.items.len - 1].fall = true;
    }

    const start_idx = if (self.darts_order.items.len < 2000) 0 else self.darts_order.items.len - 2000;

    if (self.dart_monkey_per_second < 25.0)
        self.darts_order.insertAssumeCapacity(for (self.darts_order.items[start_idx..self.darts_order.items.len], 0..) |dart, index| {
            if (self.darts.items[dart].position.y < self.darts.getLast().position.y)
                break index;
        } else self.darts_order.items.len, self.darts.items.len - 1)
    else
        self.darts_order.appendAssumeCapacity(self.darts.items.len - 1);
}

pub fn update(self: *Board, dt: f64, shop: *Shop, bounds: rl.Rectangle) !void {
    const mouse = rl.getMousePosition();

    if (self.dart_monkey_counter > self.dart_monkey_per_second)
        self.dart_monkey_counter = self.dart_monkey_per_second;

    self.dart_monkey_counter += dt * @min(500.0, self.dart_monkey_per_second);

    while (self.dart_monkey_counter > 1.0) {
        if (self.dart_monkey_per_second < 25.0) {
            const x = @as(f32, @floatFromInt(rl.getRandomValue(0, 100))) / 100.0 * bounds.width * self.dart_monkey_radius + (bounds.height * (1.0 - self.dart_monkey_radius)) / 2;
            const y = @as(f32, @floatFromInt(rl.getRandomValue(0, 100))) / 100.0 * bounds.height * self.dart_monkey_radius + (bounds.height * (1.0 - self.dart_monkey_radius)) / 2;

            for (0..self.dart_monkey_spread) |_| {
                const angle = @as(f32, @floatFromInt(rl.getRandomValue(0, 100))) / 100.0 * std.math.pi * 2;
                const mag = std.math.sqrt(@as(f32, @floatFromInt(rl.getRandomValue(0, 100))) / 100.0) * 50.0;

                self.throwDart(
                    shop,
                    bounds,
                    .{ .x = x, .y = y },
                    rl.math.vector2Lerp(
                        .{ .x = x, .y = y - 30 },
                        .{ .x = x + @sin(angle) * mag, .y = y + @cos(angle) * mag - 30 },
                        0.5,
                    ),
                    //.{ .x = self.throwing_dart.position.x - bounds.x + @sin(std.math.pi) * throwing_radius, .y = self.throwing_dart.position.y - bounds.y + @cos(std.math.pi) * throwing_radius },
                    .{ .x = x + @sin(angle) * mag, .y = y + @cos(angle) * mag },
                );
            }
        } else {
            const x = @as(f32, @floatFromInt(rl.getRandomValue(0, 100))) / 100.0 * bounds.width * self.dart_monkey_radius + (bounds.height * (1.0 - self.dart_monkey_radius)) / 2;
            const y = @as(f32, @floatFromInt(rl.getRandomValue(0, 100))) / 100.0 * bounds.height * self.dart_monkey_radius + (bounds.height * (1.0 - self.dart_monkey_radius)) / 2;

            for (0..self.dart_monkey_spread) |_| {
                self.throwDart(
                    shop,
                    bounds,
                    .{ .x = x, .y = y },
                    rl.math.vector2Lerp(
                        .{ .x = x, .y = y - 30 },
                        .{ .x = x, .y = y - 30 },
                        0.5,
                    ),
                    //.{ .x = self.throwing_dart.position.x - bounds.x + @sin(std.math.pi) * throwing_radius, .y = self.throwing_dart.position.y - bounds.y + @cos(std.math.pi) * throwing_radius },
                    .{ .x = x, .y = y },
                );
            }
        }

        self.dart_monkey_counter -= 1.0 / self.dart_monkey_per_second;
    }

    if (rl.checkCollisionPointRec(mouse, bounds))
        if (rl.isMouseButtonPressed(.left)) {
            const throwing_radius = 100.0 * self.focus;

            for (0..self.throw_count) |_| {
                const angle = @as(f32, @floatFromInt(rl.getRandomValue(0, 100))) / 100.0 * std.math.pi * 2;
                const mag = std.math.sqrt(@as(f32, @floatFromInt(rl.getRandomValue(0, 100))) / 100.0) * throwing_radius;

                self.throwDart(
                    shop,
                    bounds,
                    .{ .x = self.throwing_dart.position.x - bounds.x, .y = self.throwing_dart.position.y - bounds.y },
                    rl.math.vector2Lerp(
                        .{ .x = self.throwing_dart.position.x - bounds.x, .y = self.throwing_dart.position.y - bounds.y - 30 },
                        .{ .x = self.throwing_dart.position.x - bounds.x + @sin(angle) * mag, .y = self.throwing_dart.position.y - bounds.y + @cos(angle) * mag - 30 },
                        0.5,
                    ),
                    //.{ .x = self.throwing_dart.position.x - bounds.x + @sin(std.math.pi) * throwing_radius, .y = self.throwing_dart.position.y - bounds.y + @cos(std.math.pi) * throwing_radius },
                    .{ .x = self.throwing_dart.position.x - bounds.x + @sin(angle) * mag, .y = self.throwing_dart.position.y - bounds.y + @cos(angle) * mag },
                );
            }
        };

    for (self.darts.items) |*dart|
        try dart.update(dt);
}

pub fn draw(self: *const Board, bounds: rl.Rectangle) void {
    self.sprite.drawPro(
        .{ .x = 0, .y = 0, .width = 167, .height = 167 },
        bounds,
        .{ .x = 0.5, .y = 0.5 },
        0.0,
        .white,
    );

    const start = if (self.darts_order.items.len < 2000) 0 else self.darts_order.items.len - 2000;

    for (self.darts_order.items) |dart_idx|
        if (dart_idx >= start)
            self.darts.items[dart_idx].draw(.{
                .x = bounds.x,
                .y = bounds.y,
            });

    self.throwing_dart.draw(.{ .x = 0, .y = 0 });
}
