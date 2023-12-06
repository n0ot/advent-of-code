const std = @import("std");
const expectEqual = std.testing.expectEqual;

const Almanac = struct {
    seeds: std.ArrayList(usize),
    maps: [@typeInfo(MappingType).Enum.fields.len]std.ArrayList(Range),

    const Self = @This();

    const Range = struct {
        dst_start: usize,
        src_start: usize,
        len: usize,

        pub fn contains(_: void, key: usize, self: @This()) std.math.Order {
            if (key < self.src_start) return .lt;
            if (self.src_start <= key and key < self.src_start + self.len) return .eq;
            return .gt;
        }
    };

    const MappingType = enum {
        seed_soil,
        soil_fertilizer,
        fertilizer_water,
        water_light,
        light_temperature,
        temperature_humidity,
        humidity_location,
    };

    const MapResult = struct {
        value: usize,
        remaining: usize,
    };

    pub fn init(allocator: std.mem.Allocator) Self {
        var almanac = Almanac{
            .seeds = std.ArrayList(usize).init(allocator),
            .maps = undefined,
        };
        for (0..almanac.maps.len) |i| almanac.maps[i] = std.ArrayList(Range).init(allocator);

        return almanac;
    }

    pub fn deinit(self: *Self) void {
        self.seeds.deinit();
        for (0..self.maps.len) |i| self.maps[i].deinit();
    }

    pub fn addSeed(self: *Self, seed: usize) !void {
        try self.seeds.append(seed);
    }

    pub fn addRangeMapping(self: *Self, mapping_type: MappingType, dst_start: usize, src_start: usize, len: usize) !void {
        var map = &self.maps[@intFromEnum(mapping_type)];
        // Always insert sorted.
        const idx = blk: for (map.items, 0..) |range, i| {
            if (src_start < range.src_start) break :blk i;
        } else map.items.len;
        try map.insert(idx, .{ .dst_start = dst_start, .src_start = src_start, .len = len });
    }

    pub fn get(self: *Self, mapping_type: MappingType, src: usize) MapResult {
        const map = &self.maps[@intFromEnum(mapping_type)];
        if (std.sort.binarySearch(Range, src, map.items, {}, Range.contains)) |i| {
            const range = map.items[i];
            return .{ .value = src - range.src_start + range.dst_start, .remaining = range.len + range.src_start - src - 1 };
        }
        return .{ .value = src, .remaining = 0 };
    }

    pub fn getSeedLocation(self: *Self, seed: usize) MapResult {
        var result = self.get(.seed_soil, seed);
        var min_remaining = result.remaining;
        result = self.get(.soil_fertilizer, result.value);
        min_remaining = @min(min_remaining, result.remaining);
        result = self.get(.fertilizer_water, result.value);
        min_remaining = @min(min_remaining, result.remaining);
        result = self.get(.water_light, result.value);
        min_remaining = @min(min_remaining, result.remaining);
        result = self.get(.light_temperature, result.value);
        min_remaining = @min(min_remaining, result.remaining);
        result = self.get(.temperature_humidity, result.value);
        min_remaining = @min(min_remaining, result.remaining);
        result = self.get(.humidity_location, result.value);
        min_remaining = @min(min_remaining, result.remaining);

        return .{ .value = result.value, .remaining = min_remaining };
    }
};

const AlmanacParser = struct {
    const ParseError = error{
        BadBlockHeader,
        UnknownBlockType,
        BadMappingRange,
    };

    const mapping_types = std.ComptimeStringMap(Almanac.MappingType, .{
        .{ "seed-to-soil map", .seed_soil },
        .{ "soil-to-fertilizer map", .soil_fertilizer },
        .{ "fertilizer-to-water map", .fertilizer_water },
        .{ "water-to-light map", .water_light },
        .{ "light-to-temperature map", .light_temperature },
        .{ "temperature-to-humidity map", .temperature_humidity },
        .{ "humidity-to-location map", .humidity_location },
    });

    pub fn parse(almanac: *Almanac, input: []const u8) !void {
        // The input is divided into blocks, separated by blank lines.
        var blocks_it = std.mem.tokenizeSequence(u8, input, "\n\n");
        while (blocks_it.next()) |block| try parseBlock(almanac, block);
    }

    fn parseBlock(almanac: *Almanac, block: []const u8) !void {
        if (block.len == 0) return;
        // The first line of each block is its header, in `key:[ value]` format.
        var lines_it = std.mem.tokenizeScalar(u8, block, '\n');
        var header_it = std.mem.splitScalar(u8, lines_it.next() orelse unreachable, ':');
        const header_key = header_it.next() orelse unreachable;
        const header_value = std.mem.trimLeft(u8, header_it.next() orelse return ParseError.BadBlockHeader, " ");

        if (std.mem.eql(u8, header_key, "seeds")) {
            var seeds_it = std.mem.tokenizeScalar(u8, header_value, ' ');
            while (seeds_it.next()) |seed_str| {
                const seed = try std.fmt.parseInt(usize, seed_str, 10);
                try almanac.addSeed(seed);
            }
        } else {
            const mapping_type = mapping_types.get(header_key) orelse return ParseError.UnknownBlockType;
            while (lines_it.next()) |mapping| {
                var range_it = std.mem.tokenizeScalar(u8, mapping, ' ');
                const dst_start = try std.fmt.parseInt(usize, range_it.next() orelse return ParseError.BadMappingRange, 10);
                const src_start = try std.fmt.parseInt(usize, range_it.next() orelse return ParseError.BadMappingRange, 10);
                const len = try std.fmt.parseInt(usize, range_it.next() orelse return ParseError.BadMappingRange, 10);
                try almanac.addRangeMapping(mapping_type, dst_start, src_start, len);
            }
        }
    }
};

