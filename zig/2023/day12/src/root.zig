const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Point = struct {
    row: usize,
    col: usize,
};

fn sumDistances(input: []const u8, expansion_factor: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("Leak!");
    const allocator = gpa.allocator();

    var cols_not_empty = std.AutoHashMap(usize, void).init(allocator);
    defer cols_not_empty.deinit();
    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();
    var expand_rows_amount: usize = 0;
    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;
    var num_cols: usize = 0;
    while (lines_it.next()) |line| : (i += 1) {
        var no_galaxies = true;
        for (line, 0..) |ch, col| {
            num_cols = @max(num_cols, col);
            if (ch != '#') continue;
            no_galaxies = false;
            try points.append(.{ .row = i + expand_rows_amount, .col = col });
            try cols_not_empty.put(col, {});
        }
        if (no_galaxies) expand_rows_amount += expansion_factor - 1;
    }
    num_cols += 1;

    // Expand empty columns by pushing all points to their right further to the right.
    // Iterating in reverse is necessary,
    // otherwise, we'd moved points through other expanded columns,
    // and end up moving them more than we should.
    var col = num_cols;
    while (col > 0) {
        col -= 1;
        if (cols_not_empty.contains(col)) continue;
        for (points.items) |*point| {
            if (point.col > col) point.col += expansion_factor - 1;
        }
    }

    var sum: usize = 0;
    for (points.items[0 .. points.items.len - 1], 0..) |point1, j| {
        for (points.items[j + 1 ..]) |point2| {
            sum += @max(point2.row, point1.row) - @min(point2.row, point1.row);
            sum += @max(point2.col, point1.col) - @min(point2.col, point1.col);
        }
    }

    return sum;
}

fn part1(input: []const u8) !usize {
    return sumDistances(input, 2);
}

fn part2(input: []const u8) !usize {
    return sumDistances(input, 1000000);
}

fn getAnswer(comptime part: comptime_int) ![]const u8 {
    if (part != 1 and part != 2) @compileError("part must be either 1 or 2");
    const answer_text = @embedFile(std.fmt.comptimePrint("part{d}answer.txt", .{part}));
    return std.mem.trimRight(u8, answer_text, " \t\n");
}

test "part 1 sample input" {
    const input =
        \\...#......
        \\.......#..
        \\#.........
        \\..........
        \\......#...
        \\.#........
        \\.........#
        \\..........
        \\.......#..
        \\#...#.....
    ;
    const answer: usize = 374;
    const got = try part1(input);
    try expectEqual(answer, got);
}

test "part 1 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(usize, try getAnswer(1), 10);
    const got = try part1(input);
    try expectEqual(answer, got);
}

test "part 2 sample input" {
    const input =
        \\...#......
        \\.......#..
        \\#.........
        \\..........
        \\......#...
        \\.#........
        \\.........#
        \\..........
        \\.......#..
        \\#...#.....
    ;
    var answer: usize = 1030;
    var got = try sumDistances(input, 10);
    try expectEqual(answer, got);
    answer = 8410;
    got = try sumDistances(input, 100);
    try expectEqual(answer, got);
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(usize, try getAnswer(2), 10);
    const got = try part2(input);
    try expectEqual(answer, got);
}
