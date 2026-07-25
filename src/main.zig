const std = @import("std");
const rl = @import("raylib");
const build_options = @import("build_options");

const Board = @import("Board.zig");
const Dart = @import("Dart.zig");
const Shop = @import("Shop.zig");
const Leaderboard = @import("./ui/Leaderboard.zig");

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

const SHOP_X = 800; //pixels
const SHOP_WIDTH = build_options.SCREEN_WIDTH - 800;

const BG_COLOR: rl.Color = .{ .r = 0, .g = 0, .b = 0, .a = 255 };

const State = enum { title, game, end };
var state: State = .title;

var board: Board = .{};
var shop: Shop = .{};
var leaderboard: Leaderboard = .{};

// aim is accuracy circle
var transition_timer: f64 = 0.0;

const TITLE_BOARD_BOUNDS: rl.Rectangle = .{
    .x = (build_options.SCREEN_WIDTH - build_options.SCREEN_HEIGHT) * 0.5,
    .y = 0,
    .width = build_options.SCREEN_HEIGHT, // square
    .height = build_options.SCREEN_HEIGHT,
};

const END_BOARD_BOUNDS: rl.Rectangle = .{
    .x = (build_options.SCREEN_WIDTH - build_options.SCREEN_HEIGHT) * 0.5,
    .y = 0,
    .width = build_options.SCREEN_HEIGHT, // square
    .height = build_options.SCREEN_HEIGHT,
};

const BOARD_BOUNDS: rl.Rectangle = .{
    .x = 0,
    .y = 0,
    .width = build_options.SCREEN_HEIGHT, // square
    .height = build_options.SCREEN_HEIGHT,
};

const SHOP_BOUNDS: rl.Rectangle = .{
    .x = SHOP_X,
    .y = 0,
    .width = SHOP_WIDTH,
    .height = build_options.SCREEN_HEIGHT,
};

const LEADERBORAD_BOUNDS: rl.Rectangle = .{
    .x = 0,
    .y = 0,
    .width = build_options.SCREEN_HEIGHT, // square
    .height = build_options.SCREEN_HEIGHT,
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

pub fn setState(new_state: State) void {
    switch (new_state) {
        .title => {
            board.setup();
        },
        .game => {
            shop.setup(&board);
        },
        .end => {},
    }
    state = new_state;

    transition_timer = 0.0;
}

pub fn main() !void {
    rl.initWindow(build_options.SCREEN_WIDTH, build_options.SCREEN_HEIGHT, build_options.GAME_NAME);
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.setExitKey(.null);

    // Load a texture
    board.sprite = try rl.loadTexture("board.png");
    defer board.sprite.unload();

    Dart.dart_sprite = try rl.loadTexture("dart.png");
    defer Dart.dart_sprite.unload();

    Dart.shadow_sprite = try rl.loadTexture("dart_shadow.png");
    defer Dart.shadow_sprite.unload();

    sendHighscore("JEF", 32);

    setState(.title);

    rl.hideCursor();

    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();
        transition_timer += dt / 2.0;
        transition_timer = @min(1.0, transition_timer);

        if (board.throwing_phase == .place) {
            board.throwing_dart.position = rl.getMousePosition();
        }

        // update state
        switch (state) {
            .title => {
                try board.update(dt, &shop, TITLE_BOARD_BOUNDS);
                if (board.darts.items.len > 0)
                    setState(.game);
            },
            .game => {
                try board.update(dt, &shop, BOARD_BOUNDS);
                try shop.update(dt, SHOP_BOUNDS);

                if (board.darts.items.len >= board.darts.capacity)
                    setState(.end);
            },
            .end => {
                try leaderboard.update(dt);
            },
        }

        // draw frame
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(BG_COLOR);

        switch (state) {
            .title => {
                board.draw(TITLE_BOARD_BOUNDS);
            },
            .game => {
                shop.draw(.{
                    .x = @floatCast(SHOP_BOUNDS.x + SHOP_BOUNDS.width * (1.0 - transition_timer)),
                    .y = SHOP_BOUNDS.y,
                    .width = SHOP_BOUNDS.width,
                    .height = SHOP_BOUNDS.height,
                });
                board.draw(.{
                    .x = @floatCast(TITLE_BOARD_BOUNDS.x + (BOARD_BOUNDS.x - TITLE_BOARD_BOUNDS.x) * transition_timer),
                    .y = BOARD_BOUNDS.y,
                    .width = BOARD_BOUNDS.width,
                    .height = BOARD_BOUNDS.height,
                });
            },
            .end => {
                board.draw(END_BOARD_BOUNDS);
                leaderboard.draw(LEADERBORAD_BOUNDS);
            },
        }
    }
}
