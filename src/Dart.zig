const std = @import("std");
const rl = @import("raylib");

const build_options = @import("build_options");

const Dart = @This();

const DART_WIDTH = 36;
const DART_HEIGHT = 72;

pub const THROW_TIME = 0.25;

pub var dart_sprite: rl.Texture = undefined;
pub var shadow_sprite: rl.Texture = undefined;

toss_start: rl.Vector2 = .{ .x = 0, .y = 0 },
peak: rl.Vector2 = .{ .x = 0, .y = 0 },
position: rl.Vector2 = .{ .x = 0, .y = 0 },
vel: rl.Vector2 = .{ .x = 0, .y = 0 },

fall: bool = false,
rot_vel: f32 = 0.0,
rot: f32 = 0.0,
throw_timer: f32 = 0.0,

pub fn update(self: *Dart, dt: f64) !void {
    if (self.position.y < build_options.SCREEN_HEIGHT) {
        if (self.throw_timer < THROW_TIME) {
            self.throw_timer += @floatCast(dt);
            self.throw_timer = @min(self.throw_timer, THROW_TIME);
        } else if (self.fall) {
            self.vel.y += @floatCast(dt * 20);
            self.position.y += self.vel.y;
            self.rot += self.rot_vel * @as(f32, @floatCast(dt)) * 60;
        }
    }
}

pub fn draw(self: *const Dart, offset: rl.Vector2) void {
    var position = self.position;

    if (self.throw_timer < THROW_TIME) {
        if (self.throw_timer < THROW_TIME * 0.5) {
            const dist = self.throw_timer / (THROW_TIME * 0.5);
            position = rl.math.vector2Lerp(self.toss_start, self.peak, dist);
        } else {
            const dist = (self.throw_timer - THROW_TIME * 0.5) / (THROW_TIME * 0.5);
            position = rl.math.vector2Lerp(self.peak, self.position, dist);
        }
    }

    if (position.y + offset.y < build_options.SCREEN_HEIGHT) {
        if (!self.fall)
            shadow_sprite.drawPro(.{ .x = 0, .y = 0, .width = 9, .height = 9 }, .{
                .x = offset.x + position.x - DART_WIDTH * 0.5,
                .y = offset.y + self.position.y - DART_WIDTH * 0.5,
                .width = DART_WIDTH,
                .height = DART_WIDTH,
            }, .{ .x = 0, .y = 0 }, 0.0, .fade(.white, @min(1.0, self.throw_timer / THROW_TIME)));

        dart_sprite.drawPro(.{ .x = 0, .y = 0, .width = 9, .height = 18 }, .{
            .x = offset.x + position.x - DART_WIDTH * 0.5,
            .y = offset.y + position.y,
            .width = DART_WIDTH,
            .height = DART_HEIGHT,
        }, .{ .x = 0.5, .y = 0 }, self.rot, .fade(.white, @min(1.0, self.throw_timer / THROW_TIME)));
    }
}
