const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Node = struct {
    left: []const u8,
    right: []const u8,
};

fn part1(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("Leak!");
    const allocator = gpa.allocator();
    var nodes = std.StringHashMap(Node).init(allocator);
    defer nodes.deinit();

    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');
    const directions = lines_it.next() orelse return error.ParseError;
    while (lines_it.next()) |line| {
        var tokens_it = std.mem.tokenizeAny(u8, line, " =(,)");
        const node_name = tokens_it.next() orelse return error.ParseError;
        const left = tokens_it.next() orelse return error.ParseError;
        const right = tokens_it.next() orelse return error.ParseError;
        if (node_name.len != 3 or left.len != 3 or right.len != 3) return error.ParseError;
        try nodes.put(node_name, .{ .left = left, .right = right });
    }

    var node_name: []const u8 = "AAA";
    var i: usize = 0;
    while (i < 1000000000000) : (i += 1) {
        const node = nodes.get(node_name) orelse return error.NodeNotFound;
        node_name = switch (directions[i % directions.len]) {
            'L' => node.left,
            'R' => node.right,
            else => return error.ParseError,
        };
        if (std.mem.eql(u8, node_name, "ZZZ")) return i + 1;
    }

    return error.StepLimitExceeded;
}

fn part2(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("Leak!");
    const allocator = gpa.allocator();
    var nodes = std.StringHashMap(Node).init(allocator);
    defer nodes.deinit();
    var current_nodes = std.ArrayList([]const u8).init(allocator);
    defer current_nodes.deinit();

    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');
    const directions = lines_it.next() orelse return error.ParseError;
    while (lines_it.next()) |line| {
        var tokens_it = std.mem.tokenizeAny(u8, line, " =(,)");
        const node_name = tokens_it.next() orelse return error.ParseError;
        const left = tokens_it.next() orelse return error.ParseError;
        const right = tokens_it.next() orelse return error.ParseError;
        if (node_name.len != 3 or left.len != 3 or right.len != 3) return error.ParseError;
        try nodes.put(node_name, .{ .left = left, .right = right });
        if (node_name[2] == 'A') {
            try current_nodes.append(node_name);
        }
    }

    // Find the least common multiple of all of the path lengths.
    // This assumption only holds if every path is entirely on a cycle.
    var lcm: usize = 1;
    for (current_nodes.items) |n| {
        var node_name = n;
        var i: usize = 0;
        while (i < 1000000000000) : (i += 1) {
            const node = nodes.get(node_name) orelse return error.NodeNotFound;
            node_name = switch (directions[i % directions.len]) {
                'L' => node.left,
                'R' => node.right,
                else => return error.ParseError,
            };
            if (node_name[2] == 'Z') break;
        } else return error.StepLimitExceeded;
        lcm = lcm * (i + 1) / std.math.gcd(lcm, i + 1);
    }

    return lcm;
}

fn getAnswer(comptime part: comptime_int) ![]const u8 {
    if (part != 1 and part != 2) @compileError("part must be either 1 or 2");
    const answer_text = @embedFile(std.fmt.comptimePrint("part{d}answer.txt", .{part}));
    return std.mem.trimRight(u8, answer_text, " \t\n");
}

test "part 1 sample 1 input" {
    const input =
        \\RL
        \\
        \\AAA = (BBB, CCC)
        \\BBB = (DDD, EEE)
        \\CCC = (ZZZ, GGG)
        \\DDD = (DDD, DDD)
        \\EEE = (EEE, EEE)
        \\GGG = (GGG, GGG)
        \\ZZZ = (ZZZ, ZZZ)
    ;
    const answer: usize = 2;
    const got = try part1(input);
    try expectEqual(answer, got);
}

test "part 1 sample 2 input" {
    const input =
        \\LLR
        \\
        \\AAA = (BBB, BBB)
        \\BBB = (AAA, ZZZ)
        \\ZZZ = (ZZZ, ZZZ)
    ;
    const answer: usize = 6;
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
        \\LR
        \\
        \\11A = (11B, XXX)
        \\11B = (XXX, 11Z)
        \\11Z = (11B, XXX)
        \\22A = (22B, XXX)
        \\22B = (22C, 22C)
        \\22C = (22Z, 22Z)
        \\22Z = (22B, 22B)
        \\XXX = (XXX, XXX)
    ;
    const answer: usize = 6;
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(usize, try getAnswer(2), 10);
    const got = try part2(input);
    try expectEqual(answer, got);
}
