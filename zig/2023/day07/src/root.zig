const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Hand = struct {
    // Contains a number that represents the card's total value.
    // This consists of 23 bits,
    // where the high 3 bits encode the card's type (five of a kind, etc),
    // and the remaining 20 bits are divided into five groups of four bits,
    // each encoding a card's label (2-9, T, J, Q, K, A).
    value: u32,
    bid: usize,

    const Self = @This();

    const Label = enum {
        joker,
        two,
        three,
        four,
        five,
        six,
        seben,
        eight,
        nine,
        ten,
        jack,
        queen,
        king,
        ace,
    };

    const Type = enum {
        highCard,
        onePair,
        twoPair,
        threeOfAKind,
        FullHouse,
        FourOfAKind,
        FiveOfAKind,

        pub fn calculate(input: []const u8, part: u8) @This() {
            var sorted_hand: [5]u8 = undefined;
            std.mem.copyForwards(u8, &sorted_hand, input);
            std.sort.heap(u8, &sorted_hand, {}, std.sort.asc(u8));

            var counts = [_]u8{0} ** 5;
            var prev: ?u8 = null;
            var num_j_cards: u8 = 0;
            var i: u8 = 0;
            for (sorted_hand) |card| {
                if (prev != null and card != prev) i += 1;
                prev = card;
                if (part == 2 and card == 'J') {
                    num_j_cards += 1;
                } else {
                    counts[i] += 1;
                }
            }

            std.sort.heap(u8, &counts, {}, std.sort.asc(u8));
            if (part == 2) counts[4] += num_j_cards;

            if (counts[4] == 5) return .FiveOfAKind;
            if (counts[4] == 4) return .FourOfAKind;
            if (counts[4] == 3 and counts[3] == 2) return .FullHouse;
            if (counts[4] == 3) return .threeOfAKind;
            if (counts[4] == 2 and counts[3] == 2) return .twoPair;
            if (counts[4] == 2) return .onePair;
            return .highCard;
        }
    };

    pub fn new(input: []const u8, bid: usize, part: u8) !Hand {
        if (input.len != 5) return error.InvalidCardCount;
        // Calculate the label values, and pack them together in a single u32, for faster comparison.
        var value: u32 = 0;
        for (input) |card| {
            const label: Label = switch (card) {
                '2'...'9' => @enumFromInt(card - '0' - 1),
                'T' => .ten,
                'J' => if (part == 1) .jack else .joker,
                'Q' => .queen,
                'K' => .king,
                'A' => .ace,
                else => return error.BadCardLabel,
            };
            value = (value << 4) | @intFromEnum(label);
        }

        value = (@as(u32, @intFromEnum(Type.calculate(input, part))) << 20) | value;

        return Self{
            .value = value,
            .bid = bid,
        };
    }

    pub fn lessThan(_: void, self: Self, other: Self) bool {
        return self.value < other.value;
    }
};

fn handsSum(input: []const u8, part: u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("Leak!");
    const allocator = gpa.allocator();
    var hands = std.ArrayList(Hand).init(allocator);
    defer hands.deinit();

    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines_it.next()) |line| {
        var hand_it = std.mem.tokenizeScalar(u8, line, ' ');
        const hand = hand_it.next() orelse return error.BadHand;
        const bid_str = hand_it.next() orelse return error.BadBid;
        const bid = try std.fmt.parseInt(usize, bid_str, 10);
        try hands.append(try Hand.new(hand, bid, part));
    }

    std.sort.heap(Hand, hands.items, {}, Hand.lessThan);
    var sum: usize = 0;
    for (hands.items, 1..) |hand, i| sum += hand.bid * i;

    return sum;
}

fn part1(input: []const u8) !usize {
    return handsSum(input, 1);
}

fn part2(input: []const u8) !usize {
    return handsSum(input, 2);
}

fn getAnswer(comptime part: comptime_int) ![]const u8 {
    if (part != 1 and part != 2) @compileError("part must be either 1 or 2");
    const answer_text = @embedFile(std.fmt.comptimePrint("part{d}answer.txt", .{part}));
    return std.mem.trimRight(u8, answer_text, " \t\n");
}

test "part 1 sample input" {
    const input =
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
    ;
    const answer: usize = 6440;
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
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
    ;
    const answer: usize = 5905;
    const got = try part2(input);
    try expectEqual(answer, got);
}

test "part 2 puzzle input" {
    const input = @embedFile("input.txt");
    const answer = try std.fmt.parseInt(usize, try getAnswer(2), 10);
    const got = try part2(input);
    try expectEqual(answer, got);
}
