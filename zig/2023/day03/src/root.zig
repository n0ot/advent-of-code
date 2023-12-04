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

fn part2(input: []const u8) !u32 {
    var lines_iter = std.mem.tokenizeScalar(u8, input, '\n');
    var prev_line: ?[]const u8 = null;
    var sum: u32 = 0;
    while (lines_iter.next()) |line| : (prev_line = line) {
        const next_line = lines_iter.peek();
        for (line, 0..) |ch, i| {
            if (ch != '*') continue;
            var number_count = NumberCount{};

            // See if this "geer" is touching exactly two numbers (diagonals included).
            const left_right = numberCountLeftRight(line, i, false);
            number_count.count += left_right.count;
            number_count.product *= left_right.product;
            // Look above.
            if (prev_line) |l| {
                const above = numberCountLeftRight(l, i, true);
                number_count.count += above.count;
                number_count.product *= above.product;
            }
            // Look below.
            if (next_line) |l| {
                const below = numberCountLeftRight(l, i, true);
                number_count.count += below.count;
                number_count.product *= below.product;
            }

            if (number_count.count == 2) sum += number_count.product;
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

// Finds the beginning and end of a run of digits,
// and returns it as an integer.
// Returns null if pos doesn't refer to a digit.
fn wholeNumber(s: []const u8, pos: usize) ?u32 {
    if (pos >= s.len) return null;
    switch (s[pos]) {
        '0'...'9' => {},
        else => return null,
    }

    var start = pos;
    while (start > 0 and s[start - 1] >= '0' and s[start - 1] <= '9') : (start -= 1) {}
    var parser = std.fmt.Parser{ .buf = s, .pos = start };
    return @intCast(parser.number() orelse unreachable);
}

const NumberCount = struct {
    count: usize = 0,
    product: u32 = 1,
};

// Searches around a character,
// returning a partial NumberCount indicating the count and product of any found numbers.
// If includePos is true,
// the character at s[pos] will also be tested.
// includePos should be false when searching the line containing the target character,
// true otherwise.
fn numberCountLeftRight(s: []const u8, pos: usize, includePos: bool) NumberCount {
    var number_count = NumberCount{};

    if (includePos) {
        if (wholeNumber(s, pos)) |num| {
            number_count.count = 1;
            number_count.product = num;
            // Since this character is a digit,
            // if the characters to either side are also digits,
            // they will be a part of the same number,
            // so we shouldn't check them, and count this number more than once.
            return number_count;
        }
    }

    // Look left.
    if (pos > 0) {
        if (wholeNumber(s, pos - 1)) |num| {
            number_count.count += 1;
            number_count.product *= num;
        }
    }

    // Look right.
    if (pos < s.len - 1) {
        if (wholeNumber(s, pos + 1)) |num| {
            number_count.count += 1;
            number_count.product *= num;
        }
    }

    return number_count;
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

test "part 2 sample input" {
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
    const answer = @as(u32, 467835);
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(u32, try getAnswer(2), 10);
    const got = try part2(input);
    try expectEqual(answer, got);
}
