const std = @import("std");
const expectEqual = std.testing.expectEqual;

fn part1(input: []const u8) u32 {
    var lines_iter = std.mem.splitScalar(u8, input, '\n');
    var sum: u32 = 0;
    while (lines_iter.next()) |line| {
        if (line.len == 0) continue;
        var digit1: ?u8 = null;
        var digit2: ?u8 = null;
        for (line) |chr| {
            switch (chr) {
                '0'...'9' => {
                    if (digit1 == null) digit1 = chr - '0';
                    digit2 = chr - '0';
                },
                else => {},
            }
        }
        if (digit1 == null or digit2 == null) continue;
        sum += 10 * digit1.? + digit2.?;
    }

    return sum;
}

fn part2(input: []const u8) u32 {
    const numbers = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    var lines_iter = std.mem.splitScalar(u8, input, '\n');
    var sum: u32 = 0;
    while (lines_iter.next()) |line| {
        if (line.len == 0) continue;
        var digit1: ?u32 = null;
        var digit2: ?u32 = null;
        // digits can overlap.
        // `3eightwo` becomes `32`, not `38`.
        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            const digit: ?u32 = blk: for (numbers, 0..) |word, number| {
                if (line[i] == number + '0') {
                    break :blk @intCast(number);
                } else if (std.mem.eql(u8, line[i..@min(line.len, i + word.len)], word)) {
                    break :blk @intCast(number);
                }
            } else break :blk null;
            if (digit == null) continue;
            if (digit1 == null) digit1 = digit;
            digit2 = digit;
        }
        if (digit1 == null or digit2 == null) continue;
        sum += 10 * digit1.? + digit2.?;
    }

    return sum;
}

fn getAnswer(comptime part: comptime_int) ![]const u8 {
    if (part != 1 and part != 2) @compileError("part must be either 1 or 2");
    const answer_text = @embedFile(std.fmt.comptimePrint("part{d}answer.txt", .{part}));
    return std.mem.trimRight(u8, answer_text, " \t\n");
}

test "part 1 sample input" {
    const input =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
    ;
    try expectEqual(@as(u32, 142), part1(input));
}

test "part 1 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(u32, try getAnswer(1), 10);
    try expectEqual(answer, part1(input));
}

test "part 2 sample input" {
    const input =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;
    try expectEqual(@as(u32, 281), part2(input));
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(u32, try getAnswer(2), 10);
    try expectEqual(answer, part2(input));
}
