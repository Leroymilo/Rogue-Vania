extends Node

var in_edges: Dictionary = {}
var out_edges: Dictionary = {}

func _ready():
	for edge in $edges.get_children():
		assert (edge is RoomEdge)
		# hypothesis : there can't be 2 paths with the same key
		
		if not in_edges.has(edge.end):
			in_edges[edge.end] = {}
		in_edges[edge.end][edge.start] = edge.req_pow
		
		if not out_edges.has(edge.start):
			out_edges[edge.start] = {}
		out_edges[edge.start][edge.end] = edge.req_pow

func get_all_exits(in_door: Vector2i, abils: int) -> Dictionary:
	var result: Dictionary = {}
	var queue: Array[Vector2i] = [in_door]
	
	while not queue.is_empty():
		var cur_node = queue.pop_front()
		
		for exit in out_edges[cur_node]:
			if not result.has(exit):
				if Abilities.can_use(abils, out_edges[in_door][exit]):
					result[exit] = null
					queue.append(exit)
	return result
