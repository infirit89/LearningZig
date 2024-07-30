const std = @import("std");
const rl = @import("raylib");
const p = @import("player.zig");
const b = @import("ball.zig");
const game = @import("game.zig");

// aliases:
const vec2 = rl.Vector2;
const rect = rl.Rectangle;
const Player = p.Player;
const Game = game.Game;
const Allocator = std.heap.c_allocator;

const BACKGROUND_COLOR = rl.Color.init(25, 25, 25, 255);

pub const Application = struct {
    frameTimeScaler: f32,
    screenWidth: i32,
    screenHeight: i32,
    gameScene: *Game,

    pub fn init(windowWidth: comptime_int, windowHeight: comptime_int, title: [*:0]const u8) Application {
        rl.initWindow(windowWidth, windowHeight, title);

        return Application{
            .frameTimeScaler = 0,
            .screenWidth = windowWidth,
            .screenHeight = windowHeight,
            .gameScene = undefined,
        };
    }

    pub fn shutdown(this: *const Application) void {
        this.gameScene.deinit(Allocator);
        rl.closeWindow();
    }

    fn createScenes(this: *Application) !void {
        this.gameScene = try Game.init(Allocator);
    }

    pub fn run(this: *Application) !void {
        try this.createScenes();
        while (!rl.windowShouldClose()) {
            rl.beginDrawing();
            defer rl.endDrawing();

            rl.clearBackground(BACKGROUND_COLOR);

            this.update();

            this.draw();
        }
    }

    fn update(this: *Application) void {
        this.frameTimeScaler = rl.getFrameTime() * 100.0;
        this.gameScene.update();
    }

    fn draw(this: *const Application) void {
        this.gameScene.draw();
    }
};
