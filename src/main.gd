extends Node2D

@export var rooms: Array[PackedScene] = []
@export var map: Dictionary = {}
@onready var player
@onready var room_size: Vector2i = Parameters.ROOM_SIZE * Parameters.TILE_SIZE
var cur_room_pos: Vector2i = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():

	# generate map here

	var found_puppet = false
	for pos in map:
		var room = map[pos].instantiate()
		room.global_position = pos * room_size
		$room_container.add_child(room)
		
		# fetching initial playable puppet
		for puppet in room.get_node("puppets").get_children():
			if puppet.awake:
				if found_puppet:
					puppet.awake = false
				else:
					_on_player_entity_changed(puppet)
					found_puppet = true
	assert(found_puppet, "no initial puppet found")
	_on_player_moved()

func _on_player_moved():
	cur_room_pos = Vector2i(player.global_position) / room_size
	# fixing issue with negative values :
	if player.position.x < 0:
		cur_room_pos.x -= 1
	if player.position.y < 0:
		cur_room_pos.y -= 1
	$Camera2D.position = Vector2(cur_room_pos * room_size) + Vector2(room_size / 2)
	pass # Replace with function body.

func _on_player_entity_changed(new_player: CharacterBody2D):
	if player:
		player.disconnect("move", _on_player_moved)
		player.disconnect("change_player", _on_player_entity_changed)
	player = new_player
	player.connect("move", _on_player_moved)
	player.connect("change_player", _on_player_entity_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
