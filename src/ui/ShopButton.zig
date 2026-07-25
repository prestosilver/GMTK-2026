const std = @import("std");
const rl = @import("raylib");
const Upgrades = @import("../Upgrades.zig");
const Shop = @import("../Shop.zig");
const Board = @import("../Board.zig");
const Button = @import("Button.zig");

button: Button,
upgrade: Upgrades.UpgradeData,
shop: *Shop,
board: *Board,

const ShopButton = @This();

fn on_click(self: *const ShopButton) void {
    try Upgrades.applyUpgrade(self.upgrade, self.shop, self.board);
}

pub fn update(self: *ShopButton, bounds: rl.Rectangle) void {
    self.button.update(bounds);

    //not my favorite thing. Only thing I could think of tho bc no closures. (My react brain hates this)
    if (self.button._is_clicked) on_click(self);
}

pub fn draw(self: *const ShopButton, bounds: rl.Rectangle) void {
    self.button.draw(bounds);
}
