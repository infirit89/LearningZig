const std = @import("std");
const rl = @import("raylib");
const p = @import("player.zig");
const b = @import("ball.zig");
const g = @import("globabls.zig");

// aliases:
const Player = p.Player;
const vec2 = rl.Vector2;
const rect = rl.Rectangle;
const Ball = b.Ball;
const rndGen = std.rand.DefaultPrng;

pub const Game = struct {
    playerL: Player,
    playerR: Player,
    playerLScore: u32,
    playerRScore: u32,
    ball: Ball,
    ended: bool,
    collision: rect,
    const PLAYER_XOFFSET = 20.0;
    const BALL_SIZE = vec2.init(20.0, 20.0);
    const PLAYER_SIZE: vec2 = vec2.init(20.0, 60.0);

    pub fn init(allocator: std.mem.Allocator) !*Game {
        const app = g.application;
        const halfScreenHeight: f32 = @floatFromInt(@divTrunc(app.screenHeight, 2));
        const screenWidthF: f32 = @floatFromInt(app.screenWidth);

        // setup ball:
        var ball = Ball.init(.{ .x = 0, .y = 0, .width = BALL_SIZE.x, .height = BALL_SIZE.y });
        ball.cententer();

        // setup player1:
        const player1Controlls = .{ .up = .key_w, .down = .key_s };
        const playerY = halfScreenHeight - PLAYER_SIZE.y / 2;
        const player1Rect = .{ .x = PLAYER_XOFFSET, .y = playerY, .width = PLAYER_SIZE.x, .height = PLAYER_SIZE.y };

        // setup player2:
        const player2Controlls = .{ .up = .key_up, .down = .key_down };
        const player2X = screenWidthF - PLAYER_SIZE.x - PLAYER_XOFFSET;
        const player2Rect = .{ .x = player2X, .y = playerY, .width = PLAYER_SIZE.x, .height = PLAYER_SIZE.y };

        const gamePtr = try allocator.create(Game);
        errdefer allocator.destroy(gamePtr);

        gamePtr.playerL = Player.init(player1Rect, player1Controlls);
        gamePtr.playerR = Player.init(player2Rect, player2Controlls);
        gamePtr.playerLScore = 0;
        gamePtr.playerRScore = 0;
        gamePtr.ball = ball;
        gamePtr.ended = false;
        gamePtr.collision = undefined;
        return gamePtr;
    }

    pub fn deinit(self: *Game, allocator: std.mem.Allocator) void {
        allocator.destroy(self);
    }

    pub fn update(self: *Game) void {
        if (!self.ended) {
            self.playerL.update();
            self.playerR.update();

            self.ball.update();
            self.ended = self.playerRScore >= 10 or self.playerLScore >= 10;

            var rnd = rndGen.init(@as(u64, @bitCast(std.time.milliTimestamp())));
            const random = rnd.random();
            if (self.ball.rectangle.checkCollision(self.playerL.rectangle)) {
                const speedX: f32 =
                    @floatFromInt(random.intRangeAtMost(i32, 2, 4));
                const speedY: f32 =
                    @floatFromInt(random.intRangeAtMost(i32, -4, -2));
                self.ball.direction =
                    vec2.init((self.playerL.velocity + 1) * speedX, -speedY * (1 + self.playerL.velocity));
            } else if (self.ball.rectangle.checkCollision(self.playerR.rectangle)) {
                const speedY: f32 =
                    @floatFromInt(random.intRangeAtMost(i32, 1, 3));
                const speedX: f32 =
                    @floatFromInt(random.intRangeAtMost(i32, -3, -1));

                self.ball.direction =
                    vec2.init((self.playerR.velocity + 1) * speedX, -speedY * (1 + self.playerR.velocity));
            }
            return;
        }

        if (rl.isKeyPressed(.key_enter)) {
            self.ended = false;
            self.ball.cententer();
            self.playerLScore = 0;
            self.playerRScore = 0;
        }
    }

    pub fn draw(self: *const Game) void {
        const fontSize = 20;
        const textColor = rl.Color.light_gray;
        if (!self.ended) {
            const textXOffset = 20;
            const pos1X: i32 = @intFromFloat(self.playerL.rectangle.x);
            const pos2X: i32 = @intFromFloat(self.playerR.rectangle.x);

            const playerLScoreStr = rl.textFormat("%i", .{self.playerLScore});
            rl.drawText(playerLScoreStr, pos1X, textXOffset, fontSize, textColor);
            const playerRScoreStr = rl.textFormat("%i", .{self.playerRScore});
            rl.drawText(playerRScoreStr, pos2X, textXOffset, fontSize, textColor);

            self.ball.draw();
            self.playerL.draw();
            self.playerR.draw();
            rl.drawRectangleRec(self.collision, rl.Color.green);
            return;
        }

        const restartText = "Press enter to restart";
        const textWidth = @divFloor(rl.measureText(restartText, fontSize), 2);
        const halfScreenWidth = @divFloor(g.application.screenWidth, 2);
        const halfScreenHeight = @divFloor(g.application.screenHeight, 2);
        rl.drawText(restartText, halfScreenWidth - textWidth, halfScreenHeight - fontSize / 2, fontSize, textColor);
    }
};
