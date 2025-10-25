package day6

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

GRID_WIDTH :: 1_000
GRID_HEIGHT :: 1_000

input_file :: "../../input/day6.txt"

main :: proc() {
    data, ok := os.read_entire_file(input_file)
    if !ok {
        fmt.eprintln("Failed to read file", input_file)
        os.exit(1)
    }
    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1] // pesky empty last line

    positions := make([]Pos, len(lines))
    for line, i in lines {
        positions[i] = parse_position(line)
    }

    // mark each position in grid with index of position it is nearest
    // mark ties as sentinel value -1
    grid := make([]int, GRID_WIDTH * GRID_HEIGHT)
    for i in 0 ..< GRID_WIDTH {
        for j in 0 ..< GRID_HEIGHT {
            min_distance := max(int)
            for p, p_idx in positions {
                distance := manhattan_distance({x = i, y = j}, p)
                if distance == min_distance {
                    grid_write(grid, i, j, -1)
                } else if distance < min_distance {
                    grid_write(grid, i, j, p_idx)
                    min_distance = distance
                }
            }
        }
    }

    // if region includes an edge of the grid, then it's actually infinite
    // expect signle contiguous region for each index
    region_is_infinite := make([]bool, len(positions))
    for i in 0 ..< GRID_WIDTH {
        top := grid_get(grid, i, 0)
        bot := grid_get(grid, i, GRID_HEIGHT - 1)
        if top != -1 {
            region_is_infinite[top] = true
        }
        if bot != -1 {
            region_is_infinite[bot] = true
        }
    }
    for j in 0 ..< GRID_HEIGHT {
        left := grid_get(grid, 0, j)
        right := grid_get(grid, GRID_WIDTH - 1, j)
        if left != -1 {
            region_is_infinite[left] = true
        }
        if right != -1 {
            region_is_infinite[right] = true
        }
    }

    region_areas := make([]int, len(positions))
    for i in 0 ..< GRID_WIDTH {
        for j in 0 ..< GRID_HEIGHT {
            nearest_pos_idx := grid_get(grid, i, j)
            if nearest_pos_idx == -1 {continue}
            region_areas[nearest_pos_idx] += 1
        }
    }

    largest_area_not_infinite := 0
    for idx in 0 ..< len(positions) {
        if region_is_infinite[idx] {continue}
        largest_area_not_infinite = max(largest_area_not_infinite, region_areas[idx])
    }
    fmt.println("Result 1:", largest_area_not_infinite)

    size_of_region_close_to_all := 0
    for i in 0 ..< GRID_WIDTH {
        for j in 0 ..< GRID_HEIGHT {
            total_dist := 0
            for p in positions {
                total_dist += manhattan_distance({x = i, y = j}, p)
            }
	    if total_dist < 10_000 {
		size_of_region_close_to_all += 1
	    }
        }
    }
    fmt.println("Result 2", size_of_region_close_to_all)
}

Pos :: struct {
    x, y: int,
}

manhattan_distance :: proc(pos1, pos2: Pos) -> int {
    return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)
}

parse_position :: proc(line: string) -> Pos {
    split_line := strings.split(line, ",")
    if len(split_line) != 2 {panic("Expected all lines to contain 2 comma-separated values")}
    x, x_ok := strconv.parse_int(split_line[0])
    y, y_ok := strconv.parse_int(split_line[1][1:]) // skip initial whitespace
    if !(x_ok && y_ok) {
        panic("Failed to parse integers")}
    return {x = x, y = y}
}

grid_get :: proc(grid: []int, x, y: int) -> int {
    if x >= GRID_WIDTH || y >= GRID_HEIGHT {panic("grid access out of bounds")}
    return grid[x + y * GRID_WIDTH]
}

grid_write :: proc(grid: []int, x, y, value: int) {
    if x >= GRID_WIDTH || y >= GRID_HEIGHT {panic("grid write out of bounds")}
    grid[x + y * GRID_WIDTH] = value
}
