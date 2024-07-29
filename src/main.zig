const std = @import("std");
const rl = @import("raylib");

// aliases:
const vec2 = rl.Vector2;
const keyboard = rl.KeyboardKey;
const rndGen = std.rand.DefaultPrng;

const BACKGROUND_COLOR = rl.Color.init(25, 25, 25, 255);

const Ball = struct {
    position: vec2,
    size: vec2,

    pub fn init(position: vec2, size: vec2) Ball {
        return Ball{ .position = position, .size = size };
    }
    pub fn init2(size: vec2) Ball {
        return Ball{ .position = vec2.init(0, 0), .size = size };
    }

    pub fn draw(this: Ball) void {
        rl.drawRectangleV(this.position, this.size, rl.Color.white);
    }
};
const Player = struct {
    position: vec2,
    size: vec2,

    pub fn init(position: vec2, size: vec2) Player {
        return Player{ .position = position, .size = size };
    }

    pub fn draw(this: Player) void {
        rl.drawRectangleV(this.position, this.size, rl.Color.white);
    }
};

// setup:
const Global = struct {
    ball: Ball,
    player1: Player,
    player2: Player,
    ballDirection: vec2,
    player1Score: u32,
    player2Score: u32,
    const PLAYER_XOFFSET = 20.0;
    const BALL_SIZE = vec2.init(20.0, 20.0);
    const PLAYER_SIZE: vec2 = vec2.init(20.0, 60.0);
    const SCREEN_WIDTH = 600;
    const SCREEN_HEIGHT = 360;

    fn cententerBall(ballPtr: *Ball) void {
        ballPtr.position =
            vec2.init(SCREEN_WIDTH / 2 - BALL_SIZE.x / 2, SCREEN_HEIGHT / 2 - BALL_SIZE.y / 2);
    }

    fn generateRandomDirection() vec2 {
        var rnd = rndGen.init(@as(u64, @bitCast(std.time.milliTimestamp())));
        const random = rnd.random();

        var ballDirectionX: f32 = @floatFromInt(random.intRangeAtMost(i32, -1, 0));
        ballDirectionX = if (ballDirectionX == 0.0) ballDirectionX + 1 else ballDirectionX;

        var ballDirectionY: f32 = @floatFromInt(random.intRangeAtMost(i32, -1, 0));
        ballDirectionY = if (ballDirectionY == 0.0) ballDirectionY + 1 else ballDirectionY;
        return vec2.init(ballDirectionX, ballDirectionY);
    }

    pub fn init() Global {
        // setup ball:
        var ball = Ball.init2(BALL_SIZE);
        cententerBall(&ball);

        // setup player1:
        return Global{
            .ball = ball,
            .player1 = Player.init(vec2.init(PLAYER_XOFFSET, SCREEN_HEIGHT / 2 - PLAYER_SIZE.y / 2), PLAYER_SIZE),
            .player2 = Player.init(vec2.init(SCREEN_WIDTH - PLAYER_SIZE.x - PLAYER_XOFFSET, SCREEN_HEIGHT / 2 - PLAYER_SIZE.y / 2), PLAYER_SIZE),
            .ballDirection = generateRandomDirection(),
            .player1Score = 0,
            .player2Score = 0,
        };
    }

    pub fn update(this: *Global) void {
        this.ball.position =
            this.ball.position.add(this.ballDirection.scale(rl.getFrameTime() * 100.0));

        if (this.ball.position.y + this.ball.size.y >= Global.SCREEN_HEIGHT or this.ball.position.y < 0)
            this.ballDirection.y *= -1;

        if (this.ball.position.x + this.ball.size.x >= Global.SCREEN_WIDTH) {
            Global.cententerBall(&this.ball);
            this.ballDirection = generateRandomDirection();
            this.player1Score += 1;
        } else if (this.ball.position.x < 0) {
            Global.cententerBall(&this.ball);
            this.ballDirection = generateRandomDirection();
            this.player2Score += 1;
        }

        // TODO: normals???
        if (this.ball.position.x <= this.player1.position.x + PLAYER_SIZE.x and this.ball.position.x >= this.player1.position.x) {
            if (this.ball.position.y + BALL_SIZE.y >= this.player1.position.y and this.ball.position.y <= this.player1.position.y + PLAYER_SIZE.y / 2.0) {
                this.ballDirection = vec2.init(1, -1);
            } else if (this.ball.position.y + BALL_SIZE.y >= this.player1.position.y + PLAYER_SIZE.y / 2.0 and this.ball.position.y <= this.player1.position.y + PLAYER_SIZE.y) {
                this.ballDirection = vec2.init(1, 1);
            }
        }

        if (this.ball.position.x + BALL_SIZE.x >= this.player2.position.x and this.ball.position.x <= this.player2.position.x + PLAYER_SIZE.x) {
            if (this.ball.position.y + BALL_SIZE.y >= this.player2.position.y and this.ball.position.y <= this.player2.position.y + PLAYER_SIZE.y / 2.0) {
                this.ballDirection = vec2.init(-1, -1);
            } else if (this.ball.position.y + BALL_SIZE.y >= this.player2.position.y + PLAYER_SIZE.y / 2.0 and this.ball.position.y <= this.player2.position.y + PLAYER_SIZE.y) {
                this.ballDirection = vec2.init(-1, 1);
            }
        }
    }
};

pub fn main() !void {
    rl.initWindow(Global.SCREEN_WIDTH, Global.SCREEN_HEIGHT, "Test");
    defer rl.closeWindow();

    // set max fps
    //rl.setTargetFPS(60);

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

        global.update();

        const pos1X: i32 = @intFromFloat(global.player1.position.x);
        const pos2X: i32 = @intFromFloat(global.player2.position.x);
        rl.drawText(rl.textFormat("%i", .{global.player1Score}), pos1X, 20, 20, rl.Color.light_gray);
        rl.drawText(rl.textFormat("%i", .{global.player2Score}), pos2X, 20, 20, rl.Color.light_gray);
        global.ball.draw();
        global.player1.draw();
        global.player2.draw();
        //rl.drawText("This is some test text", 190, 200, 20, rl.Color.light_gray);
    }
}
