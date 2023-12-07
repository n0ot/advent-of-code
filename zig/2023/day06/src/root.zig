const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Race = struct {
    /// Duration of the race in MS
    duration: usize,
    /// Record distance traveled in MM
    record_distance: usize,
};

fn numWinningTimes(duration: usize, record_distance: usize) usize {
    // I know this can be worked out algebraically, but whatever.
    // We'll binary search it instead.
    // At least it's uniform in both directions, so we only have to search half the space.
    var low: usize = 1;
    var high: usize = duration / 2 + 1;
    while (low < high) {
        const mid = low + (high - low) / 2;
        if (mid * (duration - mid) > record_distance and (mid - 1) * (duration - mid + 1) <= record_distance) {
            return duration + 1 - 2 * mid;
        } else if (mid * (duration - mid) > record_distance) {
            high = mid;
        } else {
            low = mid + 1;
        }
    }

    return 0;
}

fn part1(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("Memory leak");
    const allocator = gpa.allocator();
    var races = std.ArrayList(Race).init(allocator);
    defer races.deinit();
    var races_product: usize = 1;

    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');
    var times_it = std.mem.tokenizeScalar(u8, lines_it.next() orelse return error.NoTimes, ' ');
    _ = times_it.next(); // Ignore the "Times:" column.
    var i: usize = 0;
    while (times_it.next()) |time| : (i += 1) {
        const duration = try std.fmt.parseInt(usize, time, 10);
        try races.append(.{ .duration = duration, .record_distance = 0 });
    }

    var distances_it = std.mem.tokenizeScalar(u8, lines_it.next() orelse return error.NoDistances, ' ');
    _ = distances_it.next(); // Ignore the "Distances:" column
    i = 0;
    while (distances_it.next()) |distance| : (i += 1) {
        if (i >= races.items.len) return error.NonUniformTable;
        const record_distance = try std.fmt.parseInt(usize, distance, 10);
        races.items[i].record_distance = record_distance;

        races_product *= numWinningTimes(races.items[i].duration, races.items[i].record_distance);
    }
    if (i < races.items.len) return error.NonUniformTable;

    return races_product;
}

fn part2(input: []const u8) !usize {
    var race = Race{ .duration = 0, .record_distance = 0 };

    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');
    const time = lines_it.next() orelse return error.NoTime;
    for (time) |d| {
        switch (d) {
            '0'...'9' => race.duration = 10 * race.duration + d - '0',
            else => {},
        }
    }
    const record_distance = lines_it.next() orelse return error.NoRecordDistance;
    for (record_distance) |d| {
        switch (d) {
            '0'...'9' => race.record_distance = 10 * race.record_distance + d - '0',
            else => {},
        }
    }

    return numWinningTimes(race.duration, race.record_distance);
}

fn getAnswer(comptime part: comptime_int) ![]const u8 {
    if (part != 1 and part != 2) @compileError("part must be either 1 or 2");
    const answer_text = @embedFile(std.fmt.comptimePrint("part{d}answer.txt", .{part}));
    return std.mem.trimRight(u8, answer_text, " \t\n");
}

test "part 1 sample input" {
    const input =
        \\Time:      7  15   30
        \\Distance:  9  40  200
    ;
    const answer: usize = 288;
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
        \\Time:      7  15   30
        \\Distance:  9  40  200
    ;
    const answer: usize = 71503;
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(usize, try getAnswer(2), 10);
    var timer = try std.time.Timer.start();
    const got = try part2(input);
    std.debug.print("Elapsed: {} NS\n", .{timer.read()});
    try expectEqual(answer, got);
}
