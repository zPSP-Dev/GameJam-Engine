const std = @import("std");
const psp = @import("Zig-PSP/src/psp/utils/psp.zig");
const log = @import("Utils/logger.zig");
const time = @import("Zig-PSP/src/psp/os/time.zig");
usingnamespace @import("Zig-PSP/src/psp/include/psploadexec.zig");

//STD Overrides!
pub const panic = @import("Zig-PSP/src/psp/utils/debug.zig").panic;
pub const os = @import("Zig-PSP/src/psp/pspos.zig");


comptime {
    asm(psp.module_info("Zig PSP", 0, 1, 0));
}


pub fn main() !void {
    psp.utils.enableHBCB();
    psp.debug.screenInit();

    try log.init();
    defer log.deinit();

    log.info("Hello there", .{});

    //sceKernelExitGame();
}
