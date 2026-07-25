const std = @import("std");
const rl = @import("raylib");
const build_options = @import("build_options");

const Board = @import("Board.zig");
const Dart = @import("Dart.zig");
const Shop = @import("Shop.zig");

pub fn customLogFn(
    comptime level: std.log.Level,
    comptime _: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    var buf: [1024]u8 = undefined;
    const log: [*c]const u8 = std.fmt.bufPrintZ(&buf, format, args) catch unreachable;

    rl.traceLog(switch (level) {
        .debug => .debug,
        .info => .info,
        .warn => .warning,
        .err => .err,
    }, "%s", .{log});
}

pub const std_options: std.Options = .{
    // Fix a emscripten bug in 0.16 that breaks std.defaultLog
    .logFn = customLogFn,
};

const SCREEN_WIDTH = 1200;
const SCREEN_HEIGHT = 675;

const SHOP_X = 800; //pixels
const SHOP_WIDTH = SCREEN_WIDTH - 800;

const BG_COLOR: rl.Color = .{ .r = 72, .g = 25, .b = 89, .a = 255 };

var state: enum { game } = .game;

var board: Board = .{};
var shop: Shop = .{};

var throwing_dart: Dart = .{};

const BOARD_BOUNDS: rl.Rectangle = .{
    .x = 0,
    .y = 0,
    .width = SCREEN_HEIGHT, // square
    .height = SCREEN_HEIGHT,
};

const SHOP_BOUNDS: rl.Rectangle = .{
    .x = SHOP_X,
    .y = 0,
    .width = SHOP_WIDTH,
    .height = SCREEN_HEIGHT,
};

pub fn sendHighscore(name: *const [3]u8, score: u32) void {
    switch (@import("builtin").cpu.arch) {
        .wasm32 => {
            // We shouldnt be calling this much
            // keeping the import in local scope to reflect that
            const emasm = @import("emasm.zig");
            emasm.EM_ASM((
                \\sendHighscore(UTF8ToString($0), $1);
            ), .{ &name, score });
        },
        else => |platform| std.log.warn("unimplemented: sendHighscore({s}, {}) on {s} with salt `{s}`", .{ name, score, @tagName(platform), build_options.BOARD_SALT }),
    }
}

pub fn main() !void {
    board.setup();
    shop.setup();

    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, build_options.GAME_NAME);
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.setExitKey(.null);

    // Load a texture
    board.sprite = try rl.loadTexture("board.png");
    defer board.sprite.unload();

    sendHighscore("JEF", 32);

    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();

        // update state
        switch (state) {
            .game => {
                try board.update(dt, &shop, BOARD_BOUNDS);
                try shop.update(dt, SHOP_BOUNDS);
            },
        }

        // draw frame
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(BG_COLOR);

        switch (state) {
            .game => {
                board.draw(BOARD_BOUNDS);
                shop.draw(SHOP_BOUNDS);
            },
        }
    }
}
