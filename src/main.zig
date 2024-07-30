const std = @import("std");
const app = @import("application.zig");
const Application = app.Application;
const g = @import("globabls.zig");

pub fn main() !void {
    // set max fps
    //rl.setTargetFPS(60);
    g.application = Application.init(g.SCREEN_WIDTH, g.SCREEN_HEIGHT, "Pong");
    defer g.application.shutdown();
    try g.application.run();
}
