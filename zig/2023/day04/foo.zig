const std = @import("std");

pub fn main() void {
    const s = "Hello";
    std.debug.print("{s}\n", .{@typeName(@TypeOf(s))});
}
