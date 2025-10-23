package day3

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Claim :: struct {
    id:     int,
    x:      int,
    y:      int,
    width:  int,
    height: int,
}

input_path :: "../../input/day3.txt"

main :: proc() {
    data, ok := os.read_entire_file(input_path)
    if !ok {
        fmt.eprintln("Failed to read file", input_path)
    }

    lines := strings.split_lines(string(data))
    lines = lines[0:len(lines) - 1] // getting an empty string for the last line
    claims := make([]Claim, len(lines))
    for line, idx in lines {
        claims[idx] = parse_line(line)
    }

    // max claim.x + claim.width < 1000
    // max claim.y + claim.height < 1000
    Status :: enum {
        free,
        taken,
        contested,
    }
    fabric := [1000][1000]Status{}
    for claim in claims {
        for i in claim.x ..< claim.x + claim.width {
            for j in claim.y ..< claim.y + claim.height {
                if fabric[j][i] ==
                   .free {fabric[j][i] = .taken} else if fabric[j][i] == .taken {fabric[j][i] = .contested}
            }
        }
    }

    contested_count := 0
    for row in fabric {
        for square_inch in row {
            if square_inch == .contested {
                contested_count += 1
            }
        }
    }
    fmt.println("Result 1: ", contested_count)

    claim_loop: for claim in claims {
        for i in claim.x ..< claim.x + claim.width {
            for j in claim.y ..< claim.y + claim.height {
                if fabric[j][i] == .contested {continue claim_loop}
            }
        }
        fmt.println("Result 2: ", claim.id)
        break claim_loop
    }
}

parse_line :: proc(line: string) -> (claim: Claim) {
    ParsingMode :: enum {
        id,
        x,
        y,
        width,
        height,
    }
    mode := ParsingMode.id
    // looking at the input, 4 digits is the longest number we'll need to parse
    buf: [4]u8
    buf_count := 0
    for char in line {
        if (char == '#' || char == ' ') {
            continue
        }
        switch mode {
        case .id:
            if (char == '@') {
                claim.id = parse_int(buf[0:buf_count])
                buf_count = 0
                mode = .x
                continue
            }
        case .x:
            if (char == ',') {
                claim.x = parse_int(buf[0:buf_count])
                buf_count = 0
                mode = .y
                continue
            }
        case .y:
            if (char == ':') {
                claim.y = parse_int(buf[0:buf_count])
                buf_count = 0
                mode = .width
                continue
            }
        case .width:
            if (char == 'x') {
                claim.width = parse_int(buf[0:buf_count])
                buf_count = 0
                mode = .height
                continue
            }
        case .height:
        // run until end of line
        }
        buf[buf_count] = cast(u8)char
        buf_count += 1
    }
    if mode != .height {
        fmt.eprintln("Expected to be looking for height at the end of the line, was actually looking for: ", mode)
        os.exit(1)
    }
    claim.height = parse_int(buf[0:buf_count])
    return claim
}

parse_int :: proc(buf: []u8) -> int {
    num, ok := strconv.parse_int(string(buf))
    if !ok {
        fmt.eprintln("Failed to parse int", string(buf))
        os.exit(1)
    }
    return num
}
