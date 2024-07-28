const std = @import("std");
const rl = @import("raylib");
const rlm = @import("raymath");

// aliases:
const vec2 = rl.Vector2;
const keyboard = rl.KeyboardKey;

const BACKGROUND_COLOR = rl.Color.init(25, 25, 25, 255);

const Ball = struct {
    position: vec2,
    size: vec2,

    pub fn init(position: vec2, size: vec2) Ball {
        return Ball{ .position = position, .size = size };
    }

    pub fn draw(this: Ball) void {
        rl.drawRectangleV(this.position, this.size, rl.Color.white);
    }
};
const Player = struct {
    position: vec2,
    size: vec2,
    const DEFAULT_SIZE: vec2 = vec2.init(20.0, 60.0);

    pub fn init(position: vec2) Player {
        return Player{ .position = position, .size = DEFAULT_SIZE };
    }

    pub fn draw(this: Player) void {
        rl.drawRectangleV(this.position, this.size, rl.Color.white);
    }
};

const SCREEN_WIDTH = 600;
const SCREEN_HEIGHT = 360;

// setup:
const Global = struct {
    ball: Ball,
    player1: Player,
    player2: Player,
    const PLAYER_XOFFSET = 20.0;
    const BALL_SIZE = vec2.init(20.0, 20.0);

    pub fn init() Global {
        return Global{
            .ball = Ball.init(vec2.init(SCREEN_WIDTH / 2 - BALL_SIZE.x / 2, SCREEN_HEIGHT / 2 - BALL_SIZE.y / 2), BALL_SIZE),
            .player1 = Player.init(vec2.init(PLAYER_XOFFSET, SCREEN_HEIGHT / 2 - Player.DEFAULT_SIZE.y / 2)),
            .player2 = Player.init(vec2.init(SCREEN_WIDTH - Player.DEFAULT_SIZE.x - PLAYER_XOFFSET, SCREEN_HEIGHT / 2 - Player.DEFAULT_SIZE.y / 2)),
        };
    }
};

pub fn main() !void {
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Test");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    var global = Global.init();
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(BACKGROUND_COLOR);
        if (rl.isKeyDown(keyboard.key_w)) {
            global.player1.position.y -= 1.0 * rl.getFrameTime() * 100.0;
        } else if (rl.isKeyDown(keyboard.key_s)) {
            global.player1.position.y += 1.0 * rl.getFrameTime() * 100.0;
        }

        if (rl.isKeyDown(keyboard.key_up)) {
            global.player2.position.y -= 1.0 * rl.getFrameTime() * 100.0;
        } else if (rl.isKeyDown(keyboard.key_down)) {
            global.player2.position.y += 1.0 * rl.getFrameTime() * 100.0;
        }

        global.ball.draw();
        global.player1.draw();
        global.player2.draw();
        //rl.drawText("This is some test text", 190, 200, 20, rl.Color.light_gray);
    }
}
