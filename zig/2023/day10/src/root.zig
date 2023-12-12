const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Point = struct {
    row: usize,
    col: usize,

    const Self = @This();

    pub fn moved(self: Self, direction: Direction, last: Point) ?Self {
        return switch (direction) {
            .north => if (self.row > 0) .{ .row = self.row - 1, .col = self.col } else null,
            .east => if (self.col < last.col) .{ .row = self.row, .col = self.col + 1 } else null,
            .south => if (self.row < last.row) .{ .row = self.row + 1, .col = self.col } else null,
            .west => if (self.col > 0) .{ .row = self.row, .col = self.col - 1 } else null,
        };
    }
};

const Direction = enum {
    north,
    east,
    south,
    west,
};

fn findAnimal(ground: [][]const u8, start_pos: Point, start_direction: Direction, comptime foundVertex: fn (ground: [][]const u8, point: Point) void) !?usize {
    var pos = start_pos;
    var direction = start_direction;
    const last = Point{ .row = ground.len - 1, .col = ground[0].len - 1 };
    var i: usize = 0;
    while (ground[pos.row][pos.col] != 'S') : (i += 1) {
        pos = switch (ground[pos.row][pos.col]) {
            '|' => switch (direction) {
                .north, .south => pos.moved(direction, last) orelse return null,
                else => return null,
            },
            '-' => switch (direction) {
                .east, .west => pos.moved(direction, last) orelse return null,
                else => return null,
            },
            'L' => switch (direction) {
                .south => blk: {
                    foundVertex(ground, pos);
                    direction = .east;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                .west => blk: {
                    foundVertex(ground, pos);
                    direction = .north;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                else => return null,
            },
            'J' => switch (direction) {
                .south => blk: {
                    foundVertex(ground, pos);
                    direction = .west;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                .east => blk: {
                    foundVertex(ground, pos);
                    direction = .north;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                else => return null,
            },
            '7' => switch (direction) {
                .north => blk: {
                    foundVertex(ground, pos);
                    direction = .west;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                .east => blk: {
                    foundVertex(ground, pos);
                    direction = .south;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                else => return null,
            },
            'F' => switch (direction) {
                .north => blk: {
                    foundVertex(ground, pos);
                    direction = .east;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                .west => blk: {
                    foundVertex(ground, pos);
                    direction = .south;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                else => return null,
            },
            'S' => blk: {
                foundVertex(ground, pos); // S may not actually be a vertex, but that's okay
                break :blk pos;
            },
            '.' => return null,
            else => return error.InvalidTile,
        };
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

    const foundVertex = (struct {
        pub fn foundVertex(_: [][]const u8, _: Point) void {}
    }).foundVertex;

    if (s_pos.?.row > 0) {
        if (try findAnimal(lines.items, .{ .row = s_pos.?.row - 1, .col = s_pos.?.col }, .north, foundVertex)) |steps| return (steps + 1) / 2;
    }
    if (s_pos.?.row < lines.items.len - 1) {
        if (try findAnimal(lines.items, .{ .row = s_pos.?.row + 1, .col = s_pos.?.col }, .south, foundVertex)) |steps| return (steps + 1) / 2;
    }
    if (s_pos.?.col > 0) {
        if (try findAnimal(lines.items, .{ .row = s_pos.?.row, .col = s_pos.?.col - 1 }, .west, foundVertex)) |steps| return (steps + 1) / 2;
    }
    if (s_pos.?.col < lines.items[0].len - 1) {
        if (try findAnimal(lines.items, .{ .row = s_pos.?.row, .col = s_pos.?.col + 1 }, .east, foundVertex)) |steps| return (steps + 1) / 2;
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
