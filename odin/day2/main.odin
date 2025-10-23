package day2

import "core:fmt"
import "core:os"
import "core:strings"

input_path :: "../../input/day2.txt"

main :: proc() {
    data, ok := os.read_entire_file(input_path)
    if !ok {
        fmt.eprintln("Failed to read file: ", input_path)
        os.exit(1)
    }

    lines := strings.split_lines(string(data))

    count_contains_two_of_a_letter := 0
    count_contains_three_of_a_letter := 0

    for line in lines {
        letter_counts := [26]int{}
        for char in line {
            letter_counts[alphabet_index(cast(u8)char)] += 1
        }
        two_count_found := false
        three_count_found := false
        for count in letter_counts {
            if count == 2 {two_count_found = true}
            if count == 3 {three_count_found = true}
        }
        if two_count_found {count_contains_two_of_a_letter += 1}
        if three_count_found {count_contains_three_of_a_letter += 1}
    }

    fmt.println("Result 1:", count_contains_two_of_a_letter * count_contains_three_of_a_letter)

    for line, i in lines {
        for j in i + 1 ..< len(lines) - 1 {
            other_line := lines[j]
            comparisons := make([]bool, len(line))
            for k in 0 ..< len(line) {
                comparisons[k] = line[k] == other_line[k]
            }
            common_letter_count := 0
            for check in comparisons {
                if check {
                    common_letter_count += 1
                }
            }
            if common_letter_count == len(line) - 1 {
                fmt.print("Result 2: ")
                for check, i in comparisons {
                    if check {
                        fmt.printf("%c", line[i])
                    }
                }
            }
        }
    }
}

alphabet_index :: proc(letter: u8) -> u8 {
    return letter - 'a'
}
