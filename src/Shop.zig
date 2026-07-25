const std = @import("std");
const rl = @import("raylib");

const ShopButton = @import("ui/ShopButton.zig");
const Button = @import("ui/Button.zig");
const Board = @import("./Board.zig");

const Upgrades = @import("Upgrades.zig");

//enum indexed arr for number of purchased upgrades
pub const UpgradeCounts = std.EnumArray(Upgrades.UpgradeType, u32);

const Shop = @This();
money: u64 = 0,
y_offset: f32 = 0,
board: *Board = undefined,
purchased_upgrade_count: UpgradeCounts = UpgradeCounts.initFill(0),
shop_button_container_height: u32 = 0,

const SHOP_BG: rl.Color = .{ .r = 128, .g = 42, .b = 98, .a = 255 };
const SHOP_TEXT: rl.Color = .{ .r = 0, .g = 0, .b = 0, .a = 255 };

const SHOP_PADDING = (.{ .x = 20, .y = 20 });
const BUTTON_HEIGHT = 50;

const DARTS_FONT_SIZE = 66;
const TITLE_FONT_SIZE = 44;
const MONEY_FONT_SIZE = 22;

const SHOP_SCROLL_SPEED = 50;

const START_BUTTONS_Y = DARTS_FONT_SIZE + TITLE_FONT_SIZE + MONEY_FONT_SIZE + (SHOP_PADDING.y * 2);

//TODO - better way to do this? bad practice ik. Couldn't figure out to reference Shop elsewhere.
var buttons: [Upgrades.UPGRADE_INFO.len]ShopButton = undefined;

pub fn setup(self: *Shop, board: *Board) void {
    for (Upgrades.UPGRADE_INFO, 0..) |info, iter| {
        self.board = board;
        const shop_btn = &buttons[iter];
        shop_btn.* = .{
            .upgrade = info,
            .button = Button{},
            .shop = self,
            .board = board,
        };
    }

    self.shop_button_container_height =
        @as(f32, @floatFromInt(buttons.len)) * BUTTON_HEIGHT +
        @as(f32, @floatFromInt(buttons.len - 1)) * SHOP_PADDING.y;
}

pub fn update(self: *Shop, dt: f64, bounds: rl.Rectangle) !void {
    _ = dt;

    for (&buttons, 0..) |*btn, idx| {
        const btn_bounds = getButtonBounds(self, bounds, @as(f32, @floatFromInt(idx)));
        btn.update(btn_bounds);
    }

    const viewport_height = bounds.height - START_BUTTONS_Y;
    const scroll = rl.getMouseWheelMove() * SHOP_SCROLL_SPEED;
    const max_scroll = @max(0, @as(f32, @floatFromInt(self.shop_button_container_height)) - viewport_height);

    self.y_offset += scroll * SHOP_SCROLL_SPEED;
    self.y_offset = std.math.clamp(self.y_offset, -max_scroll, 0);
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
        "{:06}",
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

    rl.beginScissorMode(
        @intFromFloat(bounds.x),
        @intFromFloat(START_BUTTONS_Y),
        @intFromFloat(bounds.width),
        @intFromFloat(bounds.height),
    );

    for (buttons, 0..) |btn, iter| {
        updateButtonText(self, @intCast(iter));
        const idx = @as(f32, @floatFromInt(iter));
        btn.draw(getButtonBounds(self, bounds, idx));
    }

    rl.endScissorMode();
}

fn updateButtonText(self: *const Shop, idx: u32) void {
    var shop_btn = &buttons[idx];
    const UPG_DATA = Upgrades.UPGRADE_INFO[idx];

    //format text w/ buf being stored within button
    shop_btn.button.text = std.fmt.bufPrintSentinel(
        &shop_btn.button.text_buf,
        "{s} ({d})",
        .{ UPG_DATA.name, Upgrades.getUpgradeCost(UPG_DATA, self) },
        0,
    ) catch unreachable;
}

fn getButtonBounds(self: *const Shop, shop_bounds: rl.Rectangle, idx: f32) rl.Rectangle {
    const START_X = shop_bounds.x + SHOP_PADDING.x;
    const BUTTON_WIDTH = shop_bounds.width - SHOP_PADDING.x * 2;

    return .{
        .x = START_X,
        .y = START_BUTTONS_Y + self.y_offset + ((BUTTON_HEIGHT * idx) + (SHOP_PADDING.y * idx)),
        .width = BUTTON_WIDTH,
        .height = BUTTON_HEIGHT,
    };
}
