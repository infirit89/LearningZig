const std = @import("std");
const rl = @import("raylib");
const g = @import("globabls.zig");

const rect = rl.Rectangle;

pub const Player = struct {
    const Controlls = struct { up: rl.KeyboardKey, down: rl.KeyboardKey };
    rectangle: rect,
    controlls: Controlls,
    velocity: f32,

    pub fn init(rectangle: rect, controlls: Controlls) Player {
        return Player{ .rectangle = rectangle, .controlls = controlls, .velocity = 0.0 };
    }

    pub fn draw(this: *const Player) void {
        rl.drawRectangleRec(this.rectangle, rl.Color.white);
    }

    pub fn update(this: *Player) void {
        const dragCoef = 0.01;
        if (rl.isKeyDown(this.controlls.up)) {
            this.velocity -= 1.0 * g.application.frameTimeScaler / 10.0;
        } else if (rl.isKeyDown(this.controlls.down)) {
            this.velocity += 1.0 * g.application.frameTimeScaler / 10.0;
        }

        this.velocity *= 1.0 - dragCoef;
        this.rectangle.y += this.velocity;
        const screenHeightF: f32 = @floatFromInt(g.application.screenHeight);
        if (this.rectangle.y <= 0) {
            this.rectangle.y = 0;
        } else if (this.rectangle.y + this.rectangle.height >= screenHeightF) {
            this.rectangle.y = screenHeightF - this.rectangle.height;
        }
    }
};
