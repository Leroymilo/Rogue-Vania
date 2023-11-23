extends Node
class_name RoomEdge

# this node represents a way to traverse a room
# don't forget to add self-edges to represent going back through the same door

@export var start: Vector2i
# the room (relative to the current room) the player must come from to use this transition
@export var end: Vector2i
# the room (relative to the current room) this transition leads to
@export_flags_2d_navigation var req_pow: int
