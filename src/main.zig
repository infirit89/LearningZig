const std = @import("std");
const rl = @import("raylib");

const BACKGROUND_COLOR = rl.Color.init(25, 25, 25, 255);

const Ball = struct {
    position: rl.Vector2,
    size: rl.Vector2,

    pub fn init(position: rl.Vector2, size: rl.Vector2) Ball {
        return Ball{ .position = position, .size = size };
    }

    pub fn draw(this: Ball) void {
        rl.drawRectangleV(this.position, this.size, rl.Color.white);
    }
};
const Player = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    const DEFAULT_SIZE: rl.Vector2 = rl.Vector2.init(20, 60);

    pub fn init(position: rl.Vector2) Player {
        return Player{ .position = position, .size = DEFAULT_SIZE };
    }

    pub fn draw(this: Player) void {
        rl.drawRectangleV(this.position, this.size, rl.Color.white);
    }
};

// setup:
const ball = Ball.init(rl.Vector2.init(0, 0), rl.Vector2.init(20, 20));
const player1 = Player.init(rl.Vector2.init(10, 10));
const player2 = Player.init(rl.Vector2.init(60, 10));

pub fn main() !void {
    const screenWidth = 600;
    const screenHeight = 360;

    rl.initWindow(screenWidth, screenHeight, "Test");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(BACKGROUND_COLOR);
        ball.draw();
        player1.draw();
        player2.draw();
        //rl.drawText("This is some test text", 190, 200, 20, rl.Color.light_gray);
    }
}
