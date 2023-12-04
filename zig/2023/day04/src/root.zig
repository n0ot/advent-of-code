const std = @import("std");
const expectEqual = std.testing.expectEqual;

fn part1(input: []const u8) !usize {
    var lines_iter = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: usize = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("memory leak");
    const allocator = gpa.allocator();
    while (lines_iter.next()) |line| {
        var card_it = std.mem.splitSequence(u8, line, ": ");
        _ = card_it.next(); // Don't care about card number
        var numbers_it = std.mem.splitSequence(u8, card_it.next() orelse continue, " | ");
        var winning_numbers_it = std.mem.splitScalar(u8, numbers_it.next() orelse continue, ' ');
        var have_numbers_it = std.mem.splitScalar(u8, numbers_it.next() orelse continue, ' ');
        var have_numbers = std.StringHashMap(void).init(allocator);
        defer have_numbers.deinit();
        while (have_numbers_it.next()) |num| if (num.len > 0) try have_numbers.put(num, {});

        var points: usize = 0;
        while (winning_numbers_it.next()) |num| {
            if (have_numbers.contains(num)) points = if (points == 0) 1 else points * 2;
        }

        sum += points;
    }

    return sum;
}

fn part2(input: []const u8) !usize {
    var lines_iter = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: usize = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("memory leak");
    const allocator = gpa.allocator();
    var card_counts = std.AutoHashMap(usize, usize).init(allocator);
    defer card_counts.deinit();
    var card_num: usize = 1;
    while (lines_iter.next()) |line| : (card_num += 1) {
        var card_it = std.mem.splitSequence(u8, line, ": ");
        _ = card_it.next(); // Don't care about card number
        var numbers_it = std.mem.splitSequence(u8, card_it.next() orelse continue, " | ");
        var winning_numbers_it = std.mem.splitScalar(u8, numbers_it.next() orelse continue, ' ');
        var have_numbers_it = std.mem.splitScalar(u8, numbers_it.next() orelse continue, ' ');
        var have_numbers = std.StringHashMap(void).init(allocator);
        defer have_numbers.deinit();
        while (have_numbers_it.next()) |num| if (num.len > 0) try have_numbers.put(num, {});

        var points: usize = 0;
        while (winning_numbers_it.next()) |num| {
            if (have_numbers.contains(num)) points += 1;
        }

        const card_count = card_counts.get(card_num) orelse 1;
        var i: usize = 0;
        while (i < points) : (i += 1) {
            const count = card_counts.get(card_num + i + 1) orelse 1; // Every card starts out with one copy
            try card_counts.put(card_num + i + 1, count + card_count); // Add one for each of the current card
        }

        sum += card_count;
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
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    const answer: usize = 13;
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
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    const answer: usize = 30;
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(usize, try getAnswer(2), 10);
    const got = try part2(input);
    try expectEqual(answer, got);
}
