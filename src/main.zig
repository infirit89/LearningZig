const std = @import("std");
const app = @import("application.zig");
const g = @import("globabls.zig");

pub fn main() !void {
    // set max fps
    //rl.setTargetFPS(60);
    g.application = app.Application.init(g.SCREEN_WIDTH, g.SCREEN_HEIGHT, "Pong");
    defer app.Application.shutdown();
    g.application.run();
}
