package day7

import "core:fmt"
import "core:os"
import "core:strings"

input_path :: "../../input/day7.txt"

main :: proc() {
    data, ok := os.read_entire_file(input_path)
    if !ok {
        fmt.eprintln("Failed to read file", input_path)
        os.exit(1)
    }
    data = data[:len(data) - 1] // pesky final empty character
    lines := strings.split_lines(string(data))
    requirements := make([]Requirement, len(lines))
    for line, idx in lines {
        requirements[idx] = parse_line(line)
    }

    requirements_map := make(map[u8][dynamic]u8)
    for requirement in requirements {
        if !(requirement.step in requirements_map) {
            requirements_map[requirement.step] = make([dynamic]u8)
        }
        append(&requirements_map[requirement.step], requirement.comes_before)
    }

    result1 := [26]u8{}
    already_picked := [26]bool{}
    count1 := 0
    outer: for count1 < 26{
        may_be_next_list := [26]bool{}
        for &b, idx in may_be_next_list {
	    if !already_picked[idx] {
		b = true
	    }
        }
        for key, comes_before_list in requirements_map {
            for value in comes_before_list {
                may_be_next_list[value - 'A'] = false
            }
        }
	for value, idx in may_be_next_list{
	    if value {
	    }
	}
	for may_be_next, idx in may_be_next_list {
	    if may_be_next {
		value := cast(u8)idx + cast(u8)'A'
		already_picked[idx] = true
		result1[count1] = value
		count1 += 1
		delete_key(&requirements_map, value)
		continue outer
	    }
	}
	unreachable()
    }
    fmt.println("Result 1:", string(result1[:]))
}

Requirement :: struct {
    step:         u8,
    comes_before: u8,
}

parse_line :: proc(line: string) -> (r: Requirement) {
    r.step = line[5]
    r.comes_before = line[36]
    return
}
