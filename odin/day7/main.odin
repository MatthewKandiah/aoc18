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

    make_requirements_map :: proc(requirements: []Requirement) -> map[u8][dynamic]u8 {
        requirements_map := make(map[u8][dynamic]u8)
        for requirement in requirements {
            if !(requirement.step in requirements_map) {
                requirements_map[requirement.step] = make([dynamic]u8)
            }
            append(&requirements_map[requirement.step], requirement.comes_before)
        }
        return requirements_map
    }
    requirements_map := make_requirements_map(requirements)

    result1 := [26]u8{}
    already_picked := [26]bool{}
    count1 := 0
    outer: for count1 < 26 {
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

    requirements_map2 := make_requirements_map(requirements)

    result2 := [26]u8{}
    count2 := 0
    time_elapsed := 0
    already_picked2 := [26]bool{}
    workers := [5]Worker{}
    available_worker_stack := Stack{}
    stack_push(&available_worker_stack, 0)
    stack_push(&available_worker_stack, 1)
    stack_push(&available_worker_stack, 2)
    stack_push(&available_worker_stack, 3)
    stack_push(&available_worker_stack, 4)

    for count2 < 26 {
        may_be_next_list := [26]bool{}
        for &b, idx in may_be_next_list {
            if !already_picked2[idx] {
                b = true
            }
        }
        for key, comes_before_list in requirements_map2 {
            for value in comes_before_list {
                may_be_next_list[value - 'A'] = false
            }
        }
        // may_be_next_list has all available candidates
        // distribute across available workers until we have no candidates, or no workers
        candidate_count := 0
        for b in may_be_next_list {
            if b {candidate_count += 1}
        }
        for !stack_is_empty(available_worker_stack) && candidate_count > 0 {
            candidate_idx := -1
            for may_be_next, idx in may_be_next_list {
                if may_be_next {
                    candidate_idx = idx
                    break
                }
            }
            value := cast(u8)candidate_idx + 'A'
            worker_idx := stack_pop(&available_worker_stack)
            workers[worker_idx].value = value
            workers[worker_idx].time_remaining = candidate_idx + 1 + 60
            may_be_next_list[candidate_idx] = false
            already_picked2[candidate_idx] = true
            candidate_count -= 1
        }
        // either workers are all busy, or all available work taken
        // wait long enough for a worker to become free, then repeat
        min_time_to_wait := max(int)
        for worker in workers {
            if worker.value != 0 {
                min_time_to_wait = min(min_time_to_wait, worker.time_remaining)
            }
        }
        time_elapsed += min_time_to_wait
        for &worker, idx in workers {
            if worker.value != 0 {
                worker.time_remaining -= min_time_to_wait
                if worker.time_remaining == 0 {
		    delete_key(&requirements_map2, worker.value)
                    result2[count2] = worker.value
                    count2 += 1
                    worker.value = 0
                    stack_push(&available_worker_stack, idx)
                }
            }
        }
    }
    fmt.println("Result 2:", string(result2[:]))
    fmt.println("Time elapsed:", time_elapsed)
}

Stack :: struct {
    size: int,
    buf:  [5]int,
}

stack_is_empty :: proc(s: Stack) -> bool {
    return s.size == 0
}

stack_pop :: proc(s: ^Stack) -> int {
    if s.size == 0 {panic("popped empty stack")}
    s.size -= 1
    return s.buf[s.size]
}

stack_push :: proc(s: ^Stack, value: int) {
    if s.size == len(s.buf) {panic("pushed on to full stack")}
    s.buf[s.size] = value
    s.size += 1
}

Worker :: struct {
    value:          u8, // 0 => worker free, not busy
    time_remaining: int,
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
