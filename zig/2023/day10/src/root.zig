const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Point = struct {
    row: usize,
    col: usize,
};

const Direction = enum {
    north,
    east,
    south,
    west,
};

fn findAnimal(ground: [][]const u8, start_pos: Point, start_direction: Direction) !?usize {
    var pos = start_pos;
    var direction = start_direction;
    var i: usize = 0;
    while (ground[pos.row][pos.col] != 'S') : (i += 1) {
        var row: isize = @intCast(pos.row);
        var col: isize = @intCast(pos.col);

        switch (ground[pos.row][pos.col]) {
            '|' => switch (direction) {
                .north => row -= 1,
                .south => row += 1,
                else => return null,
            },
            '-' => switch (direction) {
                .west => col -= 1,
                .east => col += 1,
                else => return null,
            },
            'L' => switch (direction) {
                .south => {
                    direction = .east;
                    col += 1;
                },
                .west => {
                    direction = .north;
                    row -= 1;
                },
                else => return null,
            },
            'J' => switch (direction) {
                .south => {
                    direction = .west;
                    col -= 1;
                },
                .east => {
                    direction = .north;
                    row -= 1;
                },
                else => return null,
            },
            '7' => switch (direction) {
                .north => {
                    direction = .west;
                    col -= 1;
                },
                .east => {
                    direction = .south;
                    row += 1;
                },
                else => return null,
            },
            'F' => switch (direction) {
                .north => {
                    direction = .east;
                    col += 1;
                },
                .west => {
                    direction = .south;
                    row += 1;
                },
                else => return null,
            },
            'S' => {}, // Next iteration will break
            '.' => return null,
            else => return error.InvalidTile,
        }

        if (row < 0 or row >= ground.len or col < 0 or col >= ground[0].len) return null;
        pos = .{ .row = @intCast(row), .col = @intCast(col) };
    }

    return i;
}

fn part1(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("Leak!");
    const allocator = gpa.allocator();
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();
    var s_pos: ?Point = null;
    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;
    while (lines_it.next()) |line| : (i += 1) {
        try lines.append(line);
        if (std.mem.indexOfScalar(u8, line, 'S')) |j| s_pos = .{ .row = i, .col = j };
    }
    if (s_pos == null) return error.NoAnimalFound;

    if (s_pos.?.row > 0) {
        if (try findAnimal(lines.items, .{ .row = s_pos.?.row - 1, .col = s_pos.?.col }, .north)) |steps| return (steps + 1) / 2;
    }
    if (s_pos.?.row < lines.items.len - 1) {
        if (try findAnimal(lines.items, .{ .row = s_pos.?.row + 1, .col = s_pos.?.col }, .south)) |steps| return (steps + 1) / 2;
    }
    if (s_pos.?.col > 0) {
        if (try findAnimal(lines.items, .{ .row = s_pos.?.row, .col = s_pos.?.col - 1 }, .west)) |steps| return (steps + 1) / 2;
    }
    if (s_pos.?.col < lines.items[0].len - 1) {
        if (try findAnimal(lines.items, .{ .row = s_pos.?.row, .col = s_pos.?.col + 1 }, .east)) |steps| return (steps + 1) / 2;
    }

    return error.AnimalNotNearAPipe;
}

fn getAnswer(comptime part: comptime_int) ![]const u8 {
    if (part != 1 and part != 2) @compileError("part must be either 1 or 2");
    const answer_text = @embedFile(std.fmt.comptimePrint("part{d}answer.txt", .{part}));
    return std.mem.trimRight(u8, answer_text, " \t\n");
}

test "part 1 sample 1 input" {
    const input =
        \\.....
        \\.S-7.
        \\.|.|.
        \\.L-J.
        \\.....
    ;
    const answer: usize = 4;
    const got = try part1(input);
    try expectEqual(answer, got);
}

test "part 1 sample 2 input" {
    const input =
        \\..F7.
        \\.FJ|.
        \\SJ.L7
        \\|F--J
        \\LJ...
    ;
    const answer: usize = 8;
    const got = try part1(input);
    try expectEqual(answer, got);
}

test "part 1 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(usize, try getAnswer(1), 10);
    const got = try part1(input);
    try expectEqual(answer, got);
}

//test "part 2 sample input" {
//    const input =
//        \\0 3 6 9 12 15
//        \\1 3 6 10 15 21
//        \\10 13 16 21 30 45
//    ;
//    const answer: usize = 2;
//    const got = try part2(input);
//    try expectEqual(answer, got);
//}
//
//test "part 2 puzzle input" {
//    const input = @embedFile("input.txt");
//    const answer = try std.fmt.parseInt(usize, try getAnswer(2), 10);
//    const got = try part2(input);
//    try expectEqual(answer, got);
//}
