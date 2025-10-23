package day4

import "core:fmt"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:strings"

input_path :: "../../input/day4.txt"

Record :: struct {
    time:  DateTime,
    event: Event,
}

record_cmp :: proc(r1, r2: Record) -> int {
    if r1.time.year != r2.time.year {
        return r1.time.year - r2.time.year
    } else if r1.time.month != r2.time.month {
        return r1.time.month - r2.time.month
    } else if r1.time.day != r2.time.day {
        return r1.time.day - r2.time.day
    } else if r1.time.hour != r2.time.hour {
        return r1.time.hour - r2.time.hour
    } else if r1.time.minute != r2.time.minute {
        return r1.time.minute - r2.time.minute
    } else {return 0}
}

DateTime :: struct {
    year:   int,
    month:  int,
    day:    int,
    hour:   int,
    minute: int,
}

Event :: union {
    Start,
    StateUpdate,
}

Start :: struct {
    guard_id: int,
}

StateUpdate :: struct {
    new_state: State,
}

State :: enum {
    asleep,
    awake,
}

main :: proc() {
    data, ok := os.read_entire_file(input_path)
    if !ok {
        fmt.eprintln("Failed to read input from", input_path)
        os.exit(1)
    }

    lines := strings.split_lines(string(data))
    lines = lines[:len(lines) - 1] // getting empty string for last line!

    records := make([]Record, len(lines))
    for line, i in lines {
        records[i] = parse_line(transmute([]u8)line)
    }
    sort.quick_sort_proc(records, record_cmp)

    // guards are only asleep during midnight minutes => 60 bools can describe a night
    // only one guard per night
    // we only care about the total number of minutes a guard sleeps and how often they are asleep at a given minute, so a map from guard_id to 60 ints, each counting how often a guard was asleep at that minute, is sufficient

    guard_sleep_map := make(map[int][60]int)
    current_guard_id: int = -1
    fell_asleep_minute: int = -1
    for record in records {
        switch e in record.event {
        case Start:
            if !(e.guard_id in guard_sleep_map) {
                guard_sleep_map[e.guard_id] = [60]int{}
            }
            current_guard_id = e.guard_id
        case StateUpdate:
            switch e.new_state {
            case .asleep:
                fell_asleep_minute = record.time.minute
            case .awake:
                woke_up_minute := record.time.minute
                guard_sleep_counts, ok := &guard_sleep_map[current_guard_id]
                if !ok {
                    panic("updating guard that isn't in map yet")
                }
                for idx in fell_asleep_minute ..< woke_up_minute {
                    guard_sleep_counts[idx] += 1
                }
                fell_asleep_minute = -1
            }
        }
    }

    guard_id_slept_most: int
    max_minutes_slept := 0
    for guard_id, sleep_counts in guard_sleep_map {
        minutes_slept := 0
        for c in sleep_counts {
            minutes_slept += c
        }
        if minutes_slept > max_minutes_slept {
            guard_id_slept_most = guard_id
            max_minutes_slept = minutes_slept
        }
    }

    most_slept_minute: int
    max_count := 0
    for count, idx in guard_sleep_map[guard_id_slept_most] {
        if count > max_count {
            most_slept_minute = idx
            max_count = count
        }
    }

    fmt.println("Guard -", guard_id_slept_most, "Minute -", most_slept_minute)
    fmt.println("Result 1 -", guard_id_slept_most * most_slept_minute)

    max_minute_counts := [60]int{}
    max_minute_guard_id := [60]int{}
    for guard_id, sleep_counts in guard_sleep_map {
        for idx in 0 ..< 60 {
            if sleep_counts[idx] > max_minute_counts[idx] {
                max_minute_guard_id[idx] = guard_id
                max_minute_counts[idx] = sleep_counts[idx]
            }
        }
    }
    max_max_minute_count := 0
    max_max_minute_idx: int
    for count, idx in max_minute_counts {
        if count > max_max_minute_count {
            max_max_minute_count = count
            max_max_minute_idx = idx
        }
    }
    max_max_minute_guard_id := max_minute_guard_id[max_max_minute_idx]

    fmt.println("Guard -", max_max_minute_guard_id, "Minute -", max_max_minute_idx)
    fmt.println("Result 2 -", max_max_minute_guard_id * max_max_minute_idx)
}

parse_line :: proc(line: []u8) -> (record: Record) {
    record.time.year = parse_int(line[1:5])
    record.time.month = parse_int(line[6:8])
    record.time.day = parse_int(line[9:11])
    record.time.hour = parse_int(line[12:14])
    record.time.minute = parse_int(line[15:17])
    if line[19] == 'f' {
        // falls asleep
        record.event = StateUpdate {
            new_state = .asleep,
        }
    } else if line[19] == 'w' {
        // wakes up
        record.event = StateUpdate {
            new_state = .awake,
        }
    } else {
        if line[29] != ' ' {
            // Guard #XXXX
            record.event = Start {
                guard_id = (parse_int(line[26:30])),
            }
        } else if line[28] != ' ' {
            // Guard #XXX
            record.event = Start {
                guard_id = (parse_int(line[26:29])),
            }
        } else if line[27] != ' ' {
            // Guard #XX
            record.event = Start {
                guard_id = (parse_int(line[26:28])),
            }
        } else {
            // Guard #X
            record.event = Start {
                guard_id = (parse_int(line[26:27])),
            }
        }
    }
    return record
}

parse_int :: proc(buf: []u8) -> int {
    num, ok := strconv.parse_int(string(buf))
    if !ok {
        fmt.eprintln("Failed to parse int from:", string(buf))
        os.exit(1)
    }
    return num
}
