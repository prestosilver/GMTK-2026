const std = @import("std");

const Shop = @import("Shop.zig");

//Name / Cost
pub const UpgradeType = enum { Monkey, Power, DevilFruit, NewUgrade };

pub const UpgradeData = struct {
    type: UpgradeType,
    cost: u32,
    name: [:0]const u8,
};

//TODO costs should prob increase by a fn? Should these be base prices?
pub const UPGRADE_INFO = [_]UpgradeData{ .{
    .type = UpgradeType.Monkey,
    .name = "Monkey",
    .cost = 100,
}, .{
    .type = UpgradeType.Power,
    .name = "Power",
    .cost = 500,
}, .{
    .type = UpgradeType.DevilFruit,
    .name = "Devil Fruit",
    .cost = 1000,
}, .{
    .type = UpgradeType.NewUgrade,
    .name = "Joe Bamba",
    .cost = 9000,
} };

//TODO impl upgrade logic
//all upgrade logic goes here...
pub fn applyUpgrade(upg: UpgradeData, shop: *Shop) !void {
    const PLR_MONEY = shop.money;
    const COST = upg.cost;

    if (PLR_MONEY < COST) {
        //throw an error.. player doesn't have enough moneys..

        return;
    }

    //charge player the cost
    shop.money -= COST;

    switch (upg.type) {
        .Monkey => {
            std.log.warn("monke upgrade", .{});
        },
        .Power => {
            std.log.warn("Power up (my ass)", .{});
        },
        .DevilFruit => {
            std.log.warn("No swim :(", .{});
        },
        .NewUgrade => {
            std.log.warn("Yes, I spelled this wrong", .{});
        },
    }
}
