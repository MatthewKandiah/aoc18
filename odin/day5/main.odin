package day5

import "core:fmt"
import "core:os"

input_path :: "../../input/day5.txt"
upper_case_delta :: 'a' - 'A'

main :: proc() {
    data, ok := os.read_entire_file(input_path)
    if !ok {
        fmt.eprintln("Failed to read file", input_path)
        os.exit(1)
    }
    data = data[:len(data) - 1] // damned extra character every time

    buffer := [100_000]u8{}
    ps := PolymerStack {
        data = buffer[:],
        size = 0,
    }
    for b in data {
        ok := polymer_stack_push(&ps, b)
        if !ok {
            fmt.eprintln("Overflowed polymer stack buffer")
            os.exit(1)
        }
    }
    fmt.println("Result 1:", ps.size)

    best_result: int = max(int)
    for upper in 'A' ..= 'Z' {
        lower := upper + upper_case_delta
        ps.size = 0
        for b in data {
            if b == cast(u8)upper || b == cast(u8)lower {
                continue
            }
            ok := polymer_stack_push(&ps, b)
            if !ok {
                fmt.eprintln("Overflowed polymer stack buffer")
                os.exit(1)
            }
        }
        best_result = min(best_result, ps.size)
    }
    fmt.println("Result 2:", best_result)
}

PolymerStack :: struct {
    data: []u8,
    size: int,
}

polymer_stack_pop :: proc(ps: ^PolymerStack) -> (value: u8, ok: bool) {
    if ps.size == 0 {return}
    ps.size -= 1
    return ps.data[ps.size], true
}

polymer_stack_peek :: proc(ps: ^PolymerStack) -> (value: u8, ok: bool) {
    if ps.size == 0 {return}
    return ps.data[ps.size - 1], true
}

polymer_stack_push :: proc(ps: ^PolymerStack, value: u8) -> (ok: bool) {
    if ps.size == len(ps.data) {return}
    peek, peek_ok := polymer_stack_peek(ps)
    if !peek_ok || min(abs(peek - value), abs(value - peek)) != upper_case_delta {
        ps.data[ps.size] = value
        ps.size += 1
    } else {
        polymer_stack_pop(ps)
    }
    return true
}
