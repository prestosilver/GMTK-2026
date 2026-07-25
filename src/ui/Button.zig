const std = @import("std");
const rl = @import("raylib");

const OnClickCallbackType = *const fn () void;

const Button = @This();
text_buf: [64:0]u8 = undefined,
text: [:0]const u8 = "",
btn_color: rl.Color = .white,
hover_color: rl.Color = .gray,
txt_color: rl.Color = .black,
on_click: ?OnClickCallbackType = null,
_is_hovered: bool = false,
_is_clicked: bool = false,

const FONT_SIZE = 20;
const TEXT_PADDING = 20;

pub fn update(self: *Button, bounds: rl.Rectangle) !void {
    const mouse = rl.getMousePosition();

    self._is_hovered = rl.checkCollisionPointRec(mouse, bounds);

    if (self._is_hovered) {
        if (rl.isMouseButtonPressed(.left)) {
            self._is_clicked = true;
            if (self.on_click) |cb| {
                std.log.warn("on click..", .{});
                cb();
            }
        } else self._is_clicked = false;
    }
}

pub fn draw(self: *const Button, bounds: rl.Rectangle) void {
    var color = self.btn_color;
    if (self._is_hovered) color = self.hover_color;

    rl.drawRectangleRounded(bounds, 0.25, 2, color);
    rl.drawText(self.text, @intFromFloat(bounds.x + TEXT_PADDING), @intFromFloat(bounds.y + (bounds.height / 2) - (FONT_SIZE / 2)), FONT_SIZE, self.txt_color);
}