fn part1(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("Memory leak!");
    const allocator = gpa.allocator();

    var almanac = Almanac.init(allocator);
    defer almanac.deinit();
    try AlmanacParser.parse(&almanac, input);
    var lowest_location: ?usize = null;
    for (almanac.seeds.items) |seed| {
        const locationResult = almanac.getSeedLocation(seed);
        lowest_location = if (lowest_location) |lowest| @min(lowest, locationResult.value) else locationResult.value;
    }

    return lowest_location orelse error.NoLocationsFound;
}

fn part2(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) @panic("Memory leak!");
    const allocator = gpa.allocator();

    var almanac = Almanac.init(allocator);
    defer almanac.deinit();
    try AlmanacParser.parse(&almanac, input);
    var prev_seed: ?usize = null;
    var lowest_location: ?usize = null;
    for (almanac.seeds.items) |seed| {
        // Interpret `prev_seed` as the start of a range,
        // and seed as the length.
        // If prev_seed is null, this parsed number is the start of the range.
        if (prev_seed) |prev| {
            var i = prev;
            while (i < prev + seed) : (i += 1) {
                const locationResult = almanac.getSeedLocation(i);
                lowest_location = if (lowest_location) |lowest| @min(lowest, locationResult.value) else locationResult.value;
                // Since we only care about the lowest location,
                // it's okay to skip past the rest of the values in a contiguous range.
                i += locationResult.remaining;
            }
            prev_seed = null;
        } else prev_seed = seed;
    }

    return lowest_location orelse error.NoLocationsFound;
}

fn getAnswer(comptime part: comptime_int) ![]const u8 {
    if (part != 1 and part != 2) @compileError("part must be either 1 or 2");
    const answer_text = @embedFile(std.fmt.comptimePrint("part{d}answer.txt", .{part}));
    return std.mem.trimRight(u8, answer_text, " \t\n");
}

test "part 1 sample input" {
    const input =
        \\seeds: 79 14 55 13
        \\
        \\seed-to-soil map:
        \\50 98 2
        \\52 50 48
        \\
        \\soil-to-fertilizer map:
        \\0 15 37
        \\37 52 2
        \\39 0 15
        \\
        \\fertilizer-to-water map:
        \\49 53 8
        \\0 11 42
        \\42 0 7
        \\57 7 4
        \\
        \\water-to-light map:
        \\88 18 7
        \\18 25 70
        \\
        \\light-to-temperature map:
        \\45 77 23
        \\81 45 19
        \\68 64 13
        \\
        \\temperature-to-humidity map:
        \\0 69 1
        \\1 0 69
        \\
        \\humidity-to-location map:
        \\60 56 37
        \\56 93 4
    ;
    const answer: usize = 35;
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
        \\seeds: 79 14 55 13
        \\
        \\seed-to-soil map:
        \\50 98 2
        \\52 50 48
        \\
        \\soil-to-fertilizer map:
        \\0 15 37
        \\37 52 2
        \\39 0 15
        \\
        \\fertilizer-to-water map:
        \\49 53 8
        \\0 11 42
        \\42 0 7
        \\57 7 4
        \\
        \\water-to-light map:
        \\88 18 7
        \\18 25 70
        \\
        \\light-to-temperature map:
        \\45 77 23
        \\81 45 19
        \\68 64 13
        \\
        \\temperature-to-humidity map:
        \\0 69 1
        \\1 0 69
        \\
        \\humidity-to-location map:
        \\60 56 37
        \\56 93 4
    ;
    const answer: usize = 46;
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
