usingnamespace @import("../Zig-PSP/src/psp/include/pspgu.zig");
const psp = @import("../Zig-PSP/src/psp/utils/psp.zig");

var psp_allocator: ?*std.mem.Allocator = null;

const Self = @This();
init: bool = false,
maxFilter: i32 = 0,
minFilter: i32 = 0,
repeat: bool = true,

width: usize = 0, 
height: usize = 0,

pWidth: usize = 0,
pHeight: usize = 0,

swizzled: i32 = 0,
data: ?[]u8 align(16) = null,

const std = @import("std");

pub fn pow2(int: usize) usize{
    var p2 : usize = 1;

    while(p2 < int){
        p2 = p2 << 1;
    }
    return p2;
}

const utils = @import("../utils/utils.zig");
pub fn loadTex(self: *Self, path: []const u8, min: TextureFilter, mag: TextureFilter, repeat: bool) !void {
    @setRuntimeSafety(false);
    self.init = true;
    self.minFilter = @enumToInt(min);
    self.maxFilter = @enumToInt(mag);
    self.repeat = repeat;

    var fs = try std.fs.cwd().openFile(path, .{.read = true});
    var size = try fs.getEndPos();

    if(psp_allocator == null){
        psp_allocator = &psp.PSPAllocator.init().allocator;
    }

    //Set data from file

    //self.pWidth = pow2(self.width);
    //self.pHeight = pow2(self.height);
}

pub fn deleteTex(self: *Self) void {
    self.init = false;
}

pub fn bind(self: *Self) void {
    @setRuntimeSafety(false);
    if(self.init){
        sceGuEnable(GuState.Texture2D);

        sceGuTexMode(GuPixelMode.Psm8888, 0, 0, self.swizzled);
        sceGuTexFunc(TextureEffect.Modulate, TextureColorComponent.Rgba);
        sceGuTexFilter(@intToEnum(TextureFilter, self.minFilter), @intToEnum(TextureFilter, self.maxFilter));
        sceGuTexOffset(0.0, 0.0);
        if(self.repeat){
            sceGuTexWrap(GuTexWrapMode.Repeat, GuTexWrapMode.Repeat);
        }else{
            sceGuTexWrap(GuTexWrapMode.Clamp, GuTexWrapMode.Clamp);
        }

        if(self.data != null){
            sceGuTexImage(0, @intCast(c_int, self.pWidth), @intCast(c_int, self.pHeight), @intCast(c_int, self.pWidth), @ptrCast(*c_void, &self.data.?));
        }
    }
}
