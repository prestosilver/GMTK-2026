const std = @import("std");
const rl = @import("raylib");
const build_options = @import("build_options");
const Button = @import("Button.zig");

const OnClickCallbackType = *const fn () void;

const Leaderboard = @This();
btn: Button = .{
    .text = "Submit Score",
},
score: u32 = 0,
active_idx: u32 = 0,
name: *const [3:0]u8 = "AAA",
cursor_texture: rl.Texture = undefined,

const FONT_SIZE = 20;
const TEXT_PADDING = 20;
const VALID_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?";
var is_pressed: bool = false;

const BUTTON_DIMS: rl.Vector2 = .{ .x = 175, .y = 60 };
const BUTTON_BOUNDS: rl.Rectangle = .{
    .x = build_options.SCREEN_WIDTH / 2 - (BUTTON_DIMS.x / 2),
    .y = build_options.SCREEN_HEIGHT - 150,
    .width = BUTTON_DIMS.x,
    .height = BUTTON_DIMS.y,
};

const HEADER_TEXT = "Leaderboard";
const HEADER_FONT_SIZE = 40;
const HEADER_COLOR: rl.Color = .black;

const NAME_FONT_SIZE = 55;
const NAME_COLOR: rl.Color = .black;
const NAME_POSITION_Y = build_options.SCREEN_HEIGHT - 250;

const NAME_SELECTION_PADDING = 20;

const CURSOR_SIZE = 20;

const LEADERBOARD_BOUNDS: rl.Rectangle = .{
    .x = (build_options.SCREEN_WIDTH - build_options.SCREEN_HEIGHT) * 0.5,
    .y = 0,
    .width = build_options.SCREEN_HEIGHT, // square
    .height = build_options.SCREEN_HEIGHT,
};

pub fn update(self: *Leaderboard, dt: f32) void {
    _ = dt;
    self.btn.update(BUTTON_BOUNDS);

    //change highlighted character index....
    if (rl.isKeyPressed(.right)) {
        self.active_idx = (self.active_idx + 1) % 3;
        is_pressed = true;
    } else if (rl.isKeyPressed(.left)) {
        self.active_idx = (self.active_idx + 3 - 1) % 3;
        is_pressed = true;
    } else {
        is_pressed = false;
    }
}

pub fn draw(self: *const Leaderboard, bounds: rl.Rectangle) void {
    _ = bounds;

    const HEADER_WIDTH = rl.measureText(HEADER_TEXT, HEADER_FONT_SIZE);

    const HEADER_COORDS: rl.Vector2 = .{
        .x = LEADERBOARD_BOUNDS.x + (LEADERBOARD_BOUNDS.width - @as(f32, @floatFromInt(HEADER_WIDTH))) * 0.5,
        .y = LEADERBOARD_BOUNDS.y + TEXT_PADDING,
    };

    //Draw background of leaderboard
    rl.drawRectangleRec(LEADERBOARD_BOUNDS, .{
        .r = 211,
        .g = 211,
        .b = 211,
        .a = 125,
    });

    //draw leaderboard header
    rl.drawText(
        HEADER_TEXT,
        @intFromFloat(HEADER_COORDS.x),
        @intFromFloat(HEADER_COORDS.y),
        HEADER_FONT_SIZE,
        HEADER_COLOR,
    );

    //draw user name input
    const NAME_WIDTH = rl.measureText(self.name, NAME_FONT_SIZE);

    const NAME_COORDS: rl.Vector2 = .{
        .x = LEADERBOARD_BOUNDS.x + (LEADERBOARD_BOUNDS.width - @as(f32, @floatFromInt(NAME_WIDTH))) * 0.5,
        .y = NAME_POSITION_Y + TEXT_PADDING,
    };

    rl.drawText(
        self.name,
        @intFromFloat(NAME_COORDS.x),
        @intFromFloat(NAME_COORDS.y),
        NAME_FONT_SIZE,
        NAME_COLOR,
    );

    //draw selection triangles
    const char_x = NAME_COORDS.x;

    for (0..3) |idx| {
        const char_buf: [1:0]u8 = .{self.name[idx]};
        const char_width = rl.measureText(&char_buf, NAME_FONT_SIZE);
        const char_width_fl = @as(f32, @floatFromInt(char_width));
        // const font_size_fl = @as(f32, @floatFromInt(NAME_FONT_SIZE));

        if (idx == self.active_idx) {
            const center_x = char_x + char_width_fl * 0.5;
            const top_y = NAME_COORDS.y - NAME_SELECTION_PADDING;
            // const bottom_y = NAME_COORDS.y + font_size_fl + NAME_SELECTION_PADDING;

            //top triangle
            const cursor_source: rl.Rectangle = .{
                .x = 0,
                .y = 0,
                .width = @floatFromInt(self.cursor_texture.width),
                .height = @floatFromInt(self.cursor_texture.height),
            };

            self.cursor_texture.drawPro(
                cursor_source,
                .{
                    .x = center_x - CURSOR_SIZE / 2,
                    .y = top_y,
                    .width = CURSOR_SIZE, //square
                    .height = CURSOR_SIZE,
                },
                .{
                    .x = 0.5 * cursor_source.width,
                    .y = 0.5 * cursor_source.height,
                },
                0,
                .white,
            );

            self.cursor_texture.drawPro(
                cursor_source,
                .{
                    .x = center_x - CURSOR_SIZE / 2,
                    .y = top_y + NAME_FONT_SIZE + 5,
                    .width = CURSOR_SIZE, //square
                    .height = CURSOR_SIZE,
                },
                .{
                    .x = 0.5 * cursor_source.width,
                    .y = 0.5 * cursor_source.height,
                },
                180,
                .white,
            );
        }

        //Leaderboard Background
        self.btn.draw(BUTTON_BOUNDS);
    }
}
