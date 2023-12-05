use itertools::Itertools;
use std::collections::{HashMap, HashSet};
use std::time::Instant;

fn part1(input: &str) -> usize {
    input
        .lines()
        .map(|line| match get_card_matches(line) {
            0 => 0,
            num => 1 << (num - 1),
        })
        .sum()
}

fn part2(input: &str) -> usize {
    input
        .lines()
        .enumerate()
        .scan(HashMap::<usize, usize>::new(), |m, (i, line)| {
            let card_count = *m.entry(i).or_insert(1);
            let points = get_card_matches(line);
            (0..points).for_each(|j| *m.entry(i + j + 1).or_insert(1) += card_count);
            Some(card_count)
        })
        .sum()
}

fn get_card_matches(card: &str) -> usize {
    let (winning_nums, have_nums) = card
        .split(": ") // card ID and contents
        .skip(1) // Don't need card ID
        .next() // Contents
        .unwrap()
        .split(" | ") // "winning" and "have" numbers
        .map(|num_list| {
            HashSet::<&str>::from_iter(num_list.split(" ").filter(|num| !num.is_empty()))
        })
        .next_tuple()
        .unwrap();
    winning_nums.intersection(&have_nums).count()
}

fn main() {
    let input = include_str!("input.txt");
    let sum_part1 = part1(input);
    println!("part 1: {}", sum_part1);
    let start = Instant::now();
    let sum_part2 = part2(input);
    let elapsed = start.elapsed();
    println!("part 2: {}", sum_part2);
    println!("Elapsed: {:?}\n", elapsed);
}
