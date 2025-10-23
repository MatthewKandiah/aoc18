package day1

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

input_path :: "../../input/day1.txt"

main :: proc() {
    data, ok := os.read_entire_file(input_path)
    if !ok {
        fmt.eprintln("Cannot read file", input_path)
        os.exit(1)
    }

    lines := strings.split_lines(string(data))
    numbers := make([]int, len(lines))
    for line, idx in lines {
        if line == "" {continue}
        num, ok := strconv.parse_int(line)
        if !ok {
            fmt.eprintln("Cannot parse int", line)
            os.exit(1)
        }
        numbers[idx] = num
    }

    res1 := 0
    for num in numbers {
        res1 += num
    }
    fmt.println("Result 1: ", res1)

    seen_frequencies := make(map[int]int)
    current_frequency := 0
    count := 0
    for {
        if current_frequency in seen_frequencies {
            fmt.println("Result 2:", current_frequency)
            os.exit(0)
        }

        seen_frequencies[current_frequency] = 1
        current_frequency += numbers[count % (len(numbers) - 1)]
        count += 1
    }
}
