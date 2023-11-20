extends CharacterBody2D

const dirs: Array[Vector2] = [
	Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT
]
@export var facing = Vector2.DOWN : set = set_facing
@export var awake = true
var dir = Vector2.ZERO
#var push_dir = Vector2.ZERO

@onready var playback: AnimationNodeStateMachinePlayback =\
$AnimationTree.get("parameters/state_machine/playback")

func set_facing(new_dir: Vector2):
	if not is_node_ready(): return
	if new_dir not in dirs: return
	
	facing = new_dir
	update_anim_line()

func update_anim_line():
	$sprite_sheet.frame_coords.y = dirs.find(facing)

func _ready():
	update_anim_line()
	var time_scale = 1 / (4 * Parameters.STEP_LENGTH)
	$AnimationTree.set("parameters/time_scale/scale", time_scale)

func _input(event):
	if not awake: return
	dir = Input.get_vector("left", "right", "up", "down")

func _physics_process(delta):
	if not awake: return
	velocity = Parameters.PLAYER_SPEED * dir
	move_and_slide()
	handle_slide()

func handle_slide():
	# corrects animation when diagonal against a wall
	var motion = get_last_motion()
	var unit_motion = motion * 60 / Parameters.PLAYER_SPEED
	$facing_blend.set("parameters/blend_position", unit_motion)

func incarnate():
	playback.travel("fade_out")
