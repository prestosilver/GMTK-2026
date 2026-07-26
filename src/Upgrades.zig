const std = @import("std");

const Board = @import("Board.zig");
const Shop = @import("Shop.zig");

//Name / Cost
pub const UpgradeType = enum { Monkey, Spread, Focus, MonkeySpread };

pub const UpgradeData = struct {
    type: UpgradeType,
    base_cost: u32,
    mult: f32,
    name: [:0]const u8,
};

//TODO costs should prob increase by a fn? Should these be base prices?
pub const UPGRADE_INFO = [_]UpgradeData{
    .{ .type = .Spread, .name = "Spread", .base_cost = 100, .mult = 1.5 },
    .{ .type = .Monkey, .name = "Monkey", .base_cost = 500, .mult = 1.5 },
    .{ .type = .Focus, .name = "Focus", .base_cost = 1000, .mult = 1.5 },
    .{ .type = .MonkeySpread, .name = "Monkey Spread", .base_cost = 9000, .mult = 1.5 },
};

pub fn getUpgradeCost(upg: UpgradeData, shop: *const Shop) u32 {
    const purchased = @as(f32, @floatFromInt(shop.purchased_upgrade_count.get(upg.type)));

    return @intFromFloat(@as(f32, @floatFromInt(upg.base_cost)) * (1.0 + purchased * upg.mult));
}

//TODO impl upgrade logic
//all upgrade logic goes here...
pub fn applyUpgrade(upg: UpgradeData, shop: *Shop, board: *Board) !void {
    const PLR_MONEY = shop.money;
    const COST = getUpgradeCost(upg, shop);

    if (PLR_MONEY < COST) {
        //throw an error.. player doesn't have enough moneys..

        return;
    }

    //charge player the cost
    shop.money -= COST;

    switch (upg.type) {
        .Spread => {
            board.throw_count += 1;
        },
        .Monkey => {
            board.dart_monkey_per_second += 5.0;
        },
        .Focus => {
            board.focus *= 0.75;
        },
        .MonkeySpread => {
            board.dart_monkey_spread += 1;
        },
    }

    //increase num of purchased upgrades of type
    shop.purchased_upgrade_count.getPtr(upg.type).* += 1;
}
