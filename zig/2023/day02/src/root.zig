const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Color = enum { red, green, blue };

fn part1(input: []const u8, red_max: u32, green_max: u32, blue_max: u32) !u32 {
    var lines_iter = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: u32 = 0;
    game_blk: while (lines_iter.next()) |line| {
        if (line.len == 0) continue;
        var game_it = std.mem.splitSequence(u8, line, ": ");
        const game_id_str = game_it.next() orelse continue;
        const rounds = game_it.next() orelse continue;
        if (game_id_str.len < 5 or !std.mem.eql(u8, game_id_str[0..5], "Game ")) return error.ParseError;
        const game_id = try std.fmt.parseInt(u32, game_id_str[5..], 10);

        var rounds_it = std.mem.split(u8, rounds, "; ");
        while (rounds_it.next()) |round| {
            var draws_it = std.mem.splitSequence(u8, round, ", ");
            while (draws_it.next()) |draw| {
                var color_amount_it = std.mem.splitSequence(u8, draw, " ");
                const amount = try std.fmt.parseInt(u8, color_amount_it.next() orelse continue :game_blk, 10);
                const color = std.meta.stringToEnum(Color, color_amount_it.next() orelse continue :game_blk) orelse continue :game_blk;
                const max_amount = switch (color) {
                    .red => red_max,
                    .green => green_max,
                    .blue => blue_max,
                };
                if (amount > max_amount) continue :game_blk;
            }
        }
        sum += game_id;
    }

    return sum;
}

fn part2(input: []const u8) !u32 {
    var lines_iter = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: u32 = 0;
    game_blk: while (lines_iter.next()) |line| {
        if (line.len == 0) continue;
        var game_it = std.mem.splitSequence(u8, line, ": ");
        _ = game_it.next() orelse return error.ParseError;
        const rounds = game_it.next() orelse return error.ParseError;
        var red_amount: u32, var green_amount: u32, var blue_amount: u32 = .{ 0, 0, 0 };

        var rounds_it = std.mem.split(u8, rounds, "; ");
        while (rounds_it.next()) |round| {
            var draws_it = std.mem.splitSequence(u8, round, ", ");
            while (draws_it.next()) |draw| {
                var color_amount_it = std.mem.splitSequence(u8, draw, " ");
                const amount = try std.fmt.parseInt(u8, color_amount_it.next() orelse continue :game_blk, 10);
                const color = std.meta.stringToEnum(Color, color_amount_it.next() orelse continue :game_blk) orelse continue :game_blk;
                switch (color) {
                    .red => red_amount = @max(red_amount, amount),
                    .green => green_amount = @max(green_amount, amount),
                    .blue => blue_amount = @max(blue_amount, amount),
                }
            }
        }
        sum += red_amount * green_amount * blue_amount;
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
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    const answer = @as(u32, 8);
    const got = try part1(input, 12, 13, 14);
    try expectEqual(answer, got);
}

test "part 1 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(u32, try getAnswer(1), 10);
    const got = try part1(input, 12, 13, 14);
    try expectEqual(answer, got);
}

test "part 2 sample input" {
    const input =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    const answer = @as(u32, 2286);
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(u32, try getAnswer(2), 10);
    const got = try part2(input);
    try expectEqual(answer, got);
}
