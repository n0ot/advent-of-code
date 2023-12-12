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

fn findAnimal(ground: [][]const u8, start_pos: Point, start_direction: Direction, found_vertices: *std.ArrayList(Point)) !?usize {
    found_vertices.clearRetainingCapacity();
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
                    try found_vertices.append(pos);
                    direction = .east;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                .west => blk: {
                    try found_vertices.append(pos);
                    direction = .north;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                else => return null,
            },
            'J' => switch (direction) {
                .south => blk: {
                    try found_vertices.append(pos);
                    direction = .west;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                .east => blk: {
                    try found_vertices.append(pos);
                    direction = .north;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                else => return null,
            },
            '7' => switch (direction) {
                .north => blk: {
                    try found_vertices.append(pos);
                    direction = .west;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                .east => blk: {
                    try found_vertices.append(pos);
                    direction = .south;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                else => return null,
            },
            'F' => switch (direction) {
                .north => blk: {
                    try found_vertices.append(pos);
                    direction = .east;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                .west => blk: {
                    try found_vertices.append(pos);
                    direction = .south;
                    break :blk pos.moved(direction, last) orelse return null;
                },
                else => return null,
            },
            '.' => return null,
            else => return error.InvalidTile,
        };
    }

    // `pos` is on the animal (`S` tile).
    try found_vertices.append(pos);
    return i;
}

fn findLoop(ground: [][]const u8, point: Point, found_vertices: *std.ArrayList(Point)) !usize {
    const last = Point{ .row = ground.len - 1, .col = ground[0].len - 1 };
    if (point.moved(.north, last)) |_| {
        if (try findAnimal(ground, .{ .row = point.row - 1, .col = point.col }, .north, found_vertices)) |steps| return steps;
    }
    if (point.moved(.south, last)) |_| {
        if (try findAnimal(ground, .{ .row = point.row + 1, .col = point.col }, .south, found_vertices)) |steps| return steps;
    }
    if (point.moved(.west, last)) |_| {
        if (try findAnimal(ground, .{ .row = point.row, .col = point.col - 1 }, .west, found_vertices)) |steps| return steps;
    }
    if (point.moved(.east, last)) |_| {
        if (try findAnimal(ground, .{ .row = point.row, .col = point.col + 1 }, .east, found_vertices)) |steps| return steps;
    }

    return error.NoLoopFound;
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

    var found_vertices = std.ArrayList(Point).init(allocator);
    defer found_vertices.deinit();

    return (try findLoop(lines.items, s_pos.?, &found_vertices) + 1) / 2;
}

fn part2(input: []const u8) !usize {
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

    var found_vertices = std.ArrayList(Point).init(allocator);
    defer found_vertices.deinit();

    const loop_length = try findLoop(lines.items, s_pos.?, &found_vertices) + 1;
    // Use the shoelace formula to find the area of the loop
    var area: isize = 0;
    i = 0;
    while (i < found_vertices.items.len) : (i += 1) {
        const a: isize = @intCast(found_vertices.items[i].row * found_vertices.items[(i + 1) % found_vertices.items.len].col);
        const b: isize = @intCast(found_vertices.items[i].col * found_vertices.items[(i + 1) % found_vertices.items.len].row);
        area += (a - b);
    }
    if (area < 0) area *= -1;
    area = @divTrunc(area, 2);

    return @as(usize, @intCast(area + 1)) - @divTrunc(loop_length, 2);
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

test "part 2 sample 1 input" {
    const input =
        \\...........
        \\.S-------7.
        \\.|F-----7|.
        \\.||.....||.
        \\.||.....||.
        \\.|L-7.F-J|.
        \\.|..|.|..|.
        \\.L--J.L--J.
        \\...........
    ;
    const answer: usize = 4;
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 sample 2 input" {
    const input =
        \\.F----7F7F7F7F-7....
        \\.|F--7||||||||FJ....
        \\.||.FJ||||||||L7....
        \\FJL7L7LJLJ||LJ.L-7..
        \\L--J.L7...LJS7F-7L7.
        \\....F-J..F7FJ|L7L7L7
        \\....L7.F7||L7|.L7L7|
        \\.....|FJLJ|FJ|F7|.LJ
        \\....FJL-7.||.||||...
        \\....L---J.LJ.LJLJ...
    ;
    const answer: usize = 8;
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 sample 3 input" {
    const input =
        \\FF7FSF7F7F7F7F7F---7
        \\L|LJ||||||||||||F--J
        \\FL-7LJLJ||||||LJL-77
        \\F--JF--7||LJLJ7F7FJ-
        \\L---JF-JLJ.||-FJLJJ7
        \\|F|F-JF---7F7-L7L|7|
        \\|FFJF7L7F-JF7|JL---7
        \\7-L-JL7||F7|L7F-7F7|
        \\L.L7LFJ|||||FJL7||LJ
        \\L7JLJL-JLJLJL--JLJ.L
    ;
    const answer: usize = 10;
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(usize, try getAnswer(2), 10);
    const got = try part2(input);
    try expectEqual(answer, got);
}
