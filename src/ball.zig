const std = @import("std");
const rl = @import("raylib");
const g = @import("globabls.zig");

const vec2 = rl.Vector2;
const rect = rl.Rectangle;
const rndGen = std.rand.DefaultPrng;

pub const Ball = struct {
    rectangle: rect,
    direction: vec2,

    pub fn init(rectangle: rect) Ball {
        return Ball{
            .rectangle = rectangle,
            .direction = generateRandomDirection(),
        };
    }

    pub fn draw(this: Ball) void {
        rl.drawRectangleRec(this.rectangle, rl.Color.white);
    }

    pub fn cententer(this: *Ball) void {
        const halfScreenWidth: f32 = @floatFromInt(
            @divTrunc(g.application.screenWidth, 2),
        );
        const halfScreenHeight: f32 = @floatFromInt(
            @divTrunc(g.application.screenHeight, 2),
        );
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
        ballPosition = ballPosition.add(
            this.direction.scale(g.application.frameTimeScaler),
        );
        this.rectangle.x = ballPosition.x;
        this.rectangle.y = ballPosition.y;

        const screenHeight: f32 = @floatFromInt(g.application.screenHeight);
        const screenWidth: f32 = @floatFromInt(g.application.screenWidth);
        if (this.rectangle.y + this.rectangle.height >= screenHeight) {
            this.direction.y *= -1;
            this.rectangle.y = screenHeight - this.rectangle.height;
        } else if (this.rectangle.y < 0) {
            this.direction.y *= -1;
            this.rectangle.y = 0;
        }

        if (this.rectangle.x + this.rectangle.width >= screenWidth) {
            this.cententer();
            this.direction = generateRandomDirection();
            g.application.gameScene.playerLScore += 1;
        } else if (this.rectangle.x < 0) {
            this.cententer();
            this.direction = generateRandomDirection();
            g.application.gameScene.playerRScore += 1;
        }
    }
};
