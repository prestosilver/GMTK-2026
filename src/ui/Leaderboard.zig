const std = @import("std");
const rl = @import("raylib");
const build_options = @import("build_options");

const OnClickCallbackType = *const fn () void;
const Leaderboard = @This();

score: u32 = 0,
active_idx: u32 = 0,
name: [3:0]u8 = "AAA".*,
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
const HEADER_FONT_SIZE = 30;
const HEADER_COLOR: rl.Color = .black;

const NAME_SLOT_SIZE = 60;
const TOTAL_NAME_WIDTH = NAME_SLOT_SIZE * 3;
const NAME_FONT_SIZE = 55;
const NAME_COLOR: rl.Color = .black;
const NAME_POSITION_Y = build_options.SCREEN_HEIGHT - 250;

const NAME_SELECTION_PADDING = 20;

const CURSOR_SIZE = 20;

const PRESS_ENTER_TEXT = "Press Enter To Submit Score";
const PRESS_ENTER_FONT_SIZE = 35;

const LEADERBOARD_BOUNDS: rl.Rectangle = .{
    .x = (build_options.SCREEN_WIDTH - build_options.SCREEN_HEIGHT) * 0.5,
    .y = 0,
    .width = build_options.SCREEN_HEIGHT, // square
    .height = build_options.SCREEN_HEIGHT,
};

pub fn update(self: *Leaderboard, dt: f32) bool {
    _ = dt;

    //change highlighted character index....
    if (rl.isKeyPressed(.right)) {
        self.active_idx = (self.active_idx + 1) % 3;
        is_pressed = true;
    } else if (rl.isKeyPressed(.left)) {
        self.active_idx = (self.active_idx + 3 - 1) % 3;
        is_pressed = true;
    } else if (rl.isKeyPressed(.up)) {
        var char_idx = std.mem.indexOf(u8, VALID_CHARS, &.{self.name[self.active_idx]}) orelse 0;
        char_idx += 1;

        //prevent overflow, 1 + 26
        char_idx = char_idx % VALID_CHARS.len;
        self.name[self.active_idx] = VALID_CHARS[char_idx];
        is_pressed = true;
    } else if (rl.isKeyPressed(.down)) {
        var char_idx = std.mem.indexOf(u8, VALID_CHARS, &.{self.name[self.active_idx]}) orelse 0;
        char_idx += VALID_CHARS.len - 1;
        char_idx = char_idx % VALID_CHARS.len;
        self.name[self.active_idx] = VALID_CHARS[char_idx];
        is_pressed = true;
    } else if (rl.isKeyPressed(.enter)) {

        //submit score here...
        return true;
    } else {
        is_pressed = false;
    }

    return false;
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
        .a = 200,
    });

    //draw leaderboard header
    rl.drawText(
        HEADER_TEXT,
        @intFromFloat(HEADER_COORDS.x),
        @intFromFloat(HEADER_COORDS.y),
        HEADER_FONT_SIZE,
        HEADER_COLOR,
    );

    const name = &self.name;

    //draw user name input
    const NAME_WIDTH = rl.measureText(name, NAME_FONT_SIZE);

    const NAME_COORDS: rl.Vector2 = .{
        .x = LEADERBOARD_BOUNDS.x + (LEADERBOARD_BOUNDS.width - @as(f32, @floatFromInt(NAME_WIDTH))) * 0.5,
        .y = NAME_POSITION_Y + TEXT_PADDING,
    };

    //get midpoint for starting position
    const start_x = LEADERBOARD_BOUNDS.x + (LEADERBOARD_BOUNDS.width - TOTAL_NAME_WIDTH) * 0.5;

    for (0..3) |idx| {
        const idx_fl = @as(f32, @floatFromInt(idx));
        const slot_x = start_x + NAME_SLOT_SIZE * idx_fl;

        const char_buf: [1:0]u8 = .{name[idx]};
        const char_width = @as(f32, @floatFromInt(rl.measureText(&char_buf, NAME_FONT_SIZE)));

        //center letter
        const draw_x = slot_x + (NAME_SLOT_SIZE - char_width) * 0.5;

        rl.drawText(
            &char_buf,
            @intFromFloat(draw_x),
            @intFromFloat(NAME_COORDS.y),
            NAME_FONT_SIZE,
            NAME_COLOR,
        );

        //draw cursors if ids of active one.
        if (idx == self.active_idx) {
            const center_x = slot_x + NAME_SLOT_SIZE * 0.5;
            const top_y = NAME_COORDS.y - NAME_SELECTION_PADDING;

            //top triangle
            const cursor_source: rl.Rectangle = .{
                .x = 0,
                .y = 0,
                .width = @as(f32, @floatFromInt(self.cursor_texture.width)) - 0.1,
                .height = @as(f32, @floatFromInt(self.cursor_texture.height)) - 0.1,
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
                    .x = 0.5,
                    .y = 0.5,
                },
                0,
                .white,
            );

            self.cursor_texture.drawPro(
                cursor_source,
                .{
                    .x = center_x - CURSOR_SIZE / 2,
                    .y = top_y + NAME_FONT_SIZE,
                    .width = CURSOR_SIZE, //square
                    .height = CURSOR_SIZE,
                },
                .{
                    .x = 0.5,
                    .y = 0.5,
                },
                0,
                .white,
            );
        }
    }

    const prompt_width = rl.measureText(PRESS_ENTER_TEXT, PRESS_ENTER_FONT_SIZE);

    //Print instructions to press enter to submit score
    rl.drawText(
        "Press Enter To Submit Score",
        build_options.SCREEN_WIDTH / 2 - @divFloor(prompt_width, 2),
        build_options.SCREEN_HEIGHT - 100,
        PRESS_ENTER_FONT_SIZE,
        .black,
    );
}
