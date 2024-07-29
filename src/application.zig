const std = @import("std");
const rl = @import("raylib");
const p = @import("player.zig");
const b = @import("ball.zig");

// aliases:
const vec2 = rl.Vector2;
const rect = rl.Rectangle;

const BACKGROUND_COLOR = rl.Color.init(25, 25, 25, 255);

pub const Application = struct {
    ball: b.Ball,
    player1: p.Player,
    player2: p.Player,
    player1Score: u32,
    player2Score: u32,
    frameTimeScaler: f32,
    screenWidth: i32,
    screenHeight: i32,
    const PLAYER_XOFFSET = 20.0;
    const BALL_SIZE = vec2.init(20.0, 20.0);
    const PLAYER_SIZE: vec2 = vec2.init(20.0, 60.0);

    pub fn init(windowWidth: comptime_int, windowHeight: comptime_int, title: [*:0]const u8) Application {
        rl.initWindow(windowWidth, windowHeight, title);

        return Application{
            .ball = undefined,
            .player1 = undefined,
            .player2 = undefined,
            .player1Score = 0,
            .player2Score = 0,
            .frameTimeScaler = 0,
            .screenWidth = windowWidth,
            .screenHeight = windowHeight,
        };
    }
    pub fn createObjects(this: *Application) void {
        const halfScreenHeight: f32 = @floatFromInt(@divTrunc(this.screenHeight, 2));
        const screenWidthF: f32 = @floatFromInt(this.screenWidth);

        // setup ball:
        var ball = b.Ball.init(.{ .x = 0, .y = 0, .width = BALL_SIZE.x, .height = BALL_SIZE.y });
        ball.cententer();
        this.ball = ball;

        // setup player1:
        const player1Controlls = .{ .up = .key_w, .down = .key_s };
        const playerY = halfScreenHeight - PLAYER_SIZE.y / 2;
        const player1Rect = .{ .x = PLAYER_XOFFSET, .y = playerY, .width = PLAYER_SIZE.x, .height = PLAYER_SIZE.y };
        this.player1 =
            p.Player.init(player1Rect, player1Controlls);

        const player2Controlls = .{ .up = .key_up, .down = .key_down };
        const player2X = screenWidthF - PLAYER_SIZE.x - PLAYER_XOFFSET;
        const player2Rect = .{ .x = player2X, .y = playerY, .width = PLAYER_SIZE.x, .height = PLAYER_SIZE.y };
        this.player2 =
            p.Player.init(player2Rect, player2Controlls);
    }

    pub fn shutdown() void {
        rl.closeWindow();
    }

    pub fn run(this: *Application) void {
        this.createObjects();
        while (!rl.windowShouldClose()) {
            rl.beginDrawing();
            defer rl.endDrawing();

            rl.clearBackground(BACKGROUND_COLOR);

            this.update();

            this.draw();
        }
    }

    pub fn update(this: *Application) void {
        this.frameTimeScaler = rl.getFrameTime() * 100.0;

        this.player1.update();
        this.player2.update();

        this.ball.update();
        if (this.ball.rectangle.checkCollision(this.player1.rectangle)) {
            this.ball.direction = vec2.init(1, -1);
        } else if (this.ball.rectangle.checkCollision(this.player2.rectangle)) {
            this.ball.direction = vec2.init(-1, 1);
        }
    }

    pub fn draw(this: Application) void {
        const fontSize = 20;
        const textXOffset = 20;
        const textColor = rl.Color.light_gray;
        const pos1X: i32 = @intFromFloat(this.player1.rectangle.x);
        const pos2X: i32 = @intFromFloat(this.player2.rectangle.x);

        const player1ScoreStr = rl.textFormat("%i", .{this.player1Score});
        rl.drawText(player1ScoreStr, pos1X, textXOffset, fontSize, textColor);
        const player2ScoreStr = rl.textFormat("%i", .{this.player2Score});
        rl.drawText(player2ScoreStr, pos2X, textXOffset, fontSize, textColor);

        this.ball.draw();
        this.player1.draw();
        this.player2.draw();
    }
};
