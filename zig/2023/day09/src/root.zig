const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Direction = enum {
    left,
    right,
};

fn nextNum(allocator: std.mem.Allocator, nums: []isize, direction: Direction) !isize {
    if (nums.len == 0) return 0;
    if (nums.len == 1) return nums[0];

    var new_sequence = std.ArrayList(isize).init(allocator);
    defer new_sequence.deinit();
    var all_zeros = true;
    var i: usize = 1;
    while (i < nums.len) : (i += 1) {
        var diff: isize = nums[i] - nums[i - 1];
        if (diff != 0) all_zeros = false;
        if (direction == .left) diff *= -1;
        try new_sequence.append(diff);
    }

    const idx = switch (direction) {
        .left => 0,
        .right => nums.len - 1,
    };
    if (all_zeros) return nums[idx];
    return nums[idx] + try nextNum(allocator, new_sequence.items, direction);
}

fn sumNext(input: []const u8, direction: Direction) !isize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("Leak!");
    const allocator = gpa.allocator();

    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: isize = 0;
    while (lines_it.next()) |line| {
        var nums_it = std.mem.tokenizeScalar(u8, line, ' ');
        var nums = std.ArrayList(isize).init(allocator);
        defer nums.deinit();
        while (nums_it.next()) |num| try nums.append(try std.fmt.parseInt(isize, num, 10));
        sum += try nextNum(allocator, nums.items, direction);
    }

    return sum;
}

fn part1(input: []const u8) !isize {
    return try sumNext(input, Direction.right);
}

fn part2(input: []const u8) !isize {
    return try sumNext(input, Direction.left);
}

fn getAnswer(comptime part: comptime_int) ![]const u8 {
    if (part != 1 and part != 2) @compileError("part must be either 1 or 2");
    const answer_text = @embedFile(std.fmt.comptimePrint("part{d}answer.txt", .{part}));
    return std.mem.trimRight(u8, answer_text, " \t\n");
}

test "part 1 sample 1 input" {
    const input =
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
    ;
    const answer: isize = 114;
    const got = try part1(input);
    try expectEqual(answer, got);
}

test "part 1 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(isize, try getAnswer(1), 10);
    const got = try part1(input);
    try expectEqual(answer, got);
}

test "part 2 sample input" {
    const input =
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
    ;
    const answer: isize = 2;
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(isize, try getAnswer(2), 10);
    const got = try part2(input);
    try expectEqual(answer, got);
}
