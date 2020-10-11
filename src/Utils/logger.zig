//Simple multi-platform logger
const std = @import("std");
const builtin = @import("builtin");

const io = std.io;
const os = std.os;
const fs = std.fs;
const time = @import("../Zig-PSP/src/psp/os/time.zig");

pub const Level = enum {
    const Self = @This();

    Trace,
    Debug,
    Info,
    Warn,
    Error,
    Fatal,

    fn toString(self: Self) []const u8 {
        return switch (self) {
            Level.Trace => "TRACE",
            Level.Debug => "DEBUG",
            Level.Info => "INFO",
            Level.Warn => "WARN",
            Level.Error => "ERROR",
            Level.Fatal => "FATAL",
        };
    }
};

var level: Level = Level.Trace;
var quiet: bool = false;

var file: fs.File = undefined;
var start : i64 = 0;

pub fn init() !void {
    start = time.milliTimestamp();
    file = try fs.cwd().createFile("./log.txt", fs.File.CreateFlags {.truncate = true});
}

pub fn deinit() void{
    file.close();
}

pub fn log(lv: Level, comptime fmt: []const u8, args: anytype) !void {
    if (@enumToInt(lv) < @enumToInt(level)) {
        return;
    }

    if(!quiet){
        try std.fmt.format(file.writer(), "[{}]", .{time.milliTimestamp() - start});
        try std.fmt.format(file.writer(), "[{}]", .{lv.toString()});
        try std.fmt.format(file.writer(), ": ", .{});
        try std.fmt.format(file.writer(), fmt, args);
        try std.fmt.format(file.writer(), "\n", .{});
    }
}

pub fn setLevel(lv: Level) void {
    level = lv;
}

pub fn trace(comptime fmt: []const u8, args: anytype) void {
    log(Level.Trace, fmt, args) catch return;
}
pub fn debug(comptime fmt: []const u8, args: anytype) void {
    log(Level.Debug, fmt, args) catch return;
}
pub fn info(comptime fmt: []const u8, args: anytype) void {
    log(Level.Info, fmt, args) catch return;
}
pub fn warn(comptime fmt: []const u8, args: anytype) void {
    log(Level.Warn, fmt, args) catch return;
}
pub fn err(comptime fmt: []const u8, args: anytype) void {
    log(Level.Error, fmt, args) catch return;
}
pub fn fatal(comptime fmt: []const u8, args: anytype) void {
    log(Level.Fatal, fmt, args) catch return;
}
