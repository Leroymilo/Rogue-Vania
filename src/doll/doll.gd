extends CharacterBody2D

const Ghost = preload("res://ghost.tscn")

const dirs: Array[Vector2] = [
	Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT
]
@export var awake = true
@export var facing = Vector2.DOWN : set = set_facing
@export var attacking = false
var dir = Vector2.ZERO
var push_dir = Vector2.ZERO

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
	attacking = false
	update_anim_line()
	var time_scale = 1 / (4 * Parameters.STEP_LENGTH)
	$AnimationTree.set("parameters/time_scale/scale", time_scale)
	
	if awake:
		playback.start("move")
	else:
		playback.start("sleep")

func _input(event):
	if not awake or attacking: return
	
	dir = Vector2.ZERO
	
	if event.is_action_pressed("project"):
		project()
	
	elif event.is_action_pressed("attack"):
		attack(true)
	
	else:
		dir = Input.get_vector("left", "right", "up", "down")

func project():
	# astral projection
	playback.travel("rest")
	$project_cooldown.start()
	var ghost = Ghost.instantiate()
	get_parent().add_child(ghost)
	ghost.position = self.position
	ghost.set_facing(self.facing)

func attack(active: bool = false):
	if active:
		attacking = true
		# rotating hurt box
		print(facing)
		var rot = $wand_area.position.angle_to(facing)
		$wand_area.transform = $wand_area.transform.rotated(rot)
		rot = round($wand_area.global_rotation_degrees)
		$wand_area.global_rotation_degrees = rot
		
		playback.travel("attack")
	
	else:
		attacking = false
		# potentially deactivating hurt box
		pass

func _physics_process(delta):
	if not awake or attacking: return
	
	# snap to pushed object
	if dir.dot(push_dir) > 0:
		dir = push_dir
	
	velocity = Parameters.PLAYER_SPEED * dir
	move_and_slide()
	handle_push()
	handle_slide()

func handle_slide():
	var unit_motion
	if push_dir.is_zero_approx():
		# corrects animation when diagonal against a wall
		var motion = get_last_motion()
		unit_motion = motion * 60 / Parameters.PLAYER_SPEED
	else:
		unit_motion = push_dir
	$facing_blend.set("parameters/blend_position", unit_motion)

func handle_push():
	var collision = get_last_slide_collision()
	if not collision:
		push_dir = Vector2.ZERO
		return
	
	var collider = collision.get_collider()
	if collider.has_method("push"):
		push_dir = -collision.get_normal()
		
		if dir.dot(push_dir) <= 0:
			# probably tangent to collision
			push_dir = Vector2.ZERO
			return
		
		dir = push_dir
		collider.push(dir)

func _on_ghost_area_body_entered(body: Node2D):
	if awake: return
	if not $project_cooldown.is_stopped(): return
	
	if body.has_method("incarnate"):
		body.incarnate()
		playback.travel("wake_up")
