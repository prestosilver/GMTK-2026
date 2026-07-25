const std = @import("std");
const rl = @import("raylib");

const build_options = @import("build_options");

const Dart = @This();

const DART_WIDTH = 36;
const DART_HEIGHT = 72;

pub var dart_sprite: rl.Texture = undefined;
pub var shadow_sprite: rl.Texture = undefined;

position: rl.Vector2 = .{ .x = 0, .y = 0 },
vel: rl.Vector2 = .{ .x = 0, .y = 0 },

fall: bool = false,
rot_vel: f32 = 0.0,
rot: f32 = 0.0,

pub fn update(self: *Dart, dt: f64) !void {
    if (self.fall) {
        self.vel.y += @floatCast(dt * 10);
        self.position.y += self.vel.y;
        self.rot += self.rot_vel * @as(f32, @floatCast(dt)) * 60;
    }
}

pub fn draw(self: *const Dart, offset: rl.Vector2) void {
    if (self.position.y + offset.y < build_options.SCREEN_HEIGHT) {
        if (!self.fall)
            shadow_sprite.drawPro(.{ .x = 0, .y = 0, .width = 9, .height = 9 }, .{
                .x = offset.x + self.position.x - DART_WIDTH * 0.5,
                .y = offset.y + self.position.y - DART_WIDTH * 0.5,
                .width = DART_WIDTH,
                .height = DART_WIDTH,
            }, .{ .x = 0, .y = 0 }, 0.0, .white);

        dart_sprite.drawPro(.{ .x = 0, .y = 0, .width = 9, .height = 18 }, .{
            .x = offset.x + self.position.x - DART_WIDTH * 0.5,
            .y = offset.y + self.position.y,
            .width = DART_WIDTH,
            .height = DART_HEIGHT,
        }, .{ .x = 0.5, .y = 0 }, self.rot, .white);
    }

    //rl.drawRectangleRec(.{
    //    .x = self.position.x - DART_WIDTH * 0.5,
    //    .y = self.position.y,
    //    .width = DART_WIDTH,
    //    .height = DART_HEIGHT,
    //}, .blue);
}
