const std = @import("std");
const psp = @import("Zig-PSP/src/psp/utils/psp.zig");
const time = @import("Zig-PSP/src/psp/os/time.zig");
usingnamespace @import("Zig-PSP/src/psp/include/psploadexec.zig");
const engine = @import("engine");
const utils = engine.utils;
const gfx = engine.gfx;

//STD Overrides!
pub const panic = @import("Zig-PSP/src/psp/utils/debug.zig").panic;
pub const os = @import("Zig-PSP/src/psp/pspos.zig");


comptime {
    asm(psp.module_info("Zig PSP", 0, 1, 0));
}


pub fn main() !void {
    psp.utils.enableHBCB();
    psp.debug.screenInit();

    try utils.log.init();
    defer utils.log.deinit();

    gfx.renderer.init();
    gfx.renderer.setClearColor(255, 0, 255, 255);
    gfx.renderer.set2D();
    defer gfx.renderer.deinit();

    utils.log.info("Hello there", .{});

    while(true) {
        gfx.renderer.recordCommands();
        gfx.renderer.clear();

        gfx.renderer.submitCommands();
    }
}
