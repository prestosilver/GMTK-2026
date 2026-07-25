const std = @import("std");
const rl = @import("raylib");

const ShopButton = @import("ui/ShopButton.zig");
const Button = @import("ui/Button.zig");

const Upgrades = @import("Upgrades.zig");

const Shop = @This();
money: u64 = 0,
y_offset: f32 = 0,

const SHOP_BG: rl.Color = .{ .r = 128, .g = 42, .b = 98, .a = 255 };
const SHOP_TEXT: rl.Color = .{ .r = 0, .g = 0, .b = 0, .a = 255 };

const SHOP_PADDING = (.{ .x = 20, .y = 20 });
const BUTTON_HEIGHT = 50;
const TITLE_FONT_SIZE = 35;
const MONEY_FONT_SIZE = 24;

//TODO - better way to do this? bad practice ik. Couldn't figure out to reference Shop elsewhere.
var buttons: [Upgrades.UPGRADE_INFO.len]ShopButton = undefined;

pub fn setup(self: *Shop) void {
    for (Upgrades.UPGRADE_INFO, 0..) |info, iter| {
        var shop_btn = &buttons[iter];

        shop_btn.* = .{
            .upgrade = info.type,
            .button = Button{},
            .shop = self,
        };

        //format text w/ buf being stored within button
        shop_btn.button.text = std.fmt.bufPrintSentinel(&shop_btn.button.text_buf, "{s} ({d})", .{ info.name, info.cost }, 0) catch unreachable;
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

    //draw title
    rl.drawText(
        "Darts a Million",
        @intFromFloat(START_X),
        @intFromFloat(START_Y),
        TITLE_FONT_SIZE,
        SHOP_TEXT,
    );

    //draw money/points

    //this is really dumb?? why are zig fstrings like this lmfao. Let me know if im doing it wrong.
    //initially was using bufPrintZ but it said it was depricated in favor of bufPrintSentinel. Not sure the difference ngl.
    var money_fmt: [64]u8 = undefined;

    const text = std.fmt.bufPrintSentinel(&money_fmt, "Points: {d}", .{self.money}, 0) catch unreachable;

    //Draw moneys
    rl.drawText(text, @intFromFloat(bounds.x + SHOP_PADDING.x), @intFromFloat(START_Y + TITLE_FONT_SIZE), MONEY_FONT_SIZE, SHOP_TEXT);

    for (buttons, 0..) |btn, iter| {
        const idx = @as(f32, @floatFromInt(iter));
        btn.draw(getButtonBounds(bounds, idx));
    }
}

fn getButtonBounds(shop_bounds: rl.Rectangle, idx: f32) rl.Rectangle {
    const START_X = shop_bounds.x + SHOP_PADDING.x;
    const START_Y = shop_bounds.y + SHOP_PADDING.y;
    const BUTTON_START = START_Y + TITLE_FONT_SIZE + MONEY_FONT_SIZE + SHOP_PADDING.y;
    const BUTTON_WIDTH = shop_bounds.width - SHOP_PADDING.x * 2;

    return .{
        .x = START_X,
        .y = BUTTON_START + ((BUTTON_HEIGHT * idx) + (SHOP_PADDING.y * idx)),
        .width = BUTTON_WIDTH,
        .height = BUTTON_HEIGHT,
    };
}
