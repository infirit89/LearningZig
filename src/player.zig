const std = @import("std");
const rl = @import("raylib");
const g = @import("globabls.zig");

const rect = rl.Rectangle;

pub const Player = struct {
    const Controlls = struct { up: rl.KeyboardKey, down: rl.KeyboardKey };
    rectangle: rect,
    controlls: Controlls,

    pub fn init(rectangle: rect, controlls: Controlls) Player {
        return Player{ .rectangle = rectangle, .controlls = controlls };
    }

    pub fn draw(this: Player) void {
        rl.drawRectangleRec(this.rectangle, rl.Color.white);
    }

    pub fn update(this: *Player) void {
        if (rl.isKeyDown(this.controlls.up)) {
            this.rectangle.y -= 1.0 * g.application.frameTimeScaler;
        } else if (rl.isKeyDown(this.controlls.down)) {
            this.rectangle.y += 1.0 * g.application.frameTimeScaler;
        }
    }
};
