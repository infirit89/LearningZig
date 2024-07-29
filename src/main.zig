const std = @import("std");
const rl = @import("raylib");

// aliases:
const vec2 = rl.Vector2;
const rect = rl.Rectangle;
const rndGen = std.rand.DefaultPrng;

const BACKGROUND_COLOR = rl.Color.init(25, 25, 25, 255);
const SCREEN_WIDTH = 600;
const SCREEN_HEIGHT = 360;

var application: Application = undefined;
const Ball = struct {
    rectangle: rect,
    direction: vec2,

    pub fn init(rectangle: rect) Ball {
        var ball = Ball{ .rectangle = rectangle, .direction = generateRandomDirection() };
        ball.cententer();
        return ball;
    }

    pub fn draw(this: Ball) void {
        rl.drawRectangleRec(this.rectangle, rl.Color.white);
    }

    fn cententer(this: *Ball) void {
        const halfScreenWidth: f32 = @floatFromInt(@divTrunc(application.screenWidth, 2));
        const halfScreenHeight: f32 = @floatFromInt(@divTrunc(application.screenHeight, 2));
        this.rectangle.x = halfScreenWidth - this.rectangle.width / 2;
        this.rectangle.y = halfScreenHeight - this.rectangle.height / 2;
    }

    fn generateRandomDirection() vec2 {
        var rnd = rndGen.init(@as(u64, @bitCast(std.time.milliTimestamp())));
        const random = rnd.random();

        var ballDirectionX: f32 =
            @floatFromInt(random.intRangeAtMost(i32, -1, 0));
        ballDirectionX =
            if (ballDirectionX == 0.0) ballDirectionX + 1 else ballDirectionX;

        var ballDirectionY: f32 =
            @floatFromInt(random.intRangeAtMost(i32, -1, 0));
        ballDirectionY =
            if (ballDirectionY == 0.0) ballDirectionY + 1 else ballDirectionY;
        return vec2.init(ballDirectionX, ballDirectionY);
    }

    pub fn update(this: *Ball) void {
        var ballPosition = vec2.init(this.rectangle.x, this.rectangle.y);
        ballPosition = ballPosition.add(this.direction.scale(application.frameTimeScaler));
        this.rectangle.x = ballPosition.x;
        this.rectangle.y = ballPosition.y;

        const screenHeight: f32 = @floatFromInt(application.screenHeight);
        const screenWidth: f32 = @floatFromInt(application.screenWidth);
        if (this.rectangle.y + this.rectangle.height >= screenHeight or
            this.rectangle.y < 0)
            this.direction.y *= -1;

        if (this.rectangle.x + this.rectangle.width >= screenWidth) {
            this.cententer();
            this.direction = generateRandomDirection();
            application.player1Score += 1;
        } else if (this.rectangle.x < 0) {
            this.cententer();
            this.direction = generateRandomDirection();
            application.player2Score += 1;
        }
    }
};
const Player = struct {
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
            this.rectangle.y -= 1.0 * application.frameTimeScaler;
        } else if (rl.isKeyDown(this.controlls.down)) {
            this.rectangle.y += 1.0 * application.frameTimeScaler;
        }
    }
};

// setup:
const Application = struct {
    ball: Ball,
    player1: Player,
    player2: Player,
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

        // setup ball:
        const ball = Ball.init(.{ .x = 0, .y = 0, .width = BALL_SIZE.x, .height = BALL_SIZE.y });

        // setup player1:
        const player1Controlls = .{ .up = .key_w, .down = .key_s };
        const playerY = windowHeight / 2 - PLAYER_SIZE.y / 2;
        const player1Rect = .{ .x = PLAYER_XOFFSET, .y = playerY, .width = PLAYER_SIZE.x, .height = PLAYER_SIZE.y };
        const player1 =
            Player.init(player1Rect, player1Controlls);

        const player2Controlls = .{ .up = .key_up, .down = .key_down };
        const player2X = windowWidth - PLAYER_SIZE.x - PLAYER_XOFFSET;
        const player2Rect = .{ .x = player2X, .y = playerY, .width = PLAYER_SIZE.x, .height = PLAYER_SIZE.y };
        const player2 =
            Player.init(player2Rect, player2Controlls);

        return Application{
            .ball = ball,
            .player1 = player1,
            .player2 = player2,
            .player1Score = 0,
            .player2Score = 0,
            .frameTimeScaler = 0,
            .screenWidth = windowWidth,
            .screenHeight = windowHeight,
        };
    }
    pub fn shutdown() void {
        rl.closeWindow();
    }

    pub fn run(this: *Application) void {
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

pub fn main() !void {
    // set max fps
    //rl.setTargetFPS(60);
    application = Application.init(SCREEN_WIDTH, SCREEN_HEIGHT, "Pong");
    defer Application.shutdown();
    application.run();
}
