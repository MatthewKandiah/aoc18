package day8

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

input_path :: "../../input/day8.txt"

Node :: struct {
    child_count:    int,
    metadata_count: int,
    children:       []Node,
    metadata:       []int,
}

parse_node :: proc(nums: []int) -> (node: Node, nums_used: int) {
    node.child_count = nums[0]
    node.metadata_count = nums[1]
    nums_used = 2

    node.children = make([]Node, node.child_count)
    node.metadata = make([]int, node.metadata_count)
    for i in 0..<node.child_count {
	child, child_nums_used := parse_node(nums[nums_used:])
	nums_used += child_nums_used
	node.children[i] = child
    }
    for i in 0..<node.metadata_count {
	node.metadata[i] = nums[nums_used]
	nums_used += 1
    }
    
    return node, nums_used
}

value :: proc(node: Node) -> int {
    sum := 0
    if node.child_count == 0 {
	for md in node.metadata {
	    sum += md
	}
	return sum
    }

    // node has children
    for md in node.metadata {
	if md == 0 {continue}
	if md > len(node.children) {continue}
	sum += value(node.children[md - 1])
    }
    return sum
}

main :: proc() {
    data, ok := os.read_entire_file(input_path)
    if !ok {
        fmt.eprintln("Failed to read input from", input_path)
        os.exit(1)
    }
    data = data[:len(data) - 1] // pesky newline at the end

    num_strings := strings.split(string(data), " ")
    nums := make([]int, len(num_strings))
    for ns, idx in num_strings {
        n, ok := strconv.parse_int(ns)
        if !ok {
            fmt.eprintln("Failed to parse int from string", ns)
            os.exit(2)
        }
        nums[idx] = n
    }

    root, nums_used := parse_node(nums)
    if nums_used != len(nums) {
	fmt.eprintln("Expected to use all numbers in input. nums_used:", nums_used, "len(nums):", len(nums))
	os.exit(3)
    }

    metadata_sum := 0
    nodes_to_do := [dynamic]Node{}
    append(&nodes_to_do, root)
    for len(nodes_to_do) > 0 {
	node := pop(&nodes_to_do)
	for child in node.children {
	    append(&nodes_to_do, child)
	}
	for md in node.metadata {
	    metadata_sum += md
	}
    }
    fmt.println("Result 1:", metadata_sum)

    fmt.println("Result 2:", value(root))
}
