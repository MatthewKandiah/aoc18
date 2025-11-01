package day9

import "core:fmt"

PLAYER_COUNT :: 431
//LAST_MARBLE_VALUE :: 70950 // Part 1
LAST_MARBLE_VALUE :: 7095000 // Part 2

main :: proc() {
    /* archived first solution - works fine for a small number of marbles, but scales horribly due to all the ordered removals, too slow for part 2!
    scores := [PLAYER_COUNT]int{}
    next_marble := 1
    circle := [dynamic]int{}
    append(&circle, 0)
    current_marble_idx := 0
    current_player_idx := 0
    
    for next_marble <= LAST_MARBLE_VALUE {
	if next_marble % 1000 == 0 {
	    fmt.println("next marble:", next_marble)
	}
	if next_marble % 23 == 0 {
	    scores[current_player_idx] += next_marble
	    current_marble_idx = current_marble_idx - 7
	    for current_marble_idx < 0 {
		current_marble_idx = len(circle) + current_marble_idx
	    }
	    scores[current_player_idx] += circle[current_marble_idx]
	    ordered_remove(&circle, current_marble_idx)
	    current_marble_idx %= len(circle)
	} else {
	    current_marble_idx = (current_marble_idx + 1) % len(circle)
	    inject_at(&circle, current_marble_idx + 1, next_marble)
	    current_marble_idx += 1
	}
	
	next_marble += 1
	current_player_idx = (current_player_idx + 1) % PLAYER_COUNT
    }

    max_score := -1
    for score in scores {
	max_score = max(max_score, score)
    }
    fmt.println("Result:", max_score)
    */

    scores := make([]int, PLAYER_COUNT)

    marbles := make([]Marble, LAST_MARBLE_VALUE + 1)
    for i in 0 ..= LAST_MARBLE_VALUE {
        marbles[i] = Marble {
            next_idx = -1,
            prev_idx = -1,
        }
    }
    marbles[0].next_idx = 0
    marbles[0].prev_idx = 0
    current_player_idx := 0
    current_marble_idx := 0
    next_marble_idx := 1
    for next_marble_idx <= LAST_MARBLE_VALUE {
        if next_marble_idx % 23 == 0 {
            scores[current_player_idx] += next_marble_idx
            for i in 0 ..< 7 {
                current_marble_idx = marbles[current_marble_idx].prev_idx
            }
            scores[current_player_idx] += current_marble_idx
	    marble_idx_to_remove := current_marble_idx
            current_marble_idx = marbles[current_marble_idx].next_idx
	    remove_at(marbles, marble_idx_to_remove)
        } else {
            current_marble_idx = marbles[current_marble_idx].next_idx
            insert_after(marbles, current_marble_idx, next_marble_idx)
	    current_marble_idx = marbles[current_marble_idx].next_idx
        }

        current_player_idx += 1
        current_player_idx %= PLAYER_COUNT
        next_marble_idx += 1
    }

    max_score := -1
    for score in scores {
	max_score = max(max_score, score)
    }
    fmt.println("Result:", max_score)
}

print_marbles :: proc(marbles: []Marble, current_marble_idx: int) {
    fmt.println("print_marbles")
    fmt.println("\tvalue:", current_marble_idx, marbles[current_marble_idx])
    idx := marbles[current_marble_idx].next_idx
    for idx != current_marble_idx {
        fmt.println("\tvalue:", idx, marbles[idx])
        idx = marbles[idx].next_idx
    }
}

insert_after :: proc(marbles: []Marble, target_idx: int, insert_idx: int) {
    target_marble := marbles[target_idx]
    marbles[target_marble.next_idx].prev_idx = insert_idx
    marbles[target_idx].next_idx = insert_idx
    marbles[insert_idx].prev_idx = target_idx
    marbles[insert_idx].next_idx = target_marble.next_idx
}

remove_at :: proc(marbles: []Marble, target_idx: int) {
    target_marble := marbles[target_idx]
    marbles[target_marble.next_idx].prev_idx = target_marble.prev_idx
    marbles[target_marble.prev_idx].next_idx = target_marble.next_idx
    marbles[target_idx].next_idx = -1
    marbles[target_idx].prev_idx = -1
}

Marble :: struct {
    next_idx: int,
    prev_idx: int,
}
