const std = @import("std");
const rl = @import("raylib");

const ShopButton = @import("ui/ShopButton.zig");
const Button = @import("ui/Button.zig");
const Board = @import("./Board.zig");

const Upgrades = @import("Upgrades.zig");

const Shop = @This();
money: u64 = 0,
y_offset: f32 = 0,
board: *Board = undefined,

const SHOP_BG: rl.Color = .{ .r = 128, .g = 42, .b = 98, .a = 255 };
const SHOP_TEXT: rl.Color = .{ .r = 0, .g = 0, .b = 0, .a = 255 };

const SHOP_PADDING = (.{ .x = 20, .y = 20 });
const BUTTON_HEIGHT = 50;

const DARTS_FONT_SIZE = 35;
const TITLE_FONT_SIZE = 35;
const MONEY_FONT_SIZE = 24;

const START_BUTTONS_Y = DARTS_FONT_SIZE + TITLE_FONT_SIZE + MONEY_FONT_SIZE + (SHOP_PADDING.y * 2);

//TODO - better way to do this? bad practice ik. Couldn't figure out to reference Shop elsewhere.
var buttons: [Upgrades.UPGRADE_INFO.len]ShopButton = undefined;

pub fn setup(self: *Shop, board: *Board) void {
    for (Upgrades.UPGRADE_INFO, 0..) |info, iter| {
        self.board = board;

        var shop_btn = &buttons[iter];

        shop_btn.* = .{
            .upgrade = info,
            .button = Button{},
            .shop = self,
        };

        //format text w/ buf being stored within button
        shop_btn.button.text = std.fmt.bufPrintSentinel(
            &shop_btn.button.text_buf,
            "{s} ({d})",
            .{ info.name, info.cost },
            0,
        ) catch unreachable;
    }
}

pub fn update(self: *Shop, dt: f64, bounds: rl.Rectangle) !void {
    _ = self;
    _ = dt;

    for (&buttons, 0..) |*btn, idx| {
        const btn_bounds = getButtonBounds(bounds, @as(f32, @floatFromInt(idx)));
        btn.update(btn_bounds);
    }
}

pub fn draw(self: *const Shop, bounds: rl.Rectangle) void {
    //background panel
    rl.drawRectangleRec(bounds, SHOP_BG);

    const START_X = bounds.x + SHOP_PADDING.x;
    const START_Y = bounds.y + SHOP_PADDING.y;

    var y_pos = START_Y;

    //draw darts
    var darts_fmt: [64]u8 = undefined;
    const darts_text = std.fmt.bufPrintSentinel(
        &darts_fmt,
        "{:07}",
        .{self.board.darts.capacity - self.board.darts.items.len},
        0,
    ) catch unreachable;

    rl.drawText(
        darts_text,
        @intFromFloat(START_X),
        @intFromFloat(y_pos),
        DARTS_FONT_SIZE,
        SHOP_TEXT,
    );

    y_pos += DARTS_FONT_SIZE;

    //draw title
    rl.drawText(
        "Darts a Million",
        @intFromFloat(START_X),
        @intFromFloat(y_pos),
        TITLE_FONT_SIZE,
        SHOP_TEXT,
    );

    y_pos += TITLE_FONT_SIZE;

    //draw money/points
    var money_fmt: [64]u8 = undefined;
    const money_text = std.fmt.bufPrintSentinel(
        &money_fmt,
        "Points: {d}",
        .{self.money},
        0,
    ) catch unreachable;

    //Draw moneys
    rl.drawText(
        money_text,
        @intFromFloat(bounds.x + SHOP_PADDING.x),
        @intFromFloat(y_pos),
        MONEY_FONT_SIZE,
        SHOP_TEXT,
    );

    for (buttons, 0..) |btn, iter| {
        const idx = @as(f32, @floatFromInt(iter));
        btn.draw(getButtonBounds(bounds, idx));
    }
}

fn getButtonBounds(shop_bounds: rl.Rectangle, idx: f32) rl.Rectangle {
    const START_X = shop_bounds.x + SHOP_PADDING.x;
    const BUTTON_WIDTH = shop_bounds.width - SHOP_PADDING.x * 2;

    return .{
        .x = START_X,
        .y = START_BUTTONS_Y + ((BUTTON_HEIGHT * idx) + (SHOP_PADDING.y * idx)),
        .width = BUTTON_WIDTH,
        .height = BUTTON_HEIGHT,
    };
}
