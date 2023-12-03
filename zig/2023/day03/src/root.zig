const std = @import("std");
const expectEqual = std.testing.expectEqual;

const digits = "0123456789";

fn part1(input: []const u8) !u32 {
    var lines_iter = std.mem.tokenizeScalar(u8, input, '\n');
    var prev_line: ?[]const u8 = null;
    var sum: u32 = 0;
    while (lines_iter.next()) |line| : (prev_line = line) {
        const next_line = lines_iter.peek();
        var parser = std.fmt.Parser{ .buf = line };
        // Find all the numbers on this line.
        while (std.mem.indexOfAnyPos(u8, parser.buf, parser.pos, digits)) |pos| {
            parser.pos = pos;
            const number: u32 = @intCast(parser.number().?);
            // This number should be included if it's adjacent to
            // (including diagonally) a part (marked with a `*`).
            // Try to the left.
            if (pos > 0 and foundSymbol(line[pos - 1 .. pos])) {
                sum += number;
                continue;
            }
            // Try to the right.
            if (parser.pos < line.len and foundSymbol(line[parser.pos .. parser.pos + 1])) {
                sum += number;
                continue;
            }
            // Try above and below (including diagonally).
            const start = if (pos > 0) pos - 1 else 0;
            const end = @min(parser.buf.len, parser.pos + 1);
            if (prev_line) |l| {
                if (foundSymbol(l[start..end])) {
                    sum += number;
                    continue;
                }
            }
            if (next_line) |l| {
                if (foundSymbol(l[start..end])) {
                    sum += number;
                    continue;
                }
            }
        }
    }

    return sum;
}

/// Returns true if the slice contains a symbol (anything other than '0' - '9', and '.'.
fn foundSymbol(slice: []const u8) bool {
    if (slice.len == 0) return false;
    for (slice) |c| {
        switch (c) {
            '0'...'9', '.' => {}, // Not a symbol
            else => return true,
        }
    }
    return false;
}

fn getAnswer(comptime part: comptime_int) ![]const u8 {
    if (part != 1 and part != 2) @compileError("part must be either 1 or 2");
    const answer_text = @embedFile(std.fmt.comptimePrint("part{d}answer.txt", .{part}));
    return std.mem.trimRight(u8, answer_text, " \t\n");
}

test "part 1 sample input" {
    const input =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
    ;
    const answer = @as(u32, 4361);
    const got = try part1(input);
    try expectEqual(answer, got);
}

test "part 1 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(u32, try getAnswer(1), 10);
    const got = try part1(input);
    try expectEqual(answer, got);
}
